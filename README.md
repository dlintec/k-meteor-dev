meteor-dev
==========




A [Dockerfile](http://docs.docker.io/en/latest/reference/builder/) for building a [Meteor](http://www.meteor.com)
development container.

Updated to **Meteor version 1.4.2.3.**


Configure development folder and environment
==================================================

1 Prerequisites
------------------
- **Docker** for Windows or Mac. 

**Install Prerequisites:**

**Docker installers:** 

-[Docker for Windows Installer](https://download.docker.com/win/stable/InstallDocker.msi)  
-[Docker for Mac install package](https://download.docker.com/mac/stable/Docker.dmg)

Guides: [Docker for Windows startup guide](https://docs.docker.com/docker-for-windows/) /  [Docker for Mac startup guide](https://docs.docker.com/docker-for-mac/)


Build image from this repository

    docker build --tag="meteor-dev" git://github.com/dlintec/meteor-dev
    
If you are running docker for windows, create persistent volume for /home/meteor. (not necessary for docker on linux or mac)

    docker volume create --name meteor-dev-local

Add an alias tu call just "meteor-dev" instead of full docker command

Replace "E:/meteor" with the path for your develompment folder in your host machine. This folder will be visible to container mounted as "/opt/application". Each folder inside will be treated as a project and should contain an "/app" folder in which the meteor application will be run by meteor.

To run the container use the followind command:

For Linux

    docker run --rm  --name c-meteor-dev -it -p 3000:3000 -p 3001:3001 -p 3040:3040 -v E:\meteor://opt/application -v  meteor-dev-local://home/meteor --entrypoint //bin/bash meteor-dev
    
For Windows

    docker run --rm  --name c-meteor-dev -it -p 3000:3000 -p 3001:3001 -p 3040:3040 -v E:\meteor://opt/application -v  meteor-dev-local://home/meteor --entrypoint //bin/bash meteor-dev


You will get a bash command lines inside the container. To start de default run

    k meteor
    
this will start the default app. If there is no "default" folder inside the mounted
Note:When interrupted using `ctrl-C`, meteor will restart, so use the `docker stop` command to shutdown the server.


Get bash prompt inside container

    docker run --rm  --name c-meteor-dev -it -p 3000:3000 -p 3001:3001 -p 3040:3040 -v E:\meteor:/opt/application -v  meteor-dev-local:/home/meteor --entrypoint /bin/bash meteor-dev 

Get bash prompt inside existing app

    docker run --rm  --name c-meteor-dev -it -p 3000:3000 -p 3001:3001 -p 3040:3040 -v E:\meteor:/opt/application -v  meteor-dev-local:/home/meteor -w /opt/application --entrypoint /bin/bash meteor-dev 


Run Meteor using a prebuilt docker container
--------------------------------------------

Download the `golden/meteor-dev` pre-built container from [Docker Hub](http://hub.docker.com).

    docker pull golden/meteor-dev


Run meteor using the application source code in the `/path/to/meteor/app` directory.

    docker run -it --rm -p 3000:3000 -v /path/to/meteor/app:/opt/application golden/meteor-dev


The application is now accessible on port 3000 of the localhost (`http://localhost:3000`).



Roll your own image
-------------------

Build your own image (`meteor-dev`) from the github repo.

    docker build --tag="meteor-dev" git://github.com/golden-garage/meteor-dev
    

Run meteor using the newly built image (`meteor-dev`).

    docker run -it --rm -p 3000:3000 -v /path/to/meteor/app:/opt/application -w /opt/application meteor-dev



Using the `meteor-dev` container
--------------------------------

When changes are made to the source code of the meteor application in the local directory (`/path/to/meteor/app/`), the
`meteor-dev` container automatically updates the running application. The application changes are seen immediately in
the browser, just as if meteor were installed locally.

You can check on the status of the meteor container by using the `docker ps` command.

The meteor server will attempt to restart when interrupted usng `ctrl-C`, so use `docker stop` to shutdown the server.



Cleanup
-------

The meteor image is stateless and can be automatically removed when stopped by using the `--rm` docker command switch.

Each time you use `docker run` to start Meteor without the `--rm` switch, a new container with a fresh install of
meteor is created. Each of these containers consumes disk space.

You can clean up stopped containers by using the `docker rm` command.



References
----------

- [Docker](http://docker.io)
- [Meteor](http://meteor.com)
