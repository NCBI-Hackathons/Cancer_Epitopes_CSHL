FROM continuumio/miniconda 

MAINTAINER Michael Heuer <heuermh@acm.org>


USER root
RUN apt-get update && apt-get install -y \
curl g++ gawk git m4 make patch ruby tcl  libarchive-zip-perl  libdbd-mysql-perl  libjson-perl 

RUN apt-get install -y build-essential default-jdk gfortran texinfo unzip \
	libbz2-dev libcurl4-openssl-dev libexpat-dev libncurses-dev zlib1g-dev libmysqlclient-dev

RUN useradd -m -s /bin/bash linuxbrew
RUN echo 'linuxbrew ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers

USER linuxbrew
WORKDIR /home/linuxbrew
ENV PATH /home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH
ENV SHELL /bin/bash
RUN yes |ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
RUN brew doctor || true

RUN brew tap homebrew/science \
  && brew install htslib \
  && brew tap chapmanb/homebrew-cbl \
  && brew install vep  

USER root
RUN pip install git+https://github.com/FRED-2/Fred2
RUN pip install docopt

RUN conda create --name python3 python=3.5 
RUN ["/bin/bash","-c","source activate python3;  pip install numpy pandas pvacseq docopt && source deactivate"]

ENTRYPOINT [ "/usr/bin/tini", "--" ] 
CMD [ "/bin/bash" ] 



