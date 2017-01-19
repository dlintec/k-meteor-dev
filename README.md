k-meteor-dev
==========




A [Dockerfile](http://docs.docker.io/en/latest/reference/builder/) for building a [Meteor](http://www.meteor.com)
development container.

Updated to **Meteor version 1.4.2.3.**

1 Install
------------------

**Linux and Mac:** 

a)Install Docker for your platform: 

[Docker for Mac install package](https://download.docker.com/mac/stable/Docker.dmg)

[Docker for desktop Linux Installation](https://docs.docker.com/engine/installation/linux/)

Once Docker is installed in your host machine, open the docker application and "settings/Shared drives" add /opt/application

b)Copy the following command in a new console: 
for Linux:

    curl https://raw.githubusercontent.com/dlintec/k-meteor-dev/master/utils/kstart > kstart;chmod +x kstart;. kstart
    
    
    
c)Press Enter/Return.
This will create a script called "kstart" in your current path. This script will create the OS docker image and install al the environment. Check for error messages.


**Windows:**
a)Install Docker for Windows

-[Docker for Windows Installer](https://download.docker.com/win/stable/InstallDocker.msi)  
The new version of docker (Native windows virtualization for Hyper-V) works on windows 10 Professional. 




**Windows:**
If you have an older version of windows you can still run it under VirtualBox but the development folder for your applications will only work  inside the virtual machine and will not be accesible from your windows host.


Guides: [Docker for Windows startup guide](https://docs.docker.com/docker-for-windows/) /  [Docker for Mac startup guide](https://docs.docker.com/docker-for-mac/)


Configure development folder and environment
==================================================

    curl https://raw.githubusercontent.com/dlintec/k-meteor-dev/master/utils/kstart > kstart;chmod +x kstart;. kstart
    
    
Build image from this repository

    docker build --tag="k-meteor-dev" git://github.com/dlintec/k-meteor-dev
    
If you are running docker for windows, create persistent volume for /home/meteor. (not necessary for docker on linux or mac)

    docker volume create --name k-meteor-dev-local

Add an alias tu call just "meteor-dev" instead of full docker command

Replace "E:/meteor" with the path for your develompment folder in your host machine. This folder will be visible to container mounted as "/opt/application". Each folder inside will be treated as a project and should contain an "/app" folder in which the meteor application will be run by meteor.

To run the container use the followind command:

For Linux

    docker run --rm  --name k-meteor-dev -it -p 3000:3000 -p 3001:3001 -p 3040:3040 -v E:\meteor://opt/application -v  k-meteor-dev-local://home/meteor --entrypoint //bin/bash k-meteor-dev
    
For Windows

    docker run --rm  --name k-meteor-dev -it -p 3000:3000 -p 3001:3001 -p 3040:3040 -v E:\meteor://opt/application -v  k-meteor-dev-local://home/meteor --entrypoint //bin/bash k-meteor-dev


You will get a bash command lines inside the container. To start de default run

    k meteor
    
this will start the default app. If there is no "default" folder inside the mounted
Note:When interrupted using `ctrl-C`, meteor will restart, so use the `docker stop` command to shutdown the server.


Get bash prompt inside container

    docker run --rm  --name k-meteor-dev -it -p 3000:3000 -p 3001:3001 -p 3040:3040 -v E:\meteor:/opt/application -v  k-meteor-dev-local:/home/meteor --entrypoint /bin/bash k-meteor-dev 

Get bash prompt inside existing app

    docker run --rm  --name k-meteor-dev -it -p 3000:3000 -p 3001:3001 -p 3040:3040 -v E:\meteor:/opt/application -v  k-meteor-dev-local:/home/meteor -w /opt/application --entrypoint /bin/bash k-meteor-dev 


References
----------

- [Docker](http://docker.io)
- [Meteor](http://meteor.com)
