FROM ubuntu:xenial

MAINTAINER Tadeo Gutierrez "info@dlintec.com"
#apt-get -y dist-upgrade && \
#zip unzip software-properties-common
RUN apt-get update && \
apt-get install -y curl git python2.7 python2.7-dev build-essential whiptail vim nano nginx  

#add-apt-repository -y ppa:ubuntu-desktop/ubuntu-make && \
#apt-get update && \
#apt-get install -y ubuntu-make

RUN localedef en_US.UTF-8 -i en_US -fUTF-8 && \
useradd -mUd /home/meteor meteor && \
chown -Rh meteor /usr/local

USER meteor

RUN curl https://install.meteor.com/ | sh


WORKDIR /opt/application/


EXPOSE 3000 3001 3040
ENV PYTHON=/usr/bin/python2.7

ENV APP_NAME="default"
ENV GIT_REPO="dlintec"
ENV APP_VER=1.78
ENV APP_LOCALDB="/home/meteor/meteorlocal/$APP_NAME"
ENV GIT_IMAGE="k-meteor-dev"
ENV LOCAL_IMAGE_PATH=/home/meteor/localimage
ENV PATH="$LOCAL_IMAGE_PATH/scripts:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
#replace with "yourdomain.com"
ENV DOMAIN_NAME="127.0.0.1"
#COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN git clone https://github.com/$GIT_REPO/$GIT_IMAGE.git $LOCAL_IMAGE_PATH && \
ln -s $LOCAL_IMAGE_PATH/entrypoint.sh /usr/local/bin/entrypoint.sh && \
chmod +x $LOCAL_IMAGE_PATH/entrypoint.sh  && \
chmod -R +x $LOCAL_IMAGE_PATH/scripts/
RUN $LOCAL_IMAGE_PATH/scripts/k-update.sh

USER root


RUN chown -Rh meteor /usr/local && \
chown -Rh meteor /etc/newt
RUN cd /etc/ssl && \
openssl req -nodes -newkey rsa:2048 -keyout /etc/ssl/certs/nginx-selfsigned.key -out /etc/ssl/server.csr \
  -subj "/C=MX/ST=MEX/L=Mexico/O=dlintec/OU=k-meteor-dev/CN=$DOMAIN_NAME" 
RUN openssl x509 -req -days 2000 -in /etc/ssl/server.csr -signkey /etc/ssl/certs/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
RUN openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
COPY ssl-params.conf /etc/nginx/snippets/ssl-params.conf 
COPY self-signed.conf /etc/nginx/snippets/self-signed.conf
RUN ufw allow 'Nginx Full'  
RUN ufw delete allow 'Nginx HTTP' 
RUN  mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
RUN  ln -s $LOCAL_IMAGE_PATH/ngynx-proxy-settings /etc/nginx/sites-available/default

USER meteor 
RUN meteor npm install -g maka-cli && \
meteor npm install -g jsdoc
#RUN chmod +x /usr/local/bin/entrypoint.sh
#ENTRYPOINT [ "/usr/local/bin/meteor" ]
ENTRYPOINT [ "entrypoint.sh" ]

WORKDIR /opt/application/

