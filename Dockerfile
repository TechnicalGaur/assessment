FROM ubuntu:latest
RUN apt-get update && apt-get install -y fortune cowsay netcat-openbsd
COPY wisecow.sh /app/wisecow.sh
RUN chmod +x /app/wisecow.sh
CMD ["/app/wisecow.sh"]
