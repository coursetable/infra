# Docker Container Infrastructure

This repository details all of the underlying production infrastructure for databases, reverse proxies, and administration tools that the [coursetable](https://github.com/coursetable/coursetable/) abstracts away.

The infrastructure is currently designed to provision on a monolithic VM. However, it is configuration-agonistic. Its pure dependencies are `docker` and `docker compose`. Please see [how-to-deploy.md](https://github.com/coursetable/coursetable/blob/master/docs/how-to-deploy.md) for instructions on how to bootstrap a new server.

Each directory denotes a separate Docker Compose configuration, each with its own network.

Below is the list of every network and its attached services (including those defined in [coursetable](https://github.com/coursetable/coursetable/)):
 - **[`traefik`](traefik/)**
    - `traefik`
        - Container Name / Docker Hostname: `traefik`
        - Purpose: Reverse proxy router for all incoming requests
        - Access: Public (*coursetable.com)
- **[`mysql`](mysql/)**
    - `mysql`
        - Container Name / Docker Hostname: `${MYSQL_HOST}`
        - Purpose: Standing MySQL DB for all user data
        - Access: Local
    - `phpmyadmin`
        - Container Name / Docker Hostname:`phpmyadmin`
        - Purpose: PHP My Admin GUI for MySQL DB
        - Access: Authorized Public [pma.coursetable.com](https://pma.coursetable.com)
- **[`ferry`](ferry/)**
    - `db`
        - Container Name / Docker Hostname: `${FERRY_HOST}`
        - Purpose: Standing Postgres DB for all course data (see [ferry](https://github.com/coursetable/ferry/))
        - Access: Authorized Public
- **[`${API_NETWORK}`](https://github.com/coursetable/coursetable/tree/master/api/)**
    - `api`
        - Container Name / Docker Hostname: `${EXPRESS_HOST}`
        - Purpose: Continuously deployed application server
        - Access: Public [api.coursetable.com](https://api.coursetable.com/api/ping)
    - `graphql-engine`
        - Container Name / Docker Hostname: `${GRAPHQL_ENGINE_HOST}`
        - Purpose: Continuously deployed Hasura Engine wrapping the `ferry` container
        - Access: Local (Public Proxy: https://coursetable.com/graphiql)
    - `redis`
        - Container Name / Docker Hostname: `${REDIS_HOST}`
        - Purpose: Continuously deployed KV cache for session management
        - Access: Local
- **[`under_maintenance`](under_maintenance)**
    - `web`
        - Container Name / Docker Hostname: `under_maintenance`
        - Purpose: Maintenance page that loads if the `api` service is not up.
        - Access: Public (*coursetable.com)