FROM php:7.4.4-apache

ARG CERT_URL

#
# Install basic requirements
#
RUN apt-get update \
 && apt-get install -y \
 curl \
 apt-transport-https \
 git \
 vim \
 build-essential \
 libssl-dev \
 wget \
 unzip \
 bzip2 \
 libbz2-dev \
 zlib1g-dev \
 libfontconfig \
 libfreetype6-dev \
 libjpeg62-turbo-dev \
 libpng-dev \
 libicu-dev \
 libxml2-dev \
 libldap2-dev \
 libmcrypt-dev \
 python-pip \
 fabric \
 jq \
 gnupg \
 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
apt-get update --allow-unauthenticated \
&& apt-get install -y nodejs

RUN apt install -y npm
RUN npm install -g gulp

# PHP Composer 1.10.13
RUN php -r "copy('https://raw.githubusercontent.com/composer/getcomposer.org/454bd7b5a9fd3224e8584d363e92138322fe6832/web/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir="/usr/local/bin" --filename=composer \
    && php -r "unlink('composer-setup.php');"

ENV PROJECT_DIR=/var/www/html \
    APP_URL=localhost \
    PROJECT_SRC=/var/mass-testing-platform/

RUN mkdir $PROJECT_SRC
RUN docker-php-ext-install mysqli gettext gd

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
RUN echo 'export NVM_NODEJS_ORG_MIRROR=http://nodejs.org/dist/' >> /root/.bashrc

# Adding Certs
RUN if [ -n "$CERT_URL" ]; then  curl -sL $CERT_URL | bash -; fi

COPY docker-entrypoint.sh /entrypoint.sh

RUN sed -i 's/\r//' /entrypoint.sh

VOLUME $PROJECT_DIR/storage

# Enter the container with immediate access to project root
WORKDIR $PROJECT_SRC

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["run"]
