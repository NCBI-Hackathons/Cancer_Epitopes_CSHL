
## Notes how to use Docker 

Here are some notes how to use docker, and how to work with it. 
The main idea of Docker, as far as I understand it, is to create "containers" for commands or programs. 
for example, you can create a Docker container for BWA ( where BWA plus dependencies is installed).
This enables you to run BWA ( or see the BWA help page ) with this command:  

## How to run the immunogenicity docker image on Mac OS X 

1) Download + install the Mac OS X docker app 

       https://docs.docker.com/engine/installation/mac/ 

2) Clone this github repo 
To build our image, we need the **Dockerfile** out of our github repo 

       git clone https://github.com/NCBI-Hackathons/Cancer_Epitopes_CSHL 

3) Run **docker build** 
Note: You have to be in the same directory where our Cancer_Epitopes_CSHL 
[Dockerfile](https://github.com/NCBI-Hackathons/Cancer_Epitopes_CSHL/blob/master/Dockerfile) is. 
 
       cd  Cancer_Epitopes_CSHL/
       docker build -t ncbihackathon/immunogenicity . 

Another way to build the image is to hand over a path to the directory where the **Dockerfile** is :

       docker build -t ncbihackathon/immunogenicity    Cancer_Epitopes_CSHL/


5) Check if the build was successful 
List all docker images: 

       docker images 


4) Run the docker image **i**nteractively 
This starts the docker image and let's you "jump" directly into the container: 

       sudo docker run -i -t ncbihackathon/immsnp    

5) List all running docker containers 

       docker ps 

6) Stop a container 

      docker stop  ncbihackathon/immsnp


## Additional docker notes...
Additional notes below - here's also the [docker manpage](https://www.mankier.com/1/docker) which has some useful info. 
## Run a docker from dockerhub 
Download the BWA docker, and then you can run BWA (BWA runs in docker container) 

     sudo docker pull alexcoppe/bwa  
     sudo docker run alexcoppe/bwa -help

Well done - you ran alexcoppes BWA docker image. You can run bwa with this command:  

     sudo docker run alexcoppe/bwa -help

### How to start with Docker... 
At first, create a file called **Dockerfile** and add this : 

	cat Dockerfile 
	FROM continuumio/miniconda
	MAINTAINER Michael Heuer <heuermh@acm.org>

You find various example docker files on www.dockerhub.com, for specific use cases. For example,
search for a docker-image for **VEP** or **BWA**.

### Create / build your docker image
We build a docker image from your Docker file. 

       sudo docker build -t ncbihackathon/immsnp .

       docker pull tweep/immunogenicity


## Now start docker image :  


       sudo docker build -t ncbihackathon/immsnp . 

       sudo docker run -i -t ncbihackathon/immsnp    

       sudo docker run ncbihackathon/immsnp -h 


## I sometimes see this Error msg: 

     docker build -t bla Dockerfile
     FATA[0000] The Dockerfile (Dockerfile) must be within the build context (Dockerfile)

     docker info 
     FATA[0000] Get http:///var/run/docker.sock/v1.18/info: dial unix /var/run/docker.sock: permission denied. 
     Are you trying to connect to a TLS-enabled daemon

### Solution  

	 sudo usermod -aG docker devsci7 
	 sudo usermod -aG docker devsci8 
	 sudo usermod -aG docker devsci9 
	 sudo usermod -aG docker devsci10

## Build a Docker image  
- Write a file called Dockerfile 
  (you seei examples on dockerhub) 
- then run docker build in the dircetory where the Dockefile is. 

sudo docker build -t ncbihackathon/immsnp . "

Execute the command in the folder where the dockerfile is.  

      cd 
      sudo docker build -t ncbihackathon/immsnp .   


###  The re 

	   sudo docker images  


           
