# build containers
FROM openfaas/of-watchdog:0.7.6 as watchdog
FROM composer:1.9 AS composer

# continue with the official PHP image
FROM php:7.4-alpine

# copy the Composer PHAR from the Composer image into the PHP image
COPY --from=composer /usr/bin/composer /usr/bin/composer

# composer requirements
ARG COMPOSER_AUTH='{}'
ENV COMPOSER_AUTH=${COMPOSER_AUTH}

COPY --from=watchdog /fwatchdog /usr/bin/fwatchdog
RUN chmod +x /usr/bin/fwatchdog

# install and configure roadrunner
RUN cd /tmp && \
    wget https://github.com/spiral/roadrunner/releases/download/v1.5.1/roadrunner-1.5.1-linux-amd64.tar.gz && \
    tar -xvf roadrunner-1.5.1-linux-amd64.tar.gz && \
    ls -alh && \
    mv roadrunner-1.5.1-linux-amd64/rr /usr/local/bin/ && \
    chmod +x /usr/local/bin/rr && \
    rm -rf /tmp/roadrunner*

# adding git for composer
RUN apk add --no-cache git

# create non-root user
RUN addgroup -S app && adduser -S -g app app && \
    mkdir -p /home/app

# add application
WORKDIR /home/app
COPY --chown=app index.php .rr.yaml composer.*  ./
COPY --chown=app ./function ./function

# install php roadrunner dependencies
RUN [[ -f composer.lock || -f composer.json ]] && composer install --no-dev --prefer-dist --no-progress

# install application dependencies
WORKDIR /home/app/function
USER app
RUN [[ -f composer.lock || -f composer.json ]] && composer install --no-dev

# Cleanup
USER root
RUN apk del git && \
    rm -rf /usr/src/php && \
    { find /usr/local/lib -type f -print0 | xargs -0r strip --strip-all -p 2>/dev/null || true; }

# define our entrypoint
USER app
WORKDIR /home/app

ENV fprocess="rr --config=/home/app/config/roadrunner/.rr.yaml serve -v -d"
ENV mode="http"
ENV write_debug="true"
ENV upstream_url="http://127.0.0.1:8090"

CMD ["fwatchdog"]