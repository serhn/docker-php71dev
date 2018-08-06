FROM php:7.1.17-fpm

ENV MEMCACHED_VERSION 3.0.4 
RUN apt-get update -y && apt-get install -y libpng-dev libsqlite3-dev
RUN docker-php-ext-install gd pdo pdo_sqlite exif pdo_mysql zip


RUN apt-get install -y mysql-client
RUN apt-get install -y net-tools vim
RUN apt-get install -y git
# build-essential
RUN apt-get install -y nmap mc tmux screen
RUN apt-get install -y dnsutils 

RUN apt-get install -y gnupg2

#RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs


RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }"

RUN php /tmp/composer-setup.php
RUN mv composer.phar /usr/local/bin/composer
RUN rm /tmp/composer-setup.php





RUN apt-get install -y libmagickwand-dev
RUN pecl install imagick-beta
RUN echo "extension=imagick.so" > /usr/local/etc/php/conf.d/ext-imagick.ini




RUN apt-get install -y libz-dev libmemcached-dev
#RUN pecl install memcached
#RUN echo "extension=memcached.so" > /usr/local/etc/php/conf.d/memcached.ini
RUN pecl install igbinary 
RUN docker-php-ext-enable igbinary

ENV LIBMEMCACHED_VERSION 1.0.16
ENV MEMCACHED_VERSION 3.0.4
RUN apt-get install -y \
  libmemcached-dev \
  && pecl download memcached-$MEMCACHED_VERSION \
  && tar xzvf memcached-$MEMCACHED_VERSION.tgz \
  && cd memcached-$MEMCACHED_VERSION \
  && phpize \ 
  && ./configure --enable-memcached-igbinary --enable-memcached-json \
  && make \ && make install \
  && docker-php-ext-enable memcached \


  RUN pecl install xdebug
RUN docker-php-ext-enable xdebug
RUN echo  "\
  xdebug.remote_port=9000 \n\
  xdebug.remote_enable=on \n\ 
  xdebug.remote_log=/var/log/xdebug.log " >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN touch /var/log/xdebug.log

RUN apt-get install -y ssmtp
RUN echo "[mail function]\nsendmail_path = /usr/sbin/ssmtp -t" > /usr/local/etc/php/conf.d/sendmail.ini
RUN echo "mailhub=mailcatcher:1025\nUseTLS=NO\nFromLineOverride=YES" > /etc/ssmtp/ssmtp.conf


RUN echo  "\
  syntax on \n\
  autocmd FileType php set omnifunc=phpcomplete#CompletePHP \n\
  set number \n\
  :set encoding=utf-8 \n\
  :set fileencoding=utf-8"  >> /root/.vimrc

