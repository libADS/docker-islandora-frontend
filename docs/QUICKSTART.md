Quickstart instructions
=============

Install Docker (currently only tested with Ubuntu Docker 0.9.1 installed via apt-get). General steps are:

- Clone the source repository
- Pull / download any pre-reqs
- Build the container (may take a while the first time but be lightning fast afterwards)
- Run the container

**MYSQL**

```
git clone https://github.com/tutumcloud/tutum-docker-mysql
cd tutum-docker-mysql
docker build -t tutum/mysql .
docker run -d -p 3306:3306 --name mysql -e MYSQL_PASS="admin" tutum/mysql
```

Give it 10 or so seconds to initialize. Should be accessible via `localhost:3306`.

**FEDORA**

```
git clone https://github.com/lyrasis/docker-islandora-backend.git
cd docker-islandora-backend
./get_jars.sh
docker build -t dts/fedora:latest .
docker run -d -p 8080:8080 --name fedora --link mysql:db dts/fedora:latest
```

Give it about 2 minutes to initialize. Should be accessible via `localhost:8080`.

**DJATOKA**

```
git clone https://github.com/lyrasis/docker-djatoka.git
cd docker-djatoka
docker build -t dts/djatoka:latest .
docker run -d -p 8888:8888 --name djatoka dts/djatoka:latest
```

Give it 10 or so seconds to initialize. Should be accessible via `localhost:8888`.

**ISLANDORA**

```
export ISLANDORA_SOURCE=/home/username/Projects/docker-all/docker-islandora-frontend/source # add to .bashrc and source it
git clone https://github.com/lyrasis/docker-islandora-frontend.git
cd docker-islandora-frontend
./get_binaries.sh
cd source
./get_repositories.sh
cd ..
docker build -t dts/islandora:latest .

# DEFAULT
docker run -d -p 80:80 --name islandora --link mysql:db --link fedora:backend --link djatoka:djatoka -v $ISLANDORA_SOURCE:/source dts/islandora:latest

# DAVIDSON
docker run -d -p 80:80 --name islandora --link mysql:db --link fedora:backend --link djatoka:djatoka -v $ISLANDORA_SOURCE:/source -e "DRUPAL_SITE=davidson.lyrasistechnology.org" dts/islandora:latest

# UWF
docker run -d -p 80:80 --name islandora --link mysql:db --link fedora:backend --link djatoka:djatoka -v $ISLANDORA_SOURCE:/source -e "DRUPAL_SITE=ir.uwf.edu" dts/islandora:latest
```

Give it 30 seconds or so to initialize. Should be accessible via `localhost` or `dev.islandora.org` (with /etc/hosts) entry.

---

- Refer to each repository README for more detailed instructions.
- Times to initialize are based on desktop i5 8gb -- may need to be adjusted.

---
