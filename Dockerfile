FROM continuumio/miniconda 

MAINTAINER Michael Heuer <heuermh@acm.org>


USER root
RUN apt-get update && apt-get install -y \
curl g++ gawk git m4 make patch ruby tcl  libarchive-zip-perl  libdbd-mysql-perl  libjson-perl cmake

RUN apt-get install -y build-essential default-jdk gfortran texinfo unzip samtools \
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
RUN pip install docopt numpy pyomo pysam matplotlib tables  pandas  future 

# FRED 2  
RUN apt-get update && apt-get install -y vim software-properties-common \
&& apt-get update && apt-get install -y \
    gcc-4.9 g++-4.9 coinor-cbc zlib1g-dev libbz2-dev \
&& update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.9 \
&& rm -rf /var/lib/apt/lists/* && apt-get clean && apt-get purge 

#HLA Typing 
#OptiType dependecies 
RUN curl -O https://support.hdfgroup.org/ftp/HDF5/current/bin/linux-centos7-x86_64-gcc485/hdf5-1.8.17-linux-centos7-x86_64-gcc485-shared.tar.gz \
    && tar -xvf hdf5-1.8.17-linux-centos7-x86_64-gcc485-shared.tar.gz \
    && mv hdf5-1.8.17-linux-centos7-x86_64-gcc485-shared/bin/* /usr/local/bin/ \
    && mv hdf5-1.8.17-linux-centos7-x86_64-gcc485-shared/lib/* /usr/local/lib/ \
    && mv hdf5-1.8.17-linux-centos7-x86_64-gcc485-shared/include/* /usr/local/include/ \
    && mv hdf5-1.8.17-linux-centos7-x86_64-gcc485-shared/share/* /usr/local/share/ \
    && rm -rf hdf5-1.8.17-linux-centos7-x86_64-gcc485-shared/ \
    && rm -f hdf5-1.8.17-linux-centos7-x86_64-gcc485-shared.tar.gz 

ENV LD_LIBRARY_PATH /usr/local/lib:$LD_LIBRARY_PATH 
ENV HDF5_DIR /usr/local/  

RUN git clone https://github.com/FRED-2/OptiType.git \
    && sed -i -e '1i#!/usr/bin/env python\' OptiType/OptiTypePipeline.py \
    && mv OptiType/ /usr/local/bin/ \
    && chmod 777 /usr/local/bin/OptiType/OptiTypePipeline.py \
    && echo "[mapping]\n\
razers3=/usr/local/bin/razers3 \n\
threads=1 \n\
\n\
[ilp]\n\
solver=cbc \n\
threads=1 \n\
\n\
[behavior]\n\
deletebam=true \n\
unpaired_weight=0 \n\
use_discordant=false\n" >> /usr/local/bin/OptiType/config.ini

#installing razers3 
RUN git clone https://github.com/seqan/seqan.git seqan-src \
    && cd seqan-src \
    && cmake -DCMAKE_BUILD_TYPE=Release \
    && make razers3 \
    && cp bin/razers3 /usr/local/bin \
    && cd .. \
    && rm -rf seqan-src

RUN conda create --name python3 python=3.5 
RUN ["/bin/bash","-c","source activate python3;  pip install numpy pandas pvacseq docopt && source deactivate"] 

ENV PATH /home/linuxbrew/Cancer_Epitopes_CSHL/src:/usr/local/bin/OptiType/:$PATH


USER linuxbrew
RUN cd /home/linuxbrew && git clone https://github.com/NCBI-Hackathons/Cancer_Epitopes_CSHL.git
ENTRYPOINT [ "/usr/bin/tini", "--" ] 
CMD [ "/bin/bash" ] 

