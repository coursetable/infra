doppler setup -p coursetable -c prd
(cd traefik && doppler run --command "docker-compose up -d")
(cd under_maintenance && doppler run --command "docker-compose up -d")
(cd mysql && doppler run --command "docker-compose up -d")
(cd ferry && doppler run --command "docker-compose up -d")