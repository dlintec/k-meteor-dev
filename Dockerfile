FROM ubuntu:xenial

MAINTAINER Tadeo Gutierrez "info@dlintec.com"

RUN apt-get update && \
apt-get -y dist-upgrade && \
apt-get install -y curl git python2.7 python2.7-dev build-essential whiptail vim nano vi

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
ENV APP_VER=1.75
ENV APP_LOCALDB="/home/meteor/meteorlocal/$APP_NAME"
ENV GIT_IMAGE="meteor-dev"
ENV LOCAL_IMAGE_PATH=/home/meteor/localimage
ENV PATH="$LOCAL_IMAGE_PATH/scripts:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
#COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN git clone https://github.com/$GIT_REPO/$GIT_IMAGE.git $LOCAL_IMAGE_PATH && \
ln -s $LOCAL_IMAGE_PATH/entrypoint.sh /usr/local/bin/entrypoint.sh && \
chmod +x $LOCAL_IMAGE_PATH/entrypoint.sh  && \
chmod -R +x $LOCAL_IMAGE_PATH/scripts/
RUN $LOCAL_IMAGE_PATH/scripts/k-update.sh
USER root
RUN chown -Rh meteor /usr/local 

USER meteor 

#RUN chmod +x /usr/local/bin/entrypoint.sh
#ENTRYPOINT [ "/usr/local/bin/meteor" ]
ENTRYPOINT [ "entrypoint.sh" ]
WORKDIR /opt/application/

