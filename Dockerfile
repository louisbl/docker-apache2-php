FROM phusion/baseimage:0.9.15
MAINTAINER louisbl <louis@beltramo.me>

# Set correct environment variables.
ENV HOME /root

# Install packages
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apache2 libapache2-mod-php5 php5-mysql php5-gd php-pear php-apc curl && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin && mv /usr/local/bin/composer.phar /usr/local/bin/composer

# configure apache and php
RUN mv /etc/php5/apache2/php.ini /etc/php5/apache2/php.ini.bak
RUN ln -s /usr/share/php5/php.ini-development /etc/php5/apache2/php.ini

RUN sed -i "s/variables_order.*/variables_order = \"EGPCS\"/g" /etc/php5/apache2/php.ini
RUN sed -i "s/phar.readonly.*/phar.readonly = Off/g" /etc/php5/apache2/php.ini
RUN sed -i "s/^;extension=mysql.so/extension=mysql.so/" /etc/php5/apache2/php.ini
RUN sed -i "s/^;extension=mysqli.so/extension=mysqli.so/" /etc/php5/apache2/php.ini
RUN sed -i "s/^;extension=mcrypt.so/extension=mcrypt.so/" /etc/php5/apache2/php.ini

RUN sed -i "s/AllowOverride.*/AllowOverride All/g" /etc/apache2/apache2.conf
RUN a2enmod rewrite ssl
RUN a2ensite default-ssl

# remove ssh (use nsenter instead)
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# /app/web will be the public directory
RUN mkdir -p /app/web && rm -fr /var/www/html && ln -s /app/web /var/www/html

# add apache service
RUN mkdir /etc/service/apache
ADD build/apache.sh /etc/service/apache/run

# output log to stdout
RUN mkdir /etc/service/logviewer
ADD build/stdout-log.sh /etc/service/logviewer/run


# export HTTP and HTTPS ports
EXPOSE 80
EXPOSE 443

CMD ["/sbin/my_init"]

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
