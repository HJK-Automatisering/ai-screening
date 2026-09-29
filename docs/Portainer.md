# Portainer deployment (Hjørring Kommune)

This environment has no Traefik and no external "frontend" network. Nginx
Proxy Manager (NPM) is the reverse proxy, and it reaches backend containers
by container/service name over a shared Docker network rather than via
published host ports.

Use `docker-compose.portainer.yml` (not `docker-compose.server.yml`) for
this environment.

## Deploying the stack

In Portainer: **Stacks → Add stack**, build method **Repository**, pointing
at this fork/branch, with `docker-compose.portainer.yml` as the compose
path. Set these environment variables before deploying:

- `COMPOSE_PROJECT_NAME`
- `COMPOSE_SERVER_DOMAIN`
- `MARIADB_ROOT_PASSWORD`
- `MARIADB_PASSWORD`

## Connecting Nginx Proxy Manager

1. **Portainer → Containers → nginx-proxy-manager → Join network** →
   select `<project-name>_app` (the network created by this stack).
2. In NPM, create a Proxy Host:
   - **Forward Hostname**: `nginx`
   - **Forward Port**: `8080`
   - Enable SSL, Block Common Exploits; Websockets Support is not needed.

## settings.local.php

Unlike `docs/Production.md`'s example, the database host is `mariadb` (the
service name in this stack), not `host.docker.internal` - MariaDB runs as
part of this stack rather than externally:

``` php
$databases['default']['default']['host'] = 'mariadb';
$databases['default']['default']['username'] = 'ai-screening';
$databases['default']['default']['password'] = ''; // matches MARIADB_PASSWORD
```

Create this file directly in the stack's checkout on the Portainer host, at
`web/sites/default/settings.local.php` - it is never committed to git. See
`docs/Production.md` for the rest of the required settings (trusted host
pattern, OpenID Connect).
