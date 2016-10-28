
## Notes how to use Docker 

Here are some notes how to use docker, and how to work with it. 
The main idea of Docker, as far as I understand it, is to create "containers" for commands or programs. 
Here, we have build a Docker container that bundles the wrappers and tools needed to run the immSNP pipeline that we developed during the hackathon. 

## How to run the immuSNP docker image on Mac OS X 

### Download + install the Mac OS X docker app 

       https://docs.docker.com/engine/installation/mac/ 
       
If Docker is up and running, you should see the Docker icon.
![icon](https://github.com/NCBI-Hackathons/Cancer_Epitopes_CSHL/blob/master/doc/images/dockrun.png)

### Clone the immSNP github repo 

To build the image, you will need the **Dockerfile** which is also part of our github repo. 

       git clone https://github.com/NCBI-Hackathons/Cancer_Epitopes_CSHL 

### Build the docker image

`docker build` needs to know where the [Dockerfile](https://github.com/NCBI-Hackathons/Cancer_Epitopes_CSHL/blob/master/Dockerfile) is.

So, you can either build it after going into the corresponding directory:
 
       cd  Cancer_Epitopes_CSHL/
       docker build -t ncbihackathon/immunogenicity . 

Or just define the path to the directory containing the [Dockerfile](https://github.com/NCBI-Hackathons/Cancer_Epitopes_CSHL/blob/master/Dockerfile):

       docker build -t ncbihackathon/immsnp  Cancer_Epitopes_CSHL/

The `-t` option will define the repository name to be applied to the resulting image in case of success [1](https://www.mankier.com/1/docker-build). 

This step will take a couple of minutes.

![dockinstall.png](https://github.com/NCBI-Hackathons/Cancer_Epitopes_CSHL/blob/master/doc/images/dockinstall.png)

### Check if the build was successful 

List all docker images: 

       docker images 

### Run the docker image **i**nteractively 

This starts the docker image and let's you "jump" directly into the container: 

       sudo docker run -i -t ncbihackathon/immsnp    

### List all running docker containers 

       docker ps 

### Stop a container 

      docker stop  ncbihackathon/immsnp


## Additional docker notes...

Additional notes below - here's also the [docker manpage](https://www.mankier.com/1/docker) which has lots of useful tips and trick and comprehensive Docker documentation. 

### Run a docker from dockerhub 

Download the BWA docker, and then you can run BWA (BWA runs in docker container) 

     docker pull alexcoppe/bwa  
     docker run alexcoppe/bwa -help

Well done - you ran alexcoppes BWA docker image. You can run bwa with this command:  

     docker run alexcoppe/bwa -help

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

	 sudo usermod -aG docker devsci7 
	 sudo usermod -aG docker devsci8 
	 sudo usermod -aG docker devsci9 
	 sudo usermod -aG docker devsci10 

sudo docker build -t ncbihackathon/immsnp . "

Execute the command in the folder where the dockerfile is.  

      cd 
      sudo docker build -t ncbihackathon/immsnp .   


###  The re 

	   sudo docker images  


           
