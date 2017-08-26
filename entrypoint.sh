#!/bin/bash
export DOCKER_WD="$(pwd)"
the_user=$(whoami)
source $LOCAL_IMAGE_PATH/scripts/k-lib.sh
k-output "entrypoint.sh:user:$the_user" "-"



if [ "$the_user" == "root" ];then
   echo ""
   echo "   Running NGINX proxy at port 80 and 443"
   #service nginx start
   k-output "entrypoint.sh:nginx:start"

   nginx -g "daemon off;"
   exit 0
else
   source $LOCAL_IMAGE_PATH/scripts/k-init-conf.sh

fi
server_url="$(kalan-var 'SERVER_URL')"
ssl_mail="$(kalan-var 'SSL_MAIL')"
ssl_domain="$(kalan-var 'SSL_DOMAIN')"

echo "EXECUTING entrypoint"
if [[ "$DOCKER_WD" == /opt/application* ]]; then 
 
   WD_APP_NAME="$(echo $DOCKER_WD | cut -d "/" -f 4)"
   if [ ! -z $WD_APP_NAME ] && [ -d /opt/application/$WD_APP_NAME/app/.meteor ]; then
      export APP_NAME="$WD_APP_NAME"
      echo "Inside [$APP_NAME]"

   fi
fi


if [ "$APP_NAME" == "default" ]; then
   echo "Setting APP_TEMPLATE to k-react"
   export APP_TEMPLATE="k-react"
fi
export APP_LOCALDB="/home/meteor/meteorlocal/$APP_NAME"
export LINK_LOCAL="$(readlink /opt/application/$APP_NAME/app/.meteor/local)"


#if [ -d /opt/application/$APP_NAME/packages ];then
      #export METEOR_PACKAGE_DIRS="/opt/application/$APP_NAME/packages"
#fi

