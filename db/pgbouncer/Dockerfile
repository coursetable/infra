FROM edoburu/pgbouncer:latest

# Custom step to generate all users from environment variables
COPY wrapped-entrypoint.sh /
# Use our wrapped entrypoint with the same command
ENTRYPOINT ["/wrapped-entrypoint.sh"]
CMD ["/usr/bin/pgbouncer", "/etc/pgbouncer/pgbouncer.ini"]
