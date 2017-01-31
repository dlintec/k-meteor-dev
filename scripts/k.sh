#!/bin/bash
main() {
   source $LOCAL_IMAGE_PATH/scripts/k-lib.sh
   backup_folder="/home/meteor/k-temp"
  for arg in "$@" ; do
       case "$arg" in

         ls)
               valid_apps="$(k-meteor-dev-ls)"
               echo "$valid_apps" 
               exit 0
         ;;
         stop)
               kill $(ps -U meteor | grep "[m]ongo" | awk '{print $1}' )
					kill $(ps -U meteor | grep "[n]ode" | awk '{print $1}' )
					current_app=$(kalan-var "CURRENT_APP")	    
               k-output "k.sh:stop:$current_app"
         ;;
	 dropdatabase)
	    current_app=$(kalan-var "CURRENT_APP")
	    if [ ! -z "$current_app" ] && [ -d /home/meteor/meteorlocal/$current_app/db ];then
	    	k-output "k.sh:dropdatabase:$current_app"
		echo "Dropping database for $current_app"
	    	rm -rf /home/meteor/meteorlocal/$current_app/db
	    fi
	    exit 0
	 ;;
         updateapp)
            current_app=$(kalan-var "CURRENT_APP")
            if [ ! -z "$current_app" ] && [ -d /opt/application/$current_app/app/.git ];then
               clear
               echo ""
               echo "----------------------------------------------------"
               echo "   Updating the app will overwrite any "
               echo "   changes made in the local code. "
               echo "   Are you sure?"
               echo "----------------------------------------------------"
               read -n 1 -p "   press (y) to accept or any key to cancel:" confirm_update
               echo ""
               if [ "$confirm_update" == "y" ];then
                  
                  cd /opt/application/$current_app/app
                  git fetch --all
                  git reset --hard origin/master
                  git pull
                  exitstatus=$?
                  k-output "k.sh:updateapp:$current_app:$exitstatus" $exitstatus
               fi
               exit $exitstatus
             else
               echo "Application $current_app is not a Git repository"
               echo "Can not be updated"
               k-output "k.sh:updateapp:$current_app:Not a Git repository:1" "1"
               exit 1
             fi
 
             
         ;;
	 exportdb)
	 	current_app=$(kalan-var "CURRENT_APP")
		cd /opt/application/$current_app
	        echo "Please wait. Exporting Database to /opt/application/$current_app/dumps..."
		
	     	mongodump -h 127.0.0.1 --port 3001 -d meteor
		tar -pczf /opt/application/$current_app/app/dump.tar /opt/application/$current_app/dump
		exit 0
	 ;;
	 importdb)
	         current_app=$(kalan-var "CURRENT_APP")
		
	 	mongorestore -h 127.0.0.1 --port 3001 -d meteor --drop /opt/application/$current_app/dump/meteor
		
		exit 0
	 ;;
         backup)
              name=$2
              if [ -z "$name" ];then
                    name=$(kalan-var "CURRENT_APP")
              fi
              mkdir -p /opt/application/_k-meteor-dev/backups
              file_name="/opt/application/_k-meteor-dev/backups/$(date '+%Y-%m-%d_%H-%M-%S')_$name.tar"
              echo "Be patient. Starting backup..."
              k-output "k.sh:bakcup:start:$file_name"
              tar -pczf $file_name /home/meteor/ 
              exitstatus=$?
              k-output "k.sh:backup:finish:$file_name:$exitstatus"
              echo "Backup finished"
              
              exit 0
         ;;
         restore)
              file_name=$2
              valid_tar="false"
              backup_made="false"
              temp_folder="/home/meteor/k-temp"
              if [ ! -z "$file_name" ] && [ -e /opt/application/_k-meteor-dev/backups/$file_name ];then
                    echo "Decompressing to temp"
                    if [ -d $temp_folder ];then
                       echo "A previous restore failed. The original backup is in "
                       echo "$temp_folder"
                       echo ""
                       read -n 1 -p "press akey to continue..." wait_var
                       #rm -rf $temp_folder
                    fi
                    old_ls="$(ls -a /home/meteor)"
                     mkdir $temp_folder
                     echo "making backup"
                                  
                     k-output "k.sh:restore:start:$file_name"
 
                     for line in $old_ls ; do
                      
                         if [ ! "$line" == "." ] && [ ! "$line" == ".." ] && [ ! "$line" == "k-temp" ];then
                            echo "moving $line to temp folder"
                            mv /home/meteor/$line $temp_folder/$line
                         fi

                     done                    
                     
                    cd /
                    tar -pxzf /opt/application/_k-meteor-dev/backups/$file_name
                    exitstatus=$?
                    k-output "k.sh:restore:tar:$file_name:$exitstatus" $exit_status
 
                    if [ -d /home/meteor/.meteor ] && [ -e /home/meteor/localimage/scripts/k-update.sh ];then
                       valid_tar="true"
                    fi
                    if [ "$valid_tar" == "true" ];then
                          echo "Valid backup file"
                           if [ -d $temp_folder  ];then
                                 rm -rf $temp_folder 
                           fi
                    else

                        echo "removing failed restore"
                        failed_ls="$(ls -a /home/meteor)"
                        for line in $failed_ls ; do
                             if [ ! "$line" == "." ] && [ ! "$line" == ".." ] && [ ! "$line" == "k-temp" ];then
                              echo "removing $line "
                               if [ -d /home/meteor/$line ];then
                                  rm -rf /home/meteor/$line 
                               else
                                  rm -f /home/meteor/$line
                               fi
                               
                             fi  
                         done
                         
                         
                         echo "restoring from $temp_folder"
                         backup_ls="$(ls -a $temp_folder)"
                        for line in $backup_ls ; do
                             if [ ! "$line" == "." ] && [ ! "$line" == ".." ] && [ ! "$line" == "k-temp" ];then
                              echo "restoring $line to user folder"
                               mv $temp_folder/$line /home/meteor/$line
                             fi
                        done                    
                        rm -rf $temp_folder
                        
                         echo "Reverted to original state"
                    fi  
              else 
                 echo "The file is not a valid backup"
                 echo "$file_name"
              fi
               
              exit 0
         ;;
         tree)
              for p in `meteor list | grep '^[a-z]' | awk '{ print $1"@"$2 }'`; do echo "$p"; meteor show "$p" | grep -E '^  [a-z]'; echo; done
              read -n 1 -p "Press a key to return to menu:" wait_var
              exit 0
         ;;
         menu)
               k-menu
               exit 0
         ;;
 

         update)
               k-update.sh
               exitstatus=$?
               k-output "k.sh:update:$exitstatus" $exitstatus
               exit 0
         ;;
         drun)
               ap=$2
               #kill $(ps -U meteor | grep "[n]ode" | awk '{print $1}' )
               #nohup k run $ap &
               nohup k run $ap >> /opt/application/k-output.log 2>&1&
               exit 0
         ;;
         run)
               ap=$2
               if [ ! -z $ap ] && [ -d /opt/application/$ap ]; then
                      export APP_NAME="$ap"
               else   
                      
                      current_app=$(kalan-var "CURRENT_APP")
                      if [ ! -z $current_app ];then
                        export APP_NAME="$current_app"
                      fi
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
	       k clean
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
               if [  -z $ap ];then
                 echo "$(kalan-var 'CURRENT_APP')"
                 exit 0
               fi
              
               if [ ! -z $ap ] && [ -e /opt/application/$ap/app/.meteor ]; then
                  
                  export APP_NAME="$ap"
                  kalan-var "CURRENT_APP" "$APP_NAME"
                  echo "Using: [$(kalan-var 'CURRENT_APP')]"
                  
                  k-output "k.sh:use:$APP_NAME" "-"
                  
                  exit 0 
               else 
                 
                  echo "Can not use [$ap]. There is no valid project folder at $ap/app "
                 
                  exit 1
               fi
               
           ;;
           maka)
              mk_command=$2
              shift
              pars=$@
              meteor maka $pars
              exitstatus=$?
              k-output "k.sh:maka:$pars:$exitstatus"
              exit 0
           ;;
           meteor)
              m_command=$2
              shift
              pars=$@
              current_app=$(kalan-var "CURRENT_APP")
              export APP_LOCALDB="/home/meteor/meteorlocal/$current_app"
              echo "CURRENT_APP : [$current_app]"
              exitstatus=$?
              k-output "k.sh:meteor:$m_command:$pars:$exitstatus"

              if [ ! -z $current_app ] && [ -d /opt/application/$current_app/app ];then
                 link_or_folder="/opt/application/$current_app/app/.meteor/local"
                 cd /opt/application/$current_app/app
                 echo "$(pwd)"
                 case "$m_command" in
                     update)
                        if [ ! -d "$link_or_folder" ];then   
                             mkdir -p $APP_LOCALDB
                            ln -s $APP_LOCALDB $link_or_folder
                        fi
                        meteor $pars
                        exitstatus=$?
                        k-output "k.sh:meteor:$m_command:$pars:$exitstatus" $exit_status
                       
                        exit 0
                     ;;
                     reset)
                        mkdir -p $APP_LOCALDB
                        if [ -L "$link_or_folder" ];then
                           echo "Local is Link"
                            
                           if [ -d "$link_or_folder" ];then
                             echo "Folder Link OK for: $link_or_folder"
                             #meteor $pars
                            rm -rf $APP_LOCALDB/*
                            mkdir -p $APP_LOCALDB
                            rm -f $link_or_folder
                            ln -s $APP_LOCALDB $link_or_folder
                          else
                             echo "WARNING: Local link broken. Removing and recreating"
                             rm -f $link_or_folder
                            ln -s $APP_LOCALDB $link_or_folder
                           fi
                        else
                            if [  -d "$link_or_folder" ];then
                                 echo "WARINING: previous real folder under .meteor"
                             else
                                echo "Creating new link: No previous link or folder under .meteor"
                                ln -s $APP_LOCALDB $link_or_folder
                           fi
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
                           exitstatus=$?
                           k-output "k.sh:meteor:$m_command:$pars:$exitstatus" $exit_status

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
