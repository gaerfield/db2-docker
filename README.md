# db2-docker

Dockerfile for creating a [Db2-dbms-instance](https://www.ibm.com/analytics/us/en/db2/)

# Introduction

These files allow to create a container-image for [Db2](https://www.ibm.com/analytics/us/en/db2/)-dbms. The image will **not** be available on docker hub for the reason of licensing. You need to download the installation package by yourself and eplicitely "ACCEPT" the licence by providing a build-argument.

## building the image

* **Skip this step when using docker-compose**
* Download installation package
  * i.e. Db2 Developer Edition  [db2 express c](https://www.ibm.com/us-en/marketplace/ibm-db2-direct-and-developer-editions) (you need to create/use an account for this)
* put the installation-package in the folder `imageBuild`:
  * **either** by the name `db2.tar.gz`
  * **or** by using an arbitrary filename and setting build-argument `INSTALLATION_FILE=mydb2package.tar.gz`
* explicitely accept the licence by using the build-argument `ACCEPT_LICENCE=ACCEPT`
* optionally provide the product-variant as build-argument, the default is `PRODUCT=EXPRESS_C`
* example (execute within the `imageBuild`-Folder): `docker build --build-arg ACCEPT_LICENCE=ACCEPT . -t "db2:9.7"`

## Docker Compose

The [docker-compose.yml](docker-compose.yml)-file allows you to create a container from a local image. If the image does not exist yet, it would be build using the `imageBuild`-Folder as context-Path.
Make sure that:
* you put the installation-package within the imageBuild-Folder (its not possible to load files from outside the build-context-path)
* at least accept the licence
* provide an Database-Name, Database-User, Database-Password and:
  * **either** a SQL-Script for the creation of the database 
  * **or** an old backup of the database. 
  * Use the `STARTUP_MODE=[createIfNotExists|restorIfNotExists]` to set the desired bootstrap-behaviour.

## related work

* [lresende/docker-db2express-c](https://github.com/lresende/docker-db2express-c/blob/master/docker-entrypoint.sh)

