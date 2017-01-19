k-meteor-dev
==========


A [Dockerfile](http://docs.docker.io/en/latest/reference/builder/) for building a [Meteor](http://www.meteor.com)
development container.

Updated to **Meteor version 1.4.2.3.**

Install & Run
=============

The meteor development environment works on Linux, Mac, and Windows. It can be installed with the following instructions for each platform or manually configured through the commands described in the "Manual configuration" section at the end of this document.


Linux:
--------------------

a) Download and Install Docker for your linux distro: 

- <a href="https://docs.docker.com/engine/installation/linux/" target="_blank">Docker for desktop Linux Installation</a>

b) Copy the following command in a new console and press enter: 

    curl https://raw.githubusercontent.com/dlintec/k-meteor-dev/master/utils/kstart > $HOME/kstart;chmod +x kstart;.$HOME/kstart
    
- This will create a script called "kstart" in your current path and a new folder at /opt/application (you should have user privileges to this folder). All your applications will be created on that folder of your host machine and mounted inside the container under /opt/application.

c) Once Docker is installed in your host machine, open the docker application and "settings/Shared drives" add /opt/application to the shared volumes

d) Type ./kstart at the command line to start the container

Mac:
-----------------

a) Download and Install Docker for Mac:

- <a href="https://download.docker.com/mac/stable/Docker.dmg" target="_blank">Docker for Mac install package</a>

b) Copy the following command in a new console and press enter:

    curl https://raw.githubusercontent.com/dlintec/k-meteor-dev/master/utils/kstart-mac > $HOME/kstart;chmod +x $HOME/kstart;mkdir -p $HOME/Desktop/k-meteor-dev

    
- This will create a script called "kstart" in your home path (/Users/youruser) and a new folder at /Users/youruser/Desktop/k-meteor-dev. This folder will be mounted inside the container under /opt/application.

c) Once Docker is installed in your host machine, open the docker application and in "settings/Shared drives" add /Users/youruser/Desktop/k-meteor-dev

d) Type ./kstart at the command line to start the container. 



Windows:
--------------------

a) Install Docker for Windows

-[Docker for Windows Installer](https://download.docker.com/win/stable/InstallDocker.msi)  
The new version of docker (Native windows virtualization for Hyper-V) works on windows 10 Professional. 

If you have an older version of windows you can still run it under VirtualBox but the development folder for your applications will only work  inside the virtual machine and will not be accesible from your windows host.

b) Create a folder for your application code. 

c) Download <a href="https://raw.githubusercontent.com/dlintec/k-meteor-dev/master/utils/k-md-start.bat" target="_blank">k-md-start.bat</a> file and save it in your desktop. The batch file uses "E:\meteor" for the applications code, but you can replace E:\meteor reference at line 100 to point to the folder you created in the previous step.

d) Open the docker application by right clicking the little docker whale icon at the system tray and in "settings/Shared drives". Check the drive where you created the application code folder and click apply.

e) To run the container double click the batch file you downloaded to your desktop. 



Guides: [Docker for Windows startup guide](https://docs.docker.com/docker-for-windows/) /  [Docker for Mac startup guide](https://docs.docker.com/docker-for-mac/)


Manual configuration
==================================================
    
    
Build image from this repository

    docker build --tag="k-meteor-dev" git://github.com/dlintec/k-meteor-dev
    
If you are running docker for windows, create persistent volume for /home/meteor. (not necessary for docker on linux or mac)

    docker volume create --name k-meteor-dev-local


To run the container use the followind commands:

For Linux and mac

    docker run --rm  --name k-meteor-dev -it -p 3000:3000 -p 3001:3001 -p 3040:3040 -v E:\meteor://opt/application -v  k-meteor-dev-local://home/meteor --entrypoint //bin/bash k-meteor-dev
    
For Windows

    docker run --rm  --name k-meteor-dev -it -p 3000:3000 -p 3001:3001 -p 3040:3040 -v E:\meteor://opt/application -v  k-meteor-dev-local://home/meteor --entrypoint //bin/bash k-meteor-dev
NOTE: Replace E:\meteor with the shared folder that contains your application code
    

Get bash prompt inside container

    docker run --rm  --name k-meteor-dev -it -p 3000:3000 -p 3001:3001 -p 3040:3040 -v E:\meteor:/opt/application -v  k-meteor-dev-local:/home/meteor --entrypoint /bin/bash k-meteor-dev 

Get bash prompt inside existing app

    docker run --rm  --name k-meteor-dev -it -p 3000:3000 -p 3001:3001 -p 3040:3040 -v E:\meteor:/opt/application -v  k-meteor-dev-local:/home/meteor -w /opt/application --entrypoint /bin/bash k-meteor-dev 


References
----------

- [Docker](http://docker.io)
- [Meteor](http://meteor.com)
