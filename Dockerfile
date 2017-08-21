FROM ubuntu:xenial
MAINTAINER Tadeo Gutierrez "info@dlintec.com"
ENV TERM=xterm
#apt-get -y dist-upgrade && \
#zip unzip software-properties-common
USER root

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
RUN echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list
RUN apt-get update && \
apt-get install -y curl wget git python2.7 python2.7-dev build-essential whiptail vim nano nginx software-properties-common lsof zip unzip imagemagick mongodb-org language-pack-en net-tools iproute2 

RUN add-apt-repository -y ppa:webupd8team/java 

RUN apt-get update && \
apt-get install -y oracle-java8-installer

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
ENV PATH="$LOCAL_IMAGE_PATH/scripts:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$LOCAL_IMAGE_PATH/.nvm"
ENV NVM_DIR="$LOCAL_IMAGE_PATH/.nvm"
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

RUN  mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak

RUN  ln -s $LOCAL_IMAGE_PATH/nginx-proxy-settings /etc/nginx/sites-available/default
#RUN systemctl enable nginx
#RUN update-rc.d nginx defaults
#RUN ufw allow 'Nginx Full'
#RUN ufw delete allow 'Nginx HTTP'

RUN  mv /etc/nginx/nginx.conf /etc/nginx/bak-nginx.conf
RUN  ln -s $LOCAL_IMAGE_PATH/nginx.conf /etc/nginx/nginx.conf
#COPY nginx.conf /etc/nginx/nginx.conf

USER meteor 

#RUN meteor npm install -g maka-cli && \
#meteor npm install -g jsdoc
#RUN chmod +x /usr/local/bin/entrypoint.sh
#ENTRYPOINT [ "/usr/local/bin/meteor" ]

ENTRYPOINT [ "entrypoint.sh" ]

WORKDIR /opt/application/
#CMD ["nginx", "-g", "daemon off;"]
#USER root 
