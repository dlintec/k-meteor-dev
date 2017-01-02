#!/bin/bash
source $LOCAL_IMAGE_PATH/scripts/k-lib.sh
clear
echo "";echo ""
echo "    Starting $GIT_IMAGE..."
sleep 2

current_app=$(kalan-var "CURRENT_APP")
if [ -z "$current_app" ];then
  current_app="$APP_NAME"
fi
# Syntax
# whiptail --title "<menu title>" --menu "<text to show>" <height> <width> <menu height> [ <tag> <item> ] . . .

just_updated="$(kalan-var 'k_menu_updated')"

menu_status=""
autostart="$(kalan-var 'METEOR_AUTOSTART')"
if [ -z "$autostart" ] ;then
   autostart='0'
   kalan-var "METEOR_AUTOSTART" "$autostart"
fi

if [ "$just_updated" == "1" ] ;then
	kalan-var "k_menu_updated" "_DELETE_"
	menu_status="Just Updated. Menu reloaded"
	echo $menu_status
	autostart=0
fi


if [ "$autostart" == "1" ] ;then
	echo "---------------------------------------------------------"
	echo "   Will start [$current_app] application in 10 seconds"
	echo "---------------------------------------------------------"
	read -t 10 -n 1 -p "       Press 1 to enter Main menu." key_pressed
	if [ -z "$key_pressed" ];then
	   autostart=1
	else
	   autostart=0
	fi
fi
if [ "$autostart" == "1" ] ;then
	k $current_app
else

        exit_menu=0
	while [ "$exit_menu" != 1 ]; do
		current_app=$(kalan-var "CURRENT_APP")
 		colors_normal="$(k-colors normal)"
                echo $colors_normal > /etc/newt/palette
		#NEWT_COLORS="$colors_normal" 
		OPTIONS=$(whiptail --title " Kalan $GIT_IMAGE v1.0.2c " \
		--menu " \n  MAIN MENU                    Container v$APP_VER.\n \n  Selected:[$current_app]\n \n  $menu_status\n \n  Choose an action:\n" \
		 25 60 10 \
		"1" "Select app" \
		"2" "Start app " \
		"3" "Create new app" \
		"4" "Run a command" \
		"5" "Update this containter" \
		"6" "Settings" \
		"7" "Backup" \
		"8" "Restore" \
		"9" "Help" \
		"0" "Exit" 3>&1 1>&2 2>&3)

		exitstatus=$?

		if [ $exitstatus = 0 ]; then
			 #echo "Your selected option:" $OPTIONS
			   case "$OPTIONS" in
       				0) #exit
					exit_menu=1
					break
				;;
       				1) #select app
					
					list_apps="$(k ls)"
					
					selected_app=$(k-list-menu "$list_apps" "Application" "Select default app for all meteor commands" "blue")
					echo "selected:$selected_app"
					read waitvar
					if [ ! -z "$selected_app" ];then
						k use $selected_app
						cd /opt/application/$selected_app/app
						menu_status="App selected"
					fi
					
					
				;;
        			2) #start default app
				        clear
					k $current_app
					read TEST
				;;
      				3) #create app
					new_name=$(whiptail --title "Create New Meteor Application" \
					       --inputbox "\n  Type a NAME for the new app:" 10 60 "" 3>&1 1>&2 2>&3)

					exitstatus=$?
					if [ $exitstatus = 0 ]; then
						if [ ! -z "$new_name" ];then
						        valid_name=$(echo "$new_name" | sed 's/[^a-zA-Z0-9-]//g')
							new_template=$(whiptail --title "Create New Meteor Application" \
							       --inputbox "\n  Type a Git hub repository name to use as template \n  or leave blank to create new app:" 10 60 "" 3>&1 1>&2 2>&3)
							exitstatus2=$?
							if [ $exitstatus = 0 ]; then
								echo "Using template $new_template"
								export APP_TEMPLATE="$new_template"
							   else
								new_template=""
							fi
							clear
							k create $valid_name 
							k use $valid_name
							cd /opt/application/$new_name/app
							echo "---------------------------------------"
							echo "press any key to return to menu" 
							read -n 1 TEST
						fi
					fi
				;;
       				4) #Run command
					clear
					current_app=$(kalan-var "CURRENT_APP")
					cd /opt/application/$current_app/app
				        echo "  Type a command and press ENTER to execute"
					echo "  or type 'exit' to return to menu"
					echo "-------------------------------------------"
					echo "  $(pwd)"
					echo "-------------------------------------------"
					exit_run=0
					while [ "$exit_run" != 1 ]; do
						read -p ">" THE_COMMAND
						if [ ! "$THE_COMMAND" == "exit" ];then
						   eval k $THE_COMMAND
						else
						   exit_run="1"
						fi
					done
				;;
       				5) #Update this containter
					clear
					k update
					kalan-var "k_menu_updated" "1"
					#read -n 1 -p "Update process finished. Press any key to continue." waitvar
					. k-menu
					echo "exiting k-menu level"
					exit 0
				;;
				6) #settings
				    settings_string=$(cat ~/.$GIT_IMAGE.cfg)
					selected_setting=$(k-list-menu "$settings_string" "SETTINGS" "Select config variable to edit" "red")
					if [ ! -z "$selected_setting" ];then
						IFS='=' read -ra value_pairs <<< "$selected_setting"    #Convert string to array
						pair_name="${value_pairs[0]}"
						pair_value="${value_pairs[1]}"
						new_value=$(whiptail --title "Change settings" --inputbox "\n  [$pair_name] Change Value:" 10 60 $pair_value 3>&1 1>&2 2>&3)

						exitstatus=$?
						if [ $exitstatus = 0 ]; then
							if [ ! -z "$new_value" ];then
								menu_status="Setting Changed for [$pair_name]"
								kalan-var "$pair_name" "$new_value"
							fi
						fi
					fi
					#read  TEST

				;;
				7) #backup
					echo "backup"
					new_name=$(whiptail --title "Create Backup" \
					       --inputbox "\n  Type a DESCRIPTION for the Backup:" 10 60 "" 3>&1 1>&2 2>&3)

					exitstatus=$?
					if [ $exitstatus = 0 ]; then
						if [ ! -z "$new_name" ];then
							valid_name=$(echo "$new_name" | sed 's/[^a-zA-Z0-9-]//g')
							k backup $valid_name
						fi
					fi
					read -n 1 -p "press akey to continue..." wait_var
				;;
				8) #restore
					echo "Restore"
					backups_list=$(ls /opt/application/_k-meteor-dev/backups/)
					selected_backup=$(k-list-menu "$backups_list" "SETTINGS" "Select a Backup to restore" "red")
					if [ ! -z "$selected_backup" ];then
					  k restore $selected_backup
					fi
					read -n 1 -p "press akey to continue..." wait_var

				;;
				9) #help
					echo "Help"

				;;
				esac

		else
			echo "You chose cancel."
		fi
		#read test
	done
fi
