FROM phusion/baseimage:0.9.11
MAINTAINER louisbl <louis@beltramo.me>

# Set correct environment variables.
ENV HOME /root

# Install packages
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apache2 libapache2-mod-php5 php5-mysql php5-gd php-pear php-apc curl && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin && mv /usr/local/bin/composer.phar /usr/local/bin/composer

RUN sed -i "s/variables_order.*/variables_order = \"EGPCS\"/g" /etc/php5/apache2/php.ini
RUN sed -i "s/phar.readonly.*/phar.readonly = Off/g" /etc/php5/apache2/php.ini
RUN sed -i "s/AllowOverride.*/AllowOverride All/g" /etc/apache2/apache2.conf
RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/

RUN /usr/sbin/enable_insecure_key

RUN mkdir /etc/service/apache
RUN mkdir /etc/service/logviewer
ADD build/apache.sh /etc/service/apache/run
ADD build/stdout-log.sh /etc/service/logviewer/run

EXPOSE 80
CMD ["/sbin/my_init"]

RUN mkdir -p /app/web && rm -fr /var/www/html && ln -s /app/web /var/www/html

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
