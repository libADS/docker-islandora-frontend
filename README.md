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
# foreground
docker run -i -t -p 80:80 -p 8888:8888 --hostname=dev.islandora.org --name islandora --link mysql:db --link fedora:backend -v $ISLANDORA_SOURCE:/source islandora/frontend:latest

# background
docker run -d -p 80:80 -p 8888:8888 --hostname=dev.islandora.org --name islandora --link mysql:db --link fedora:backend -v $ISLANDORA_SOURCE:/source islandora/frontend:latest

# run from within the container
docker run -i -t -p 80:80 -p 8888:8888 --hostname=dev.islandora.org --name islandora --link mysql:db --link fedora:backend -v $ISLANDORA_SOURCE:/source islandora/frontend:latest /bin/bash
./setup.sh &

# overriding the site (can be used with any docker run invocation)
docker run -i -t -p 80:80 -p 8888:8888 --hostname=dev.islandora.org --name islandora --link mysql:db --link fedora:backend -v $ISLANDORA_SOURCE:/source -e "DRUPAL_SITE=ir.uwf.edu" islandora/frontend:latest /bin/bash
./setup.sh
```

---

```
# DEFAULT
docker run -d -p 80:80 -p 8888:8888 --hostname=dev.islandora.org --name islandora --link mysql:db --link fedora:backend -v $ISLANDORA_SOURCE:/source islandora/frontend:latest
```

---
