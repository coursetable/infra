doppler setup -p coursetable -c prd
(cd traefik && doppler run --command "docker-compose up -d")
(cd under-maintenance && doppler run --command "docker-compose up -d")
(cd mysql && doppler run --command "docker-compose up -d")
