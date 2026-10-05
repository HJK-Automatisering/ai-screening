FROM node:20 AS theme-build
WORKDIR /app
COPY web/themes/custom/itkdev ./web/themes/custom/itkdev
RUN yarn --cwd web/themes/custom/itkdev/itkdev_project_theme install && \
    yarn --cwd web/themes/custom/itkdev/itkdev_base_theme install && \
    yarn --cwd web/themes/custom/itkdev/itkdev_base_theme build

FROM itkdev/php8.4-fpm:alpine
COPY --chown=deploy:deploy composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader

COPY --chown=deploy:deploy . .
COPY --chown=deploy:deploy --from=theme-build /app/web/themes/custom/itkdev ./web/themes/custom/itkdev

RUN composer install --no-dev -o
RUN mkdir -p /app/local-config && ln -s /app/local-config/settings.local.php web/sites/default/settings.local.php