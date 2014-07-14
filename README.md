Docker Islandora Frontend
================

Run Islandora on Ubuntu precise (php5.3 -- 5.4 ok?). Islandora and its modules are pulled locally and made available to the container, therefore development can happen directly on the development machine and changes will be reflected inside the container.

Binary default versions:
-------------------------------

- Fits 0.8.0
- OpenSeadragon 0.9.129
- VideoJS 4.0.0

Requirements
------------------

- Access to a linked MySQL database aliased as **db** exposing **3306**. 
- Access to a linked Fedora backend aliased as **backend** exposing **8080**. 
- Access to a linked Djatoka instance aliased as **djatoka* exposing **8888**.

```
docker run -d -p 3306:3306 --name mysql -e MYSQL_PASS="admin" tutum/mysql
docker run -d -p 8080:8080 --name fedora --link mysql:db dts/fedora:latest
docker run -d -p 8888:8888 --name djatoka dts/djatoka:latest
```

Set the ENV path to the source directory:

```
export ISLANDORA_SOURCE=/path/to/docker-islandora-frontend/source
# i.e. in .bashrc: export ISLANDORA_SOURCE=/home/username/Projects/docker-all/docker-islandora-frontend/source
```

Add a local /etc/host entry:

```
127.0.0.1 dev.islandora.org
```

You can then use `dev.islandora.org` or `localhost` in the browser.

Pull all of the binaries and source repositories:

```
./get_binaries.sh
cd source
./get_repositories.sh
```

The `modules_install_order.csv` determines which source modules get installed (and in what order) for the `default` site only.

Build:

```
docker build -t dts/islandora:latest .
```

Run:

```
docker run -i -t -p 80:80 --name islandora --link mysql:db --link fedora:backend --link djatoka:djatoka -v $ISLANDORA_SOURCE:/source dts/islandora:latest # foreground
docker run -d -p 80:80 --name islandora --link mysql:db --link fedora:backend --link djatoka:djatoka -v $ISLANDORA_SOURCE:/source dts/islandora:latest # background
```

Run from within the container:

```
docker run -i -t -p 80:80 --name islandora --link mysql:db --link fedora:backend --link djatoka:djatoka -v $ISLANDORA_SOURCE:/source dts/islandora:latest /bin/bash
./setup.sh &
```

Overriding the site (can be used with any docker run invocation):

```
docker run -i -t -p 80:80 --name islandora --link mysql:db --link fedora:backend --link djatoka:djatoka -v $ISLANDORA_SOURCE:/source -e "DRUPAL_SITE=ir.uwf.edu" dts/islandora:latest /bin/bash
./setup.sh &
```

---

```
# DEFAULT
docker run -d -p 80:80 --name islandora --link mysql:db --link fedora:backend --link djatoka:djatoka -v $ISLANDORA_SOURCE:/source dts/islandora:latest

# DAVIDSON
docker run -d -p 80:80 --name islandora --link mysql:db --link fedora:backend --link djatoka:djatoka -v $ISLANDORA_SOURCE:/source -e "DRUPAL_SITE=davidson.lyrasistechnology.org" dts/islandora:latest

# UWF
docker run -d -p 80:80 --name islandora --link mysql:db --link fedora:backend --link djatoka:djatoka -v $ISLANDORA_SOURCE:/source -e "DRUPAL_SITE=ir.uwf.edu" dts/islandora:latest
```

---