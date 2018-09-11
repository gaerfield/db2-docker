# db2-docker
Dockerfile for creating a [Db2-dbms-instance](https://www.ibm.com/analytics/us/en/db2/)

# Introduction
This files allow to create a container-image for [Db2](https://www.ibm.com/analytics/us/en/db2/)-dbms. The image will **not** be available on docker hub for the reason of licensing. You need to download the installation package by yourself and provide a response-file (where you explicitely accept the licence agreement).

## building the image
* Download installation package
  * i.e. Db2 Developer Edition  [db2 express c](https://www.ibm.com/us-en/marketplace/ibm-db2-direct-and-developer-editions) (you need to create/use an account for this)
* put the installation-package in the folder `imageBuild/db2-install` by the name `db2.tar.gz`
* provide the response `db2.rsp` within the folder `imageBuild/db2-install` (there is an example-file you can use)
* change into folder imageBuild
* execute `docker build . -t "db2:9.7"`

## running the image
* docker-compose-file will follow

## related work
* [lresende/docker-db2express-c](https://github.com/lresende/docker-db2express-c/blob/master/docker-entrypoint.sh)

