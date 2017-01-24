docker stop k-meteor-dev
docker rm k-meteor-dev
docker stop sftp-container
docker rm sftp-container

REM Run the first 3 commands to create image and volumes (only needed once)
docker build --tag="k-meteor-dev" git://github.com/dlintec/k-meteor-dev
docker volume create --name k-meteor-dev-local
docker volume create --name k-meteor-dev-app

REM Use the next four commands every time to start environment

docker run -d --name k-meteor-dev --user root -p 80:80 -p 443:443 -v k-meteor-dev-app://opt/application -v  k-meteor-dev-local://home/meteor k-meteor-dev
docker exec -it --user root k-meteor-dev chown -Rh meteor /opt/application

REM Create ssh container to access /opt/application (/server/data/) on sftp  port 22
docker run -d --name sftp-container -p 22:22 -v k-meteor-dev-app:/server/data -e USERNAME=admin -e PASSWORD=changeme lerenn/sftp-server

REM exec meteor-dev menu
docker exec -it --user meteor k-meteor-dev /bin/bash k menu
