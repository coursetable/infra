doppler setup -p coursetable -c prod
(cd traefik && doppler run --command "docker compose up -d")
(cd under_maintenance && doppler run --command "docker compose up -d")
(cd db && doppler run --command "docker compose up -d")
(cd api_services && doppler run --command "docker compose up -d")