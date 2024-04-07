doppler setup -p coursetable -c prod
(cd traefik && doppler run --command "docker-compose up -d")
(cd under_maintenance && doppler run --command "docker-compose up -d")
(cd mysql && doppler run --command "docker-compose up -d")
(cd ferry && doppler run --command "docker-compose up -d")