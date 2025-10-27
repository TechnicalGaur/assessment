FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fortune cowsay netcat ca-certificates && \
    ln -s /usr/games/fortune /usr/bin/fortune && \
    ln -s /usr/games/cowsay /usr/bin/cowsay && \
    rm -rf /var/lib/apt/lists/*

# Copy script into container
COPY wisecow.sh /app/wisecow.sh
RUN chmod +x /app/wisecow.sh

EXPOSE 4499
CMD ["/app/wisecow.sh"]

