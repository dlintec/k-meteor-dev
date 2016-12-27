#!/bin/bash
main() {
   source $LOCAL_IMAGE_PATH/scripts/k-lib.sh
   function meteor-dev-ls {
      filelines=$(ls /opt/application)
      valid_apps=""
      for line in $filelines ; do
          #echo "Checking $line"
          if [ -d /opt/application/$line/app/.meteor ];then
             echo $line
          fi
          
      done
      #echo $valid_apps
   }

   for arg in "$@" ; do
       case "$arg" in

         ps)
               valid_apps="$(meteor-dev-ls)"
               echo "$valid_apps"
               exit 0
         ;;
         menu)
               k-menu
               exit 0
         ;;
 

         update)
               k-update.sh
               exit 0
         ;;
 
         run)
               ap=$2
               if [ ! -z $ap ] && [ -d /opt/application/$ap ]; then
                      export APP_NAME="$ap"
               fi
               cd /opt/application/$APP_NAME
               entrypoint.sh
               exit 0
         ;;
         create)
               ap=$2
               template=$3
               if [ ! -z $ap ] && [ ! -d /opt/application/$ap ]; then
                  echo "K is Creating new app:$ap" 
                  export APP_NAME="$ap"
                  
               else 
                  echo "Can not create application [$ap]. Folder already exists"
                  exit 1
               fi

               if [ ! -z $template ]; then
                  export APP_TEMPLATE="$template"
               fi
               cd /opt/application
               entrypoint.sh
               exit 0
           ;;
           
           clean)
               filelines=$(ls /home/meteor/meteorlocal)

               for line in $filelines ; do
                   #echo "Creando link para script $line"
                  if [ -d /home/meteor/meteorlocal/$line ] && [ -d /opt/application/$line/app/.meteor ];then
                     echo "App Ok: $line"
                  else
                     echo "Removing LOCALDB for $line"
                     rm -rf /home/meteor/meteorlocal/$line
                  fi
               done
           ;;
           
           use)
               ap=$2
               if [ ! -z $ap ] && [ -e /opt/application/$ap/app/.meteor ]; then
                  export APP_NAME="$ap"
                  kalan-var "CURRENT_APP" "$APP_NAME"
                  echo "Using: [$(kalan-var 'CURRENT_APP')]"
                  exit 0
               else 
                  if [ ! -z $ap ];then
                     echo "Can not use [$ap]. There is no valid project folder at $ap/app "
                  else
                     echo "$(kalan-var 'CURRENT_APP')"
                  fi
                  exit 1
               fi
               
           ;;
           maka)
              mk_command=$2
              shift
              pars=$@
              meteor maka $pars
           ;;
           meteor)
              m_command=$2
              shift
              pars=$@
              current_app=$(kalan-var "CURRENT_APP")
              echo "CURRENT_APP : [$current_app]"
              if [ ! -z $current_app ] && [ -d /opt/application/$APP_NAME/app ];then
                 cd /opt/application/$current_app/app
                 echo "$(pwd)"
                 case "$m_command" in
                     reset)
                        meteor $pars
                        if [ ! -z "$(readlink /opt/application/$APP_NAME/app/.meteor/local)" ];then
                           echo "removing link"
                            rm -sf /opt/application/$APP_NAME/app/.meteor/local
                        fi
                        exit 0
                     ;;
                     #any other command
                     *)
                        echo "running: meteor $pars"
                        if [ -z "$pars" ];then
                           entrypoint.sh
                        else
                           meteor $pars
                        fi
                        exit 0

                     ;;
                 esac

              else
                 echo "No application in use"
                 echo "Select an application typing:"
                 echo "   k use appname"
                 
              fi
              exit 0
           ;;

          *)
            
           if [ ! -z $arg ] && [ -d /opt/application/$arg ]; then
    
                   export APP_NAME="$arg"
                   
                   cd /opt/application/$APP_NAME
                   entrypoint.sh
                   exit 0
           else
                eval "$@"       
           fi

            ;;
        esac
  done
  #echo "final:$@"
}

main "$@"
