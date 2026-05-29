FROM php:8.3-cli

RUN apt-get update && apt-get install -y \
    cron \
    git \
    unzip \
    libzip-dev \
    libicu-dev \
    libonig-dev \
    libxml2-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxslt1-dev \
    libcurl4-openssl-dev \
    default-mysql-client \
 && docker-php-ext-install \
    pdo_mysql \
    intl \
    zip \
    soap \
    bcmath \
    gd \
    xsl \
    sockets

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN useradd -u 1001 -ms /bin/bash test-ssh

WORKDIR /var/www/html

COPY cron/magento-cron /etc/cron.d/magento-cron

RUN chmod 0644 /etc/cron.d/magento-cron && \
    crontab /etc/cron.d/magento-cron
RUN echo "memory_limit=512m" > /usr/local/etc/php/conf.d/memory-limit.ini
CMD ["cron", "-f"]
