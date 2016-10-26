
## Notes how to use Docker
Here are some notes how to use docker, and how to work with it. 
The main idea of Docker, as far as I understand it, is to create "containers" for commands or programs. 
for example, you can create a Docker container for BWA ( where BWA plus dependencies is installed).
This enables you to run BWA ( or see the BWA help page ) with this command: 

## Run a docker from dockerhub 
Download the BWA docker, and then you can run BWA (BWA runs in docker container) 

     sudo docker pull alexcoppe/bwa  
     sudo docker run alexcoppe/bwa -help

### How to start
Create a file called **Dockerfile** and add this : 

	cat Dockerfile 
	FROM continuumio/miniconda
	MAINTAINER Michael Heuer <heuermh@acm.org>

Then, build your Docker image with this command : 

       sudo docker build -t ncbihackathon/immsnp .




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

	   sudo docker run -i -t ncbihackathon/immsnp   

	   sudo docker run ncbihackathon/immsnp -h 


           
