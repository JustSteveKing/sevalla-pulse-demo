FROM dunglas/frankenphp:php8.4-bookworm AS vendor

ENV SERVER_NAME=":8080"

RUN install-php-extensions @composer pcntl redis

WORKDIR /app

COPY composer.json composer.lock ./

RUN composer install \
    --ignore-platform-reqs \
    --optimize-autoloader \
    --prefer-dist \
    --no-interaction \
    --no-progress \
    --no-scripts

FROM node:22-slim AS assets

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
COPY --from=vendor /app/vendor vendor

RUN npm run build

FROM dunglas/frankenphp:php8.4-bookworm

ENV SERVER_NAME=":8080"

RUN install-php-extensions @composer pcntl redis

WORKDIR /app

COPY . .
COPY --from=vendor /app/vendor vendor
COPY --from=assets /app/public/build public/build

RUN composer install \
    --ignore-platform-reqs \
    --optimize-autoloader \
    --prefer-dist \
    --no-interaction \
    --no-progress \
    --no-scripts