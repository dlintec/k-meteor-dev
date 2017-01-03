docker stop k-meteor-dev
docker rm k-meteor-dev
mkdir -p /opt/application/
docker volume create --name k-meteor-dev-local
docker build --tag="k-meteor-dev" git://github.com/dlintec/k-meteor-dev
docker run --rm -d --name k-meteor-dev \
--user root -p 80:80 -p 443:443 -v /opt/application://opt/application -v  k-meteor-dev-local://home/meteor k-meteor-dev
docker exec -it --user meteor k-meteor-dev /bin/bash
