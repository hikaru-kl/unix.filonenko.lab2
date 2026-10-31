
FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends util-linux \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY worker.sh /app/worker.sh

RUN chmod +x /app/worker.sh

ENTRYPOINT ["/app/worker.sh"]

