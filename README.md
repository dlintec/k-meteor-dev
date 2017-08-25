![alt tag](https://github.com/dlintec/k-meteor-dev/raw/master/utils/dlintec1.png) dlintec k-meteor-dev
==========


A [Dockerfile](http://docs.docker.io/en/latest/reference/builder/) for building a [Meteor](http://www.meteor.com)
development container.

Updated to **Meteor version 1.4.2.3.**
Mantainer: Tadeo Gutierrez

Install & Run
=============

The meteor development environment works on Linux, Mac, and Windows. It can be installed with the following instructions for each platform or manually configured through the commands described in the "Manual configuration" section at the end of this document.


Linux:
--------------------

a) Download and Install Docker for your linux distro: 

- <a href="https://docs.docker.com/engine/installation/linux/" target="_blank">Docker for desktop Linux Installation</a>

b) Copy the following command in a new console and press enter: 

    curl https://raw.githubusercontent.com/dlintec/k-meteor-dev/master/utils/kstart-linux > $HOME/kstart;chmod +x $HOME/kstart
    
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

c) Type ./kstart at the command line to start the container. 

NOTE: Docker beta and latest versions cover some special cases that help running it on different configurations. Take a look at  [Docker for Mac startup guide](https://docs.docker.com/docker-for-mac/)


Windows:
--------------------

a) Install Docker for Windows

-[Docker for Windows Installer](https://download.docker.com/win/stable/InstallDocker.msi)  
The new version of docker (Native windows virtualization for Hyper-V) works on windows 10 Professional. 

If you have an older version of windows you can still run it under VirtualBox with <a href="https://docs.docker.com/toolbox/toolbox_install_windows/" target="_blank">Docker Toolbox for Windows</a> but the development folder for your applications will only work  inside the virtual machine and will not be accesible from your windows host. You can use docker commands to copy and access your application source files inside the k-meteor-dev-local volume.

b) Create a folder for your application code. 

c) Download <a href="https://raw.githubusercontent.com/dlintec/k-meteor-dev/master/utils/k-md-start.bat" target="_blank">k-md-start.bat</a> file and save it in your desktop. The batch file uses "E:\meteor" for the applications code, but you can replace E:\meteor reference at line 100 to point to the folder you created in the previous step.

d) Open the docker application by right clicking the little docker whale icon at the system tray and in "settings/Shared drives". Check the drive where you created the application code folder and click apply.

e) To run the container double click the batch file you downloaded to your desktop. 



Guides: [Docker for Windows startup guide](https://docs.docker.com/docker-for-windows/) / 


Manual configuration
==================================================

IF your Host system can not run Docker in Native mode (windows pre 10 pro or Older Macs). Just copy and paste the following command at the docker console:

    curl https://raw.githubusercontent.com/dlintec/k-meteor-dev/master/utils/kstart-manual > $HOME/kstart;chmod +x $HOME/kstart
    
Just run the kstart script at the docker console to start the container

    ./kstart
    


You can also run the commands manually.

    
a)Run the first 3 commands to create image and volumes (only needed once)

    docker build --tag="k-meteor-dev" git://github.com/dlintec/k-meteor-dev
    docker volume create --name k-meteor-dev-local
    docker volume create --name k-meteor-dev-app

b)Use the next three commands every time to start environment

    docker run -d --name k-meteor-dev --user root -p 80:80 -p 443:443 -v k-meteor-dev-app://opt/application -v  k-meteor-dev-local://home/meteor k-meteor-dev
    docker exec -it --user root k-meteor-dev chown -Rh meteor /opt/application
    docker exec -it --user meteor k-meteor-dev /bin/bash k menu
    
c)Create sftp container to access /opt/application (/server/data/) on sftp  port 2222. The server will receive requests from a user with name "meteor" and password "changeme". You can change user and password in the command as desired. The "1000" is the Linux user ID needed to share the volume.

    docker run -d --name sftp-container -v k-meteor-dev-app:/home/meteor/share -p 2222:22 -d atmoz/sftp meteor:changeme:1000

References
----------

- [Docker](http://docker.io)
- [Meteor](http://meteor.com)
