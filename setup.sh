#!/bin/bash

# for symlinking source repositories into drupal
function link {
  local link_type=$1
  local link_path=$2
  for link in /source/$link_type/*; do
    NAME=`basename $link`
    if [[ -d $link ]]; then
        ln -s $link $link_path/$NAME
    fi
  done
}

function setup_islandora {
  local site_name=$1
  local site_path=$2
  local site_initialize=$3
  cd $site_path
  echo "Setting up Islandora for $site_name"
  if [[ "$site_name" == "Islandora" ]]; then
    drush -y site-install standard --site-name=$site_name --account-mail=$ISLANDORA_EMAIL --account-pass=$ISLANDORA_PASSWORD
  else
    drush -y site-install --site-name=$site_name --account-mail=$ISLANDORA_EMAIL --account-pass=$ISLANDORA_PASSWORD
  fi

  drush -y vset islandora_base_url http://$BACKEND_PORT_8080_TCP_ADDR:8080/fedora
  drush -y vset islandora_solr_url http://$BACKEND_PORT_8080_TCP_ADDR:8080/solr
  drush -y vset islandora_paged_content_djatoka_url http://$DJATOKA_PORT_8888_TCP_ADDR:8888
  drush -y vset islandora_fits_executable_path $FITS_PATH/fits.sh

  # install the modules
  while IFS=, read MODULE
  do
    if [[ "$MODULE" == "" || "$MODULE" =~ ^#.*$ ]]; then
      continue
    fi
    drush -y -u 1 en $MODULE  
  done < "/modules_install_order.csv"
  cd
}

# for additional (not default) sites, in synced source/sites directory
# install the site if it matches $DRUPAL_SITE
function setup_sites {
  echo "<?php" >> $DRUPAL_SITES_PATH/sites.php
  for site in /source/sites/*; do
    NAME=`basename $site`
    if [[ -d $site ]]; then
      mkdir $DRUPAL_SITES_PATH/$NAME
      mkdir $DRUPAL_SITES_PATH/$NAME/files
      chmod -R a+w $DRUPAL_SITES_PATH/$NAME/files
      cp $DRUPAL_DEFAULT_PATH/settings.php $DRUPAL_SITES_PATH/$NAME
      ln -s $site/modules $DRUPAL_SITES_PATH/$NAME/modules
      ln -s $site/themes $DRUPAL_SITES_PATH/$NAME/themes

      if [[ "$NAME" == "$DRUPAL_SITE" ]]; then
        echo "\$sites['localhost'] = '$NAME';" >> $DRUPAL_SITES_PATH/sites.php
        echo "\$sites['dev.islandora.org'] = '$NAME';" >> $DRUPAL_SITES_PATH/sites.php

        # site specific features / themes etc.
        FEATURE=$DRUPAL_SITES_PATH/$NAME/modules/*
        FEATURE_NAME=`basename $FEATURE`
        THEME=$DRUPAL_SITES_PATH/$NAME/themes/*
        THEME_NAME=`basename $THEME`
        
        cd $DRUPAL_SITES_PATH/$NAME
        drush -y -u 1 en $FEATURE_NAME
        drush -y -u 1 en $THEME_NAME
        cd
      fi
    fi
  done
}

DRUPAL_PATH=/var/www/drupal
DRUPAL_SOURCE_PATH=/source/base/drupal

DRUPAL_DEFAULT_PATH=$DRUPAL_PATH/sites/default
DRUPAL_LIBRARIES_PATH=$DRUPAL_PATH/sites/all/libraries
DRUPAL_MODULES_PATH=$DRUPAL_PATH/sites/all/modules/islandora
DRUPAL_SITES_PATH=$DRUPAL_PATH/sites
DRUPAL_THEMES_PATH=$DRUPAL_PATH/sites/all/themes

# drupal is slightly special in this arrangement: copy it out of the source directory because we don't want "synced" symlinks
# changes to drupal source will require a re-run to be seen in the container -- probably not a great need for that
rm -rf $DRUPAL_PATH
rm -rf $DRUPAL_SITES_PATH/sites.php
cp -r $DRUPAL_SOURCE_PATH $DRUPAL_PATH
mkdir $DRUPAL_DEFAULT_PATH/files
chmod -R a+w $DRUPAL_DEFAULT_PATH/files

# SETUP DATABASE
mysql --host=$DB_PORT_3306_TCP_ADDR --port=3306 --user=$ADMIN --password=$ADMIN_PASSWORD -e "CREATE DATABASE $DRUPAL_DB default character set utf8;"
mysql --host=$DB_PORT_3306_TCP_ADDR --port=3306 --user=$ADMIN --password=$ADMIN_PASSWORD -e "grant all on $DRUPAL_DB.* to '$DRUPAL_USER'@'%' identified by '$DRUPAL_PASSWORD';"

cp /settings.php $DRUPAL_DEFAULT_PATH/settings.php
mkdir -p $DRUPAL_MODULES_PATH
mkdir -p $DRUPAL_LIBRARIES_PATH

sed -i "s/!MYSQL_HOST!/$DB_PORT_3306_TCP_ADDR/g" $DRUPAL_DEFAULT_PATH/settings.php
sed -i "s/!DRUPAL_DB!/$DRUPAL_DB/g" $DRUPAL_DEFAULT_PATH/settings.php
sed -i "s/!DRUPAL_USER!/$DRUPAL_USER/g" $DRUPAL_DEFAULT_PATH/settings.php
sed -i "s/!DRUPAL_PASSWORD!/$DRUPAL_PASSWORD/g" $DRUPAL_DEFAULT_PATH/settings.php
sed -i "s/!DJATOKA_HOST!/$DJATOKA_PORT_8888_TCP_ADDR/g" /etc/apache2/sites-available/islandora # may not need

# PHP CONFIG
sed -i "s/max_execution_time = 30/max_execution_time = 120/g" /etc/php5/apache2/php.ini
sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 24M/g" /etc/php5/apache2/php.ini
sed -i "s/post_max_size = 8M/post_max_size = 28M/g" /etc/php5/apache2/php.ini

# LINK THEMES, MODULES, LIBRARIES
link "libraries" $DRUPAL_LIBRARIES_PATH
link "modules" $DRUPAL_MODULES_PATH
link "themes" $DRUPAL_THEMES_PATH

ln -s $OPENSEADRAGON_PATH $DRUPAL_LIBRARIES_PATH/openseadragon
ln -s $VIDEOJS_PATH $DRUPAL_LIBRARIES_PATH/video.js

if [[ "default" == "$DRUPAL_SITE" ]]; then
  setup_islandora "Islandora" $DRUPAL_DEFAULT_PATH
else
  setup_islandora "Islandora" $DRUPAL_DEFAULT_PATH
  setup_sites  
fi

# setup a mods xml form
for sql in /sql/*.sql; do
  mysql --host=$DB_PORT_3306_TCP_ADDR --port=3306 --user=$ADMIN --password=$ADMIN_PASSWORD $DRUPAL_DB < $sql
done

# hard coded param alert! disable default collections
php ./islandora_set_object_state.php -h http://$BACKEND_PORT_8080_TCP_ADDR:8080/fedora -u fedoraAdmin -p fedora -s I

exec supervisord -n
