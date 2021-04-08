FROM php:7.3

# install build requirements
RUN apt update && \
    apt -y install make git curl zip zlib1g-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev libxml2-dev libonig-dev libcurl4-openssl-dev libldap2-dev libicu-dev locales gettext make && \
    rm -r /var/lib/apt/lists /var/cache/apt/archives/*

# generate locales required by the test suite
RUN printf "de_DE.UTF-8 UTF-8\nen_US.utf8 UTF-8\nfr_FR.utf8 UTF-8\n" > /etc/locale.gen && \
    locale-gen &&\
    dpkg-reconfigure --frontend=noninteractive locales

# configure/intall php extensions
RUN docker-php-ext-configure gd --with-freetype-dir=/usr --with-jpeg-dir=/usr && docker-php-ext-install gd simplexml json mbstring intl curl gettext ldap

# install composer
RUN curl --silent --show-error https://getcomposer.org/installer --output composer-setup.php && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer

# disable xdebug: it significantly speed up tests and linter, and we don't use coverage yet
RUN phpenv config-rm xdebug.ini || echo 'No xdebug config.' 

# create Drone CI user/environment
RUN useradd --home-dir /drone/ --create-home --shell /bin/bash drone && \
    mkdir /drone/src && \
    chown -R drone:drone /drone/src && \
    chmod -R 0755 /drone/src

USER drone
