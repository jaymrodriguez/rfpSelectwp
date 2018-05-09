FROM wordpress:php7.2-apache
# COPY composer.json /var/www/html
# COPY composer.lock /var/www/html
COPY . /var/www/html

# install git
RUN apt-get update && apt-get install -y git zip unzip

# install composer
RUN curl -o /tmp/composer.phar http://getcomposer.org/composer.phar \
  && mv /tmp/composer.phar /usr/local/bin/composer && chmod a+x /usr/local/bin/composer
# install our dependencies(wordpress, themes and plugins)
WORKDIR  /var/www/html
RUN composer install
