#!/bin/bash   
   function addreplacevalue {
     usesudo="$4"
     archivo="$3"
     nuevacad="$2"
     buscar="$1"
     temporal="$archivo.tmp.kalan"
     listalineas=""
     if [ ! -e $archivo ];then
       echo "CONTAINER_NAME=$GIT_IMAGE" >> $archivo
     fi
     linefound=0       
     listalineas=$(cat $archivo)
     if [[ !  -z  $listalineas  ]];then
       #echo "buscando lineas existentes con:"
       #echo "$nuevacad"
       #$usesudo >$temporal

       while read -r linea; do
       if [[ $linea == *"$buscar"* ]];then
         #echo "... $linea ..."
         if [ ! "$nuevacad" == "_DELETE_" ];then
            ## just add new line if value is NOT _DELETE_
            echo $nuevacad >> $temporal
         fi
         linefound=1
       else
         echo $linea >> $temporal

       fi
       done <<< "$listalineas"
       
       cat $temporal > $archivo
       rm -rf $temporal
     fi
     if [ $linefound == 0 ];then
       echo "Adding new value to file: $nuevacad"
       echo $nuevacad>>$archivo
     fi
   }

   function kalan-var {
      new_value="$2"
      if [[ -z "$new_value" ]];then
         sed "y/ ,/\n\n/;/^$1/P;D" <~/.$GIT_IMAGE.cfg | awk -F= '{print $NF}'
      else
         if [ "$new_value" == "_DELETE_" ];then
            addreplacevalue "$1" "$new_value" ~/.$GIT_IMAGE.cfg
         else
            addreplacevalue "$1" "$1=$new_value" ~/.$GIT_IMAGE.cfg
         fi
      fi

   }
function k-colors {
	colors_normal=(
		root=white,lightgrey
		border=red,red
		checkbox=,black
		entry=,black
		label=black,
		actlistbox=,black
		helpline=,black
		roottext=,black
		emptyscale=black
		disabledentry=black,
		checkbox=,black
		entry=,black
		label=black,
		actlistbox=,black
		helpline=,black
		roottext=,black
		emptyscale=black
		disabledentry=black,
	)
        palette_name="$1"
	if [ -z "$palette_name" ];then
	  palete_name="normal"
	fi
	colors_palette=( "${colors_normal[@]}" )
	case "$palete_name" in
		red) #exit

			colors_red=(
			   window=,red
			   border=white,red
			   textbox=white,red
			   button=black,white
			)

			colors_palette="${colors_normal[@]} ${colors_red[@]}" 		
			break
		;;
		blue) #exit

			colors_blue=(
			   window=,blue
			   border=blue,blue
			   textbox=,black
			   button=black,white
			)

			colors_palette="${colors_normal[@]} ${colors_blue[@]}" 		
			break
		;;
	esac

	for var in "${colors_palette[@]}"
	do
	  echo "${var}"
	done


}
   function k-list-menu {
         title="$2"
         option_list="$1"
         param="$3"
	 color_palette="$4"
	 if [ -z "$color_palette" ];then
	 	color_palette="normal"
	fi
         total_elements=0
         if [ -z "$title" ];then
            title="Option"
         fi
        if [ -z "$param" ];then
            param="Choose $title"
         fi
         elementarray[0]='none'
         menu_elements=""
         for line in $option_list ; do
             total_elements=$((total_elements+1))
             #echo "Checking $line"
             if [ ! -z "$line" ];then
                menu_elements="$menu_elements '$total_elements' '$line'"
                elementarray[$total_elements]=$line
             fi
         done
         height=$((total_elements+12))
         total_displayed=$(($total_elements<10?$total_elements:10))
         display_msg="[$total_displayed of $total_elements displayed] Use Up/Down arrows to scroll"
         width=60
         title_string="--title '$title' --menu '\n  $param\n \n $display_msg'"
         #echo $command_string
         menu_selection=$(eval NEWT_COLORS="$(k-colors $color_palette)" whiptail $title_string $height $width $total_elements $menu_elements 3>&1 1>&2 2>&3)

         exitstatus=$?

         if [ $exitstatus = 0 ]; then
            selection=${elementarray[$menu_selection]}
            echo "$selection" 
         fi
   }          
   