if [ ! -d /opt/application/$APP_NAME ];then
      echo "No previous folder for app $APP_NAME"

   if [ -z $APP_TEMPLATE ] || [ "$APP_TEMPLATE" == "maka" ]; then
      cd /opt/application/
      echo "Creating new app $APP_NAME (maka create)"
      k-output "entrypoint.sh:maka:$APP_NAME"
      #mkdir -p /opt/application/$APP_NAME
      cd /opt/application
      meteor maka create "$APP_NAME"
      cd /opt/application/$APP_NAME
      if [[ -d "$APP_LOCALDB" ]];then
        echo "Cleaning Existing LOCALDB folder..."
        rm -rf $APP_LOCALDB
      fi
      mkdir -p $APP_LOCALDB

      if [ -d /opt/application/$APP_NAME/app/.meteor/local ];then
         echo "Copy generated local to $APP_LOCALDB..."
         cp -ar /opt/application/$APP_NAME/app/.meteor/local/* $APP_LOCALDB
         mv /opt/application/$APP_NAME/app/.meteor/local /opt/application/$APP_NAME/local_backup
      fi
      if [ ! -d /opt/application/$APP_NAME/app/.meteor ];then
        mkdir -p /opt/application/$APP_NAME/app/.meteor
      fi
      cd /opt/application/$APP_NAME/app
      ln -s $APP_LOCALDB /opt/application/$APP_NAME/app/.meteor/local 
      if [ ! -e /opt/application/$APP_NAME/app/package.json ];then
      package_string='{
  "name": "app",
  "private": true,
  "scripts": {
    "start": "meteor"
  },
  "dependencies": {
  }
}'
      echo $package_string >> /opt/application/$APP_NAME/app/package.json
      fi
     
      meteor  npm install --save bcrypt babel-runtime 
      meteor  npm install --save jsdoc
      #meteor maka jsdoc
         
      echo "Default meteor app created: $APP_NAME"

   else
      echo "Creating new app from template: [$APP_TEMPLATE]"
      
      if [ "$APP_TEMPLATE" == "meteor-application-template" ];then
         export APP_SETTINGS_FILE="/opt/application/$APP_NAME/config/settings.development.json"
         export APP_SETTINGS="--settings $APP_SETTINGS_FILE"
         echo "DEFAULT Using  default template"
         cd /opt/application
         git clone https://github.com/$GIT_REPO/$APP_TEMPLATE.git $APP_NAME
      else
         echo "Using repository $APP_TEMPLATE template "
         export APP_WORKDIR="/opt/application/$APP_NAME"
         mkdir -p $APP_WORKDIR
         cd $APP_WORKDIR
         if [[ "$APP_TEMPLATE" == https* ]];then
            git clone $APP_TEMPLATE app
         else
            git clone https://github.com/$GIT_REPO/$APP_TEMPLATE.git app
         fi
      fi
      exitstatus=$?
      k-output "entrypoint.sh:create:template:$APP_TEMPLATE:$exitstatus" $exitstatus
       mkdir -p $APP_LOCALDB
      if [ -d /opt/application/$APP_NAME/app/.meteor/local ];then
         cp -arv /opt/application/$APP_NAME/app/.meteor/local/* $APP_LOCALDB
         mv /opt/application/$APP_NAME/app/.meteor/local /opt/application/$APP_NAME/local_backup
      fi
      if [ ! -e /opt/application/$APP_NAME/app/package.json ];then
      package_string='{
  "name": "app",
  "private": true,
  "scripts": {
    "start": "meteor"
  },
  "dependencies": {
  }
}'
           echo $package_string >> /opt/application/$APP_NAME/app/package.json
      fi
      
       ln -s $APP_LOCALDB /opt/application/$APP_NAME/app/.meteor/local
       echo $APP_SETTINGS > /opt/application/$APP_NAME/app_settings.txt
       cd /opt/application/$APP_NAME/app 

   fi
   
   if [ ! -e /opt/application/$APP_NAME/app/app_config.txt ];then
      file_line_value /opt/application/$APP_NAME/app/app_config.txt "MOBILE_BUILD_URL" "MOBILE_BUILD_URL=$server_url"
   fi
   echo "New application created:[$APP_NAME]"
   
   echo "    TO enter work dir for that app type: "
   echo "    cd /opt/application/$APP_NAME/app"
   kalan-var "CURRENT_APP" "$APP_NAME"
   exit 0
fi

echo "Existing app"
if [[ ! -d "$APP_LOCALDB" ]];then
  echo "creating LOCALDB folder..."
  mkdir -p $APP_LOCALDB
  export NEW_LOCALDB="$APP_LOCALDB"
fi

file="/opt/application/$APP_NAME/app/.meteor/local"
if [[ -L "$file" && -d "$file" ]];then
    echo "LOCAL is a symlink to a directory"

    if [ ! "$LINK_LOCAL" == "$APP_LOCALDB" ];then
       echo "LOCAL symlink not same for $APP_NAME $LINK_LOCAL"
       rm /opt/application/$APP_NAME/app/.meteor/local
       ln -s $APP_LOCALDB /opt/application/$APP_NAME/app/.meteor/local 
    fi
else
   echo "No previous link OK"
   if [[ -d /opt/application/$APP_NAME/app/.meteor/local ]];then

       echo "BACKUP and Copying original folder to LOCALDB..."
       if [[ -d "$APP_LOCALDB" ]];then
           #echo "Cleaning Existing LOCALDB folder..."
           #rm -rf $APP_LOCALDB
           mkdir -p $APP_LOCALDB
       fi

       cp -ar /opt/application/$APP_NAME/app/.meteor/local/* $APP_LOCALDB
       mv /opt/application/$APP_NAME/app/.meteor/local /opt/application/$APP_NAME/local_backup
       ln -s $APP_LOCALDB /opt/application/$APP_NAME/app/.meteor/local
   else 
       echo "No previous local link or path on source"

        mkdir -p $APP_LOCALDB

       ln -s $APP_LOCALDB /opt/application/$APP_NAME/app/.meteor/local

   fi     

    cd /opt/application/$APP_NAME/app
    if [ "$APP_NAME" == "default" ]; then
      if [[ -d /opt/application/$APP_NAME/app/node_modules ]];then
          echo "updating"
          #meteor update 
          echo "Starting meteor npm install"
          meteor npm install
          exitstatus=$?
          k-output "entrypoint.sh:configure:app:default:$exitstatus" $exitstatus

       fi
    fi
     
fi

if [ -e /opt/application/$APP_NAME/app_settings.txt ];then
    APP_SETTINGS="$(cat /opt/application/$APP_NAME/app_settings.txt)"
    echo $APP_SETTINGS
fi

if [ -d /opt/application/$APP_NAME/.maka ];then
    echo "maka start"
  cd /opt/application/$APP_NAME
  k-output "entrypoint.sh:maka_starting:$APP_NAME"
  meteor maka run
else
  cd /opt/application/$APP_NAME/app
 
  kalan-var "CURRENT_APP" "$APP_NAME"
  echo "---------------------------------------"
  echo " CURRENT_APP: [$APP_NAME]"
  echo "  SERVER_URL: [$server_url]"
  echo " Starting meteor.Press Ctrl+Z to stop."
  echo "---------------------------------------"
  echo "settings:[$APP_SETTINGS]"
  #k-output "entrypoint.sh:starting:$APP_NAME" "-"

   export ROOT_URL=$server_url
  meteor --mobile-server $server_url $APP_SETTINGS $APP_PARAMETERS
 fi
#exit 0
