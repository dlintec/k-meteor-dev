@Echo Off

REM meteor-dev - Docker container for meteor development (2016 Tadeo Gutierrez)
echo "-----------------------------------------------------"
echo "   meteor-dev - Docker container for meteor development 
echo "   (2016 Tadeo Gutierrez)"
echo "   Preparing environment "
echo "-----------------------------------------------------"

docker stop k-meteor-dev
docker rm k-meteor-dev
cls
echo ""
echo "-----------------------------------------------------"
echo "   Creating Persistent data volume k-meteor-dev-local"
echo "-----------------------------------------------------"

docker volume create --name k-meteor-dev-local
echo ""
echo "-----------------------------------------------------"
echo "   Creaing Docker Image"
echo "-----------------------------------------------------"
docker build --tag="k-meteor-dev" git://github.com/dlintec/k-meteor-dev
echo ""
echo "-----------------------------------------------------"
echo "   Image Created"
echo "-----------------------------------------------------"

echo ""
echo "-----------------------------------------------------"
echo "   Starting container of NGINX (root)"
echo "-----------------------------------------------------"

docker run --rm -d --name k-meteor-dev --user root -p 80:80 -p 443:443 -v E:\meteor://opt/application -v  k-meteor-dev-local://home/meteor k-meteor-dev
echo ""
echo "-----------------------------------------------------"
echo "   WELCOME to k-metoer-dev"
echo "-----------------------------------------------------"
echo ""
sleep 2
echo "New windows for bash"
start cmd.exe /k "docker exec -it --user meteor k-meteor-dev /bin/bash k menu "



Exit
