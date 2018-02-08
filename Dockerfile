FROM ubuntu:xenial
MAINTAINER Tadeo Gutierrez "info@dlintec.com"
ENV TERM=xterm
#apt-get -y dist-upgrade && \
#zip unzip software-properties-common
USER root

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
RUN echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list

RUN apt-get update && \
    apt-get install -y apt-utils curl wget git python2.7 python2.7-dev build-essential software-properties-common \
    default-jdk whiptail vim nano nginx lsof zip unzip imagemagick mongodb-org language-pack-en net-tools iproute2 gradle
    
RUN localedef en_US.UTF-8 -i en_US -fUTF-8 

RUN useradd -mUd /home/meteor meteor && \
chown -Rh meteor /usr/local

USER meteor

RUN curl https://install.meteor.com/ | sh



WORKDIR /opt/application/


EXPOSE 80 443 3000 3001 3040
ENV PYTHON=/usr/bin/python2.7

ENV APP_NAME="default"
ENV GIT_REPO="dlintec"

ENV APP_VER=2.0
ENV APP_LOCALDB="/home/meteor/meteorlocal/$APP_NAME"
ENV GIT_IMAGE="k-meteor-dev"
ENV LOCAL_IMAGE_PATH=/home/meteor/localimage
ENV PATH="$LOCAL_IMAGE_PATH/scripts:/home/meteor/links:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$LOCAL_IMAGE_PATH/.nvm"
ENV NVM_DIR="$LOCAL_IMAGE_PATH/.nvm"
#replace with "yourdomain.com"
ENV DOMAIN_NAME="127.0.0.1"
#COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN git clone https://github.com/$GIT_REPO/$GIT_IMAGE.git $LOCAL_IMAGE_PATH && \
ln -s $LOCAL_IMAGE_PATH/entrypoint.sh /usr/local/bin/entrypoint.sh && \
chmod +x $LOCAL_IMAGE_PATH/entrypoint.sh  && \
chmod -R +x $LOCAL_IMAGE_PATH/scripts/
RUN mkdir -p /home/meteor/links/ 
RUN $LOCAL_IMAGE_PATH/scripts/k-update.sh

USER root

RUN mkdir -p /home/meteor/ssl/certs
RUN chown -Rh root:root /home/meteor/ssl
RUN mkdir -p /home/meteor/nginxconf
RUN chown -Rh root:root /home/meteor/nginxconf

RUN chown -Rh meteor /usr/local && \
chown -Rh meteor /etc/newt

RUN cd /home/meteor/ssl && \
openssl req -nodes -newkey rsa:2048 -keyout /home/meteor/ssl/certs/nginx-selfsigned.key -out /home/meteor/ssl/server.csr \
  -subj "/C=MX/ST=MEX/L=Mexico/O=dlintec/OU=k-meteor-dev/CN=$DOMAIN_NAME" 
RUN openssl x509 -req -days 2000 -in /home/meteor/ssl/server.csr -signkey /home/meteor/ssl/certs/nginx-selfsigned.key -out /home/meteor/ssl/certs/nginx-selfsigned.crt
RUN openssl dhparam -out /home/meteor/ssl/certs/dhparam.pem 2048

COPY ssl-params.conf /home/meteor/nginxconf/ssl-params.conf
RUN  ln -s /home/meteor/nginxconf/ssl-params.conf /etc/nginx/snippets/ssl-params.conf

COPY self-signed.conf /home/meteor/nginxconf/self-signed.conf
RUN  ln -s /home/meteor/nginxconf/self-signed.conf /etc/nginx/snippets/self-signed.conf

RUN  mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak

COPY nginx-proxy-settings /home/meteor/nginxconf/nginx-proxy-settings
RUN  ln -s /home/meteor/nginxconf/nginx-proxy-settings /etc/nginx/sites-available/default


RUN  mv /etc/nginx/nginx.conf /etc/nginx/bak-nginx.conf

COPY nginx.conf /home/meteor/nginxconf/nginx.conf
RUN  ln -s /home/meteor/nginxconf/nginx.conf /etc/nginx/nginx.conf

RUN add-apt-repository ppa:certbot/certbot && \ 
    apt-get update && \
    apt-get install -y python-certbot-nginx 

USER meteor 

#RUN meteor npm install -g maka-cli && \
#meteor npm install -g jsdoc
#RUN chmod +x /usr/local/bin/entrypoint.sh
#ENTRYPOINT [ "/usr/local/bin/meteor" ]

ENTRYPOINT [ "entrypoint.sh" ]

WORKDIR /opt/application/
#CMD ["nginx", "-g", "daemon off;"]
#USER root 
