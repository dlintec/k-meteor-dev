@Echo Off

REM meteor-dev - Docker container for meteor development (2017 Tadeo Gutierrez)




:MENU
	SET running_k_meteor_dev=

	FOR /F "delims==" %%K IN ('docker ps -f "name=k-meteor-dev" -a -q') DO @SET running_k_meteor_dev=%%K
	REM echo "   Checking for running container"
	SET container_status=stopped
	SET runStopOption=Start Container
	SET runStopSub=START_CONTAINER
	SET auto_menu=1
	REM echo "found:%running_k_meteor_dev%."
	IF "%running_k_meteor_dev%."=="." (
		SET runStopOption=Start Container
		SET runStopSub=START_CONTAINER
     	) else (
		SET runStopOption=Stop Container
		SET runStopSub=STOP_CONTAINER
		SET container_status=running
	)
	cls
	echo ----------------------------------------------------------
	echo    K-METEOR-DEV - Docker container for meteor development 
	echo    (2017 Tadeo Gutierrez)
	echo    Preparing environment 
	echo ----------------------------------------------------------

	ECHO.
	ECHO PRESS a number to select task, or 0 to EXIT.
	ECHO.
	ECHO . 1 - %runStopOption%
	IF "%container_status%"=="running" (
		ECHO . 2 - Open menu inside container
		ECHO . 3 - Open command line inside container
	)
	ECHO . 4 - Rebuild k-meteor-dev docker image
	ECHO . 0 - EXIT
	ECHO.
	echo ----------------------------------------------------------
	SET /P M=Type a number then press ENTER:
	IF %M%==1 GOTO:%runStopSub%
	IF "%container_status%"=="running" (
		IF %M%==2 GOTO:EXEC_MENU

		IF %M%==3 GOTO:EXEC_BASH
	)
	IF %M%==4 GOTO:REBUILD_IMAGE
	IF %M%==0 GOTO EOF
	pause

	
:STOP_CONTAINER
	FOR /F "delims==" %%K IN ('docker ps -f "name=k-meteor-dev" -a -q') DO @SET running_k_meteor_dev=%%K
	IF "%running_k_meteor_dev%."=="." (
	     	FOR /F "delims==" %%G IN ('docker ps -f "name=k-meteor-dev" -a -q') DO @SET hanged_k_meteor_dev=%%G
		IF "%hanged_k_meteor_dev."=="." (
		    echo "   Removing previous stopped container"
		    docker rm k-meteor-dev
		)
	) else (
		echo Stopping k-meteor-dev
	   docker stop k-meteor-dev
	)
	GOTO:MENU

:START_CONTAINER
	FOR /F "delims==" %%G IN ('docker images -q k-meteor-dev') DO @SET existing_k_meteor_dev_image=%%G
	IF "%existing_k_meteor_dev_image%."=="." (
  		GOTO:CREATE_IMAGE
	) else (
 		echo "Image OK"
	)
	

	echo ""
	echo "-----------------------------------------------------"
	echo "   Creating Persistent data volume k-meteor-dev-local"
	echo "-----------------------------------------------------"

	docker volume create --name k-meteor-dev-local
	if errorlevel 1 (
	   echo Failure Creating Volume. Reason Given is %errorlevel%

	   pause
	   exit /b %errorlevel%
	)

	echo "-----------------------------------------------------"
	echo "   Starting container of NGINX (root)"
	echo "-----------------------------------------------------"


	docker run --rm -d --name k-meteor-dev --user root -p 80:80 -p 443:443 -v E:\meteor://opt/application -v  k-meteor-dev-local://home/meteor k-meteor-dev
	if errorlevel 1 (
	   echo Failure Starting container. Reason Given is %errorlevel%

	   pause
	   REM exit /b %errorlevel%
	) else (
	   goto:sub_execute
	)
	GOTO:MENU

:REBUILD_IMAGE
	docker rmi k-meteor-dev
	SET auto_menu=0
	GOTO:CREATE_IMAGE

:CREATE_IMAGE
	echo ""
	echo "-----------------------------------------------------"
	echo "   Creating Docker Image"
	echo "-----------------------------------------------------"
	docker build --tag="k-meteor-dev" git://github.com/dlintec/k-meteor-dev
	if errorlevel 1 (
	   echo Failure Creating Docker Container Image. Reason Given is %errorlevel%

	   pause
	   REM exit /b %errorlevel%
	)
	echo ""
	echo "-----------------------------------------------------"
	echo "   Image Created"
	echo "-----------------------------------------------------"
	echo ""

:sub_execute
	IF auto_menu==1 (
	echo ""
	echo "-----------------------------------------------------"
	echo "   WELCOME to k-metoer-dev"
	echo "-----------------------------------------------------"
	echo ""
	sleep 2
	docker exec -it --user meteor k-meteor-dev /bin/bash k menu
	)
	
	GOTO:MENU

:EXEC_BASH
	cls
	echo .
	echo "-----------------------------------------------------"
	echo "   WELCOME to k-metoer-dev command line"
	echo "   Type 'exit' and press ENTER to return to menu "

	echo "-----------------------------------------------------"
	echo ""
	docker exec -it --user meteor k-meteor-dev /bin/bash
	GOTO:MENU

:EXEC_MENU
	docker exec -it --user meteor k-meteor-dev /bin/bash k menu 
	GOTO:MENU

:EOF
