FROM php:7.2-apache

# install the PHP extensions we need
RUN set -ex; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libjpeg-dev \
		libpng-dev \
	; \
	\
	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
	docker-php-ext-install gd mysqli opcache; \
	\
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { print $3 }' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN a2enmod rewrite expires

# install git
RUN apt-get update && apt-get install -y git zip unzip

RUN curl -sS https://getcomposer.org/installer | php \
        && mv composer.phar /usr/local/bin/ \
        && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer


WORKDIR  /usr/src
COPY composer.json .
# COPY composer.lock .

RUN composer install; \
    mv wp-content /var/www/html; \ 
    mkdir /var/www/html/wp-content/config; \
    mkdir /var/www/html/wp-content/themes/twentyseventeen/acf-json; \
	mkdir /var/www/html/wp-content/plugins/rfp-filters; \
    chown -R www-data:www-data /usr/src/wp; \
    chown -R www-data:www-data /var/www/html/wp-content/config; \
    chown -R www-data:www-data /var/www/html/wp-content/themes/twentyseventeen/acf-json; \
	chown -R www-data:www-data /var/www/html/wp-content/plugins/rfp-filters 



COPY docker-entrypoint.sh /usr/local/bin/ 

COPY wp-content/config /var/www/html/wp-content/config

COPY acf-json /var/www/html/wp-content/themes/twentyseventeen/acf-json

COPY rfp-filters /var/www/html/wp-content/plugins/rfp-filters 


RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]

WORKDIR  /var/www/html


