FROM r-base:4.4.3

LABEL org.opencontainers.image.authors="Andrew Kane <andrew@ankane.org>"

RUN apt-get update && apt-get install -qq -y --no-install-recommends \
  libxml2-dev libssl-dev libcurl4-openssl-dev libsodium-dev libssh2-1-dev

RUN mkdir -p /app
WORKDIR /app

COPY init.R DESCRIPTION renv.lock ./
RUN Rscript init.R

COPY . .

CMD ["Rscript", "server.R"]
