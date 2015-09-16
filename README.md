# docker-java
Dockerfile base on ubuntu and install java 8

**Build Dockerfil** <br />
docker build -t my-mysql-server .

**Run a container** <br />
docker run -d my-mysql-server <br />
cb260adc41f718e9afc452d54e7bf26f8b4b6a07946ea6a2ec3b4d800e7facee

**Access to Mysql shell client** <br />
docker run -t -i --rm --volumes-from=cb260adc41f718e9afc452d54e7bf26f8b4b6a07946ea6a2ec3b4d800e7facee  argus-core mysql -uroot
