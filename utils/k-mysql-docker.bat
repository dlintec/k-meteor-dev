@Echo Off

REM Docker MySQL - Docker container for MySQL (2017 Tadeo Gutierrez)




:MENU
	SET running_k_mysql=

	FOR /F "delims==" %%K IN ('docker ps -f "name=k-mysql" -a -q') DO @SET running_k_mysql=%%K
	REM echo "   Checking for running container"
	SET container_status=stopped
	SET runStopOption=Start Container
	SET runStopSub=START_CONTAINER
	SET auto_menu=1
	SET status_string=Preparing environment
	REM echo "found:%running_k_mysql%."
	IF "%running_k_mysql%."=="." (
		SET runStopOption=Start Container
		SET runStopSub=START_CONTAINER
		SET status_string=Stopped
     	) else (
		SET runStopOption=Stop Container
		SET runStopSub=STOP_CONTAINER
		SET container_status=running
		SET status_string=RUNNING
	)
	cls
	echo ----------------------------------------------------------
	echo    k-mysql - Docker container for mysql development 
	echo    (2017 Tadeo Gutierrez)
	echo    CONTAINER STATUS:[ %status_string% ]
	echo ----------------------------------------------------------

	ECHO.
	ECHO PRESS a number to select task, or 0 to EXIT.
	ECHO.
	ECHO . 1 - %runStopOption%
	IF "%container_status%"=="running" (
		ECHO . 2 - Open mysql inside container
		ECHO . 3 - Open command line inside container
		ECHO . 4 - Open ROOT command line inside container
	)
	ECHO . 5 - Rebuild k-mysql docker image
	ECHO . 0 - EXIT
	ECHO.
	echo ----------------------------------------------------------
	SET /P M=Type a number then press ENTER:
	IF %M%==1 GOTO:%runStopSub%
	IF "%container_status%"=="running" (
		IF %M%==2 GOTO:EXEC_MENU

		IF %M%==3 GOTO:EXEC_BASH

		IF %M%==4 GOTO:EXEC_BASH_ROOT
	)
	IF %M%==5 GOTO:REBUILD_IMAGE
	IF %M%==0 GOTO EOF
	pause

	
:STOP_CONTAINER
	FOR /F "delims==" %%K IN ('docker ps -f "name=k-mysql" -a -q') DO @SET running_k_mysql=%%K
	IF "%running_k_mysql%."=="." (
	     	FOR /F "delims==" %%G IN ('docker ps -f "name=k-mysql" -a -q') DO @SET hanged_k_mysql=%%G
		IF "%hanged_k_mysql."=="." (
		    echo "   Removing previous stopped container"
		    docker rm k-mysql
		)
	) else (
		echo Stopping k-mysql
	   docker stop k-mysql
	   timeout 5
	   GOTO:MENU
	)
	GOTO:MENU

:START_CONTAINER
	FOR /F "delims==" %%G IN ('docker images -q mysql') DO @SET existing_k_mysql_image=%%G
	IF "%existing_k_mysql_image%."=="." (
  		GOTO:CREATE_IMAGE
	) else (
 		echo "Image OK"
	)
	

	echo ""
	echo "-----------------------------------------------------"
	echo "   Creating Persistent data volume k-mysql-local"
	echo "-----------------------------------------------------"

	docker volume create --name k-mysql-local
	if errorlevel 1 (
	   echo Failure Creating Volume. Reason Given is %errorlevel%

	   pause
	   exit /b %errorlevel%
	)

	echo "-----------------------------------------------------"
	echo "   Starting container for MYSQL "
	echo "-----------------------------------------------------"


	docker run --rm -d --name k-mysql --user root -p 3306:3306 -v  k-mysql-local://var/lib/mysql -e MYSQL_ROOT_PASSWORD=changeme mysql
	if errorlevel 1 (
	   echo Failure Starting container. Reason Given is %errorlevel%

	   pause
	   REM exit /b %errorlevel%
	) else (
	   echo MYSQL running
	   REM goto:sub_execute
	)
	GOTO:MENU

:REBUILD_IMAGE
	docker rmi mysql
	SET auto_menu=0
	echo ""
	echo "-----------------------------------------------------"
	echo "   Rebuilding Docker Image"
	echo "-----------------------------------------------------"
	docker pull mysql:latest
	if errorlevel 1 (
	   echo Failure Creating Docker Container Image. Reason Given is %errorlevel%

	   pause
	   REM exit /b %errorlevel%
	)else(
	echo ""
	echo "-----------------------------------------------------"
	echo "   Image Created"
	echo "-----------------------------------------------------"
	echo ""
	pause
	)
	GOTO:MENU


:CREATE_IMAGE
	echo ""
	echo "-----------------------------------------------------"
	echo "   Creating Docker Image"
	echo "-----------------------------------------------------"
	docker pull mysql:latest
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
	echo "   WELCOME to k-mysql"
	echo "-----------------------------------------------------"
	echo ""
	sleep 2
	
        docker exec -it k-mysql mysql -uroot -p
	)
	
	GOTO:MENU

:EXEC_BASH
	cls
	echo .
	echo "-----------------------------------------------------"
	echo "   WELCOME to k-mysql command line"
	echo "   Type 'exit' and press ENTER to return to menu "

	echo "-----------------------------------------------------"
	echo ""
	docker exec -it --user mysql k-mysql /bin/bash
	GOTO:MENU

:EXEC_BASH_ROOT
	cls
	echo .
	echo "-----------------------------------------------------"
	echo "   WELCOME to k-mysql ROOT command line"
	echo "   Type 'exit' and press ENTER to return to menu "

	echo "-----------------------------------------------------"
	echo ""
	docker exec -it --user root k-mysql /bin/bash
	GOTO:MENU
:EXEC_MENU
	docker exec -it k-mysql mysql -uroot -p
	GOTO:MENU

:EOF
