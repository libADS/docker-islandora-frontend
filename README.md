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
docker run -d -p 8080:8080 --name fedora --link mysql:db islandora/backend:latest
docker run -d -p 8888:8888 --name djatoka islandora/djatoka:latest
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
docker build -t islandora/frontend:latest .
```

Run:

```
docker run -i -t -p 80:80 --name islandora --link mysql:db --link fedora:backend --link djatoka:djatoka -v $ISLANDORA_SOURCE:/source islandora/frontend:latest # foreground
docker run -d -p 80:80 --name islandora --link mysql:db --link fedora:backend --link djatoka:djatoka -v $ISLANDORA_SOURCE:/source islandora/frontend:latest # background
```

Run from within the container:

```
docker run -i -t -p 80:80 --name islandora --link mysql:db --link fedora:backend --link djatoka:djatoka -v $ISLANDORA_SOURCE:/source islandora/frontend:latest /bin/bash
./setup.sh &
```

Overriding the site (can be used with any docker run invocation):

```
docker run -i -t -p 80:80 --name islandora --link mysql:db --link fedora:backend --link djatoka:djatoka -v $ISLANDORA_SOURCE:/source -e "DRUPAL_SITE=ir.uwf.edu" islandora/frontend:latest /bin/bash
./setup.sh
```

---

```
# DEFAULT
docker run -d -p 80:80 --name islandora --link mysql:db --link fedora:backend --link djatoka:djatoka -v $ISLANDORA_SOURCE:/source islandora/frontend:latest
```

---

Djatoka considerations
------------------------------

For content that leverages Djatoka as a viewer (IA book reader, large image) Djatoka needs to be able to access the url of the content from Islandora. For example:

```
http://172.17.0.3:8888/resolver?rft_id=http%3A%2F%2Fdev.islandora.org%2Fislandora%2Fobject%2Fislandora%3A17%2Fdatastream%2FJP2%2Fview%3Ftoken%3D0f433453eea71f5509c51b2babb911118d2035d0c2f235fd9bbdf4ef88ca3b7d&url_ver=Z39.88-2004&svc_id=info%3Alanl-repo%2Fsvc%2FgetRegion&svc_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajpeg2000&svc.format=image%2Fpng&svc.level=4&svc.rotate=0
```

This is a problem in the sense that Docker does not support bi-directional container linking and `/etc/hosts` is read only without a ugly hack. Therefore if properly viewing the content is important then use the ip address of the Islandora container in the request:

```
http://172.17.0.5/islandora/object/islandora:15#page/1/mode/1up
```

Djatoka will then be able to do its thing.

---
