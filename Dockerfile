FROM wordpress:php7.2-apache
COPY . /var/www/html

# install composer
RUN curl -o /tmp/composer.phar http://getcomposer.org/composer.phar \
  && mv /tmp/composer.phar /usr/local/bin/composer && chmod a+x /usr/local/bin/composer
# install our dependencies(wordpress, themes and plugins)
RUN composer install
