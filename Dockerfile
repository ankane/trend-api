FROM r-base:4.0.0

MAINTAINER Andrew Kane <andrew@chartkick.com>

RUN apt-get update && apt-get install -qq -y --no-install-recommends \
  libxml2-dev libssl-dev libcurl4-openssl-dev libssh2-1-dev

RUN mkdir -p /app
WORKDIR /app

COPY init.R DESCRIPTION packrat.lock ./
RUN Rscript init.R

COPY . .

CMD Rscript server.R
