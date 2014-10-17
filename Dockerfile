FROM ubuntu:12.04

ENV ADMIN admin
ENV ADMIN_PASSWORD admin
ENV DRUPAL_DB drupal
ENV DRUPAL_USER drupal
ENV DRUPAL_PASSWORD drupal
ENV ISLANDORA_SITENAME Islandora
ENV ISLANDORA_PASSWORD admin
ENV ISLANDORA_EMAIL example@example.com
ENV FITS_PATH /fits-0.8.0/fits-0.8.0
ENV KAKADU_PATH /kakadu-733/KDU733_Demo_Apps_for_Linux-x86-64_140118
ENV OPENSEADRAGON_PATH /openseadragon-bin-0.9.129/openseadragon-bin-0.9.129
ENV VIDEOJS_PATH /video-js-4.0.0/video-js

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install build-essential python-software-properties
RUN add-apt-repository --yes http://ppa.launchpad.net/jon-severinsson/ffmpeg/ubuntu
RUN add-apt-repository --yes ppa:lyrasis/precise-tools
RUN add-apt-repository --yes ppa:lyrasis/precise-backports

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apache2 curl libapache2-mod-php5 git imagemagick maven mysql-client openjdk-7-jdk supervisor unzip vim
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install ffmpeg ffmpeg2theora graphicsmagick-imagemagick-compat
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install lame libavcodec-extra-53 libimage-exiftool-perl libmagickcore6 libmagickcore6-extra libjasper-dev libleptonica-dev libogg0 libopenjp27 libtheora0 libvorbis0a
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install bibutils ghostscript poppler-utils tesseract-ocr tesseract-ocr-eng
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install php5 php5-curl php5-gd php5-imagick php5-mysql php5-xsl php5-xdebug php-pear php-soap

# PHP -- COMPOSER, DRUSH
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN cd /root && /usr/local/bin/composer global require drush/drush:6.*
# double check this later
RUN ln -s /root/.composer/vendor/bin/drush /usr/local/bin/drush

RUN pecl install uploadprogress
RUN echo "extension=uploadprogress.so" > /etc/php5/apache2/conf.d/uploadprogress.ini

# FITS
ADD bin/fits-0.8.0.zip /fits-0.8.0.zip
RUN unzip fits-0.8.0.zip -d fits-0.8.0
RUN chown -R www-data:www-data $FITS_PATH
RUN chmod a+x $FITS_PATH/fits.sh

# KAKADU
ADD bin/KDU733_Demo_Apps_for_Linux-x86-64_140118.zip /KDU733_Demo_Apps_for_Linux-x86-64_140118.zip
RUN unzip /KDU733_Demo_Apps_for_Linux-x86-64_140118.zip -d kakadu-733
RUN mkdir -p /opt/kakadu/lib
RUN cp $KAKADU_PATH/* /opt/kakadu
RUN mv /opt/kakadu/libkdu_v73R.so /opt/kakadu/lib/libkdu_v73R.so
RUN chmod a+x /opt/kakadu/kdu_*
RUN echo "/opt/kakadu/lib" > /etc/ld.so.conf.d/kakadu.conf
RUN ldconfig
RUN ln -s /opt/kakadu/kdu_compress /usr/bin/kdu_compress

# OPENSEADRAGON
ADD bin/openseadragon-bin-0.9.129.zip /openseadragon-bin-0.9.129.zip
RUN unzip /openseadragon-bin-0.9.129.zip -d openseadragon-bin-0.9.129

# VIDEOJS
ADD bin/video-js-4.0.0.zip /video-js-4.0.0.zip
RUN unzip /video-js-4.0.0.zip -d video-js-4.0.0

# DJATOKA
RUN git clone https://github.com/ksclarke/freelib-djatoka.git /freelib-djatoka
RUN cd /freelib-djatoka && mvn -q install && cd

ADD configuration/php/drushrc.php /root/.composer/vendor/drush/drushrc.php
ADD configuration/apache2/islandora /etc/apache2/sites-available/islandora
ADD configuration/drupal/settings.php /settings.php
ADD configuration/supervisor/supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD configuration/supervisor/start-apache2.sh /start-apache2.sh
ADD source/modules_install_order.csv /modules_install_order.csv
ADD setup.sh /setup.sh

RUN chmod u+x /*.sh
RUN a2enmod rewrite
RUN a2enmod proxy
RUN a2enmod proxy_http
RUN a2dissite default
RUN a2ensite islandora

EXPOSE 80 8888

CMD ["/setup.sh"]
