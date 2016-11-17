How to run the immSNP docker image 
====================================

Here are some notes how to use docker, and how to work with it. 
The main idea of Docker is to create "containers" that contain the environment to run certain commands or programs. 
Here, we have build a Docker container that bundles the wrappers and tools needed to run the immSNP pipeline.

1. [Install Docker](#inst)
2. [Download Dockerfile (and other scripts)](#git)
3. [Build the Docker container](#build)
4. [Use the Docker container](#dock)
5. [Run the immSNP pipeline](#run)
6. [Stop the Docker container](#stop)

* __[Modifying the immSNP pipeline](#mod)__
* __[Additional notes about Docker usage](#add)__

---------------------------------------------------

## 1. Prerequisite: download + install the Mac OS X [or whatever is appropriate for your set-up] Docker app  <a name="inst"></a>

       https://docs.docker.com/engine/installation/mac/ 
       
If Docker is up and running, you should see the Docker icon:

![icon](https://github.com/NCBI-Hackathons/Cancer_Epitopes_CSHL/blob/master/doc/images/dockrun.png)

## 2. Clone the immSNP github repo <a name="git"></a>

To build the image, you will need the **Dockerfile** which is also part of our github repo. 

       git clone https://github.com/NCBI-Hackathons/Cancer_Epitopes_CSHL 

## 3. Build the Docker image <a name="build"></a>

To create the environment which will allow the immSNP pipeline to basically run out-of-the-box, use `docker build`.
`docker build` needs to know where the [Dockerfile](https://github.com/NCBI-Hackathons/Cancer_Epitopes_CSHL/blob/master/Dockerfile) is.

So, you can either build it after going into the corresponding directory:
 
       cd  Cancer_Epitopes_CSHL/
       docker build -t ncbihackathon/immsnp . 

Or just define the path to the directory containing the [Dockerfile](https://github.com/NCBI-Hackathons/Cancer_Epitopes_CSHL/blob/master/Dockerfile):

       docker build -t ncbihackathon/immsnp  Cancer_Epitopes_CSHL/

The `-t` option will define the repository name to be applied to the resulting image in case of success [1](https://www.mankier.com/1/docker-build). 

This step will take a couple of minutes, you should see all kinds of messages in the Terminal:

![dockinstall.png](https://github.com/NCBI-Hackathons/Cancer_Epitopes_CSHL/blob/master/doc/images/dockinstall.png)

### Check if the build was successful 

List all docker images: 

       docker images 
       
You should see something like that:
![dockimage](https://github.com/NCBI-Hackathons/Cancer_Epitopes_CSHL/blob/master/doc/images/dockresult.png)

## 4. Run the Docker image interactively <a name="dock"></a>

The following command starts the Docker image and lets you "jump" directly into the container: 

       docker run -i -t ncbihackathon/immsnp    # -t again is used to refer to the specific docker container for immSNP

You're automatically thrown into the docker environment.
Check this, e.g., via `pwd`:

	$ pwd
	/home/linuxbrew
	
## 5. Run the immSNP pipeline <a name="run"></a>

Within the docker image, type:

       cd /home/linuxbrew/
       ./Cancer_Epitopes_CSHL/bin/test.sh Cancer_Epitopes_CSHL/data/test_data/input.vcf

You should see some messages that indicate that the pipeline is running.
Most likely it will look something like that:
![testresult](https://github.com/NCBI-Hackathons/Cancer_Epitopes_CSHL/blob/master/doc/images/testresult.png)

## 6. Stop the container <a name="stop"></a>

Most docker containers can be stopped so:

	exit
      	docker stop <IMAGE-TAG>

In our case, the docker image will stop as soon as you type `exit`, so need for the `docker stop` command.

__NOTE: NO CHANGES WILL BE KEPT AFTER YOU EXIT THE DOCKER CONTAINER!__

---------------------------

## Working on the immSNP pipeline <a name="mod"></a>

If you want to modify the immSNP pipeline while being inside the docker image, simply modify the files in the git repo, commit and __push__ changes.
Then, exit the container (type `exit` or see below) and re-start the container.
Make sure to pull the updated git repo into the container since the image we built will still have the repo in the state that it was in when we built it.

If you wanted to add permanent changes to the immSNP Docker container (e.g., installing a new program), these would have to be defined within the Dockerfile.

------------------------------------------------------------------------------

## Additional docker notes... <a name="add"></a>

Additional notes below - here's also the [docker manpage](https://www.mankier.com/1/docker) which has lots of useful tips and trick and comprehensive Docker documentation. 

### Run a docker from dockerhub 

Download the BWA docker, and then you can run BWA (BWA runs in docker container) 

     docker pull alexcoppe/bwa  
     docker run alexcoppe/bwa -help

Well done - you ran alexcoppes BWA docker image. You can run bwa with this command:  

     docker run alexcoppe/bwa -help

### List all running docker containers 

Open a different terminal session, then type:

       docker ps 


### How to make your own Docker instance 

At first, create a file called **Dockerfile** and add this : 

	cat Dockerfile 
	FROM continuumio/miniconda
	MAINTAINER Michael Heuer <heuermh@acm.org>

You find various example docker files on www.dockerhub.com, for specific use cases.
For example, search for a docker-image for **VEP** or **BWA**.

### I sometimes see this Error msg: 

     docker build -t bla Dockerfile
     FATA[0000] The Dockerfile (Dockerfile) must be within the build context (Dockerfile)

     docker info 
     FATA[0000] Get http:///var/run/docker.sock/v1.18/info: dial unix /var/run/docker.sock: permission denied. 
     Are you trying to connect to a TLS-enabled daemon

#### Solution  

	 usermod -aG docker devsci7
           
