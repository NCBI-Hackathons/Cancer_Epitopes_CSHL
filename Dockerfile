FROM continuumio/miniconda 

MAINTAINER Jan Vogel <jan.vogelde@gmail.com>


USER root
RUN apt-get update && apt-get install -y \
curl g++ gawk git m4 make patch ruby tcl bzip2 libarchive-zip-perl  libdbd-mysql-perl  libjson-perl cmake libncurses5-dev

RUN apt-get install -y build-essential default-jdk gfortran texinfo unzip \
	libbz2-dev libcurl4-openssl-dev libexpat-dev libncurses-dev zlib1g-dev libmysqlclient-dev

RUN conda install variant-effect-predictor -c bioconda
WORKDIR /root
RUN mkdir -p .vep/Plugins
WORKDIR /root/.vep/Plugins
RUN wget https://raw.githubusercontent.com/griffithlab/pVAC-Seq/master/pvacseq/VEP_plugins/Wildtype.pm
RUN wget https://raw.githubusercontent.com/Ensembl/VEP_plugins/release/86/Downstream.pm

USER root
RUN pip install git+https://github.com/FRED-2/Fred2
RUN pip install docopt numpy pyomo pysam matplotlib tables  pandas  future 

# FROM https://hub.docker.com/r/ljishen/samtools/~/dockerfile/
WORKDIR /root
RUN wget -O "samtools.tar.bz2" https://github.com/samtools/samtools/releases/download/1.3.1/samtools-1.3.1.tar.bz2 \ 
    && tar xjf samtools.tar.bz2 && mv samtools-* samtools

WORKDIR /root/samtools
RUN ./configure && make all all-htslib && make install install-htslib

# FRED 2  
RUN apt-get update && apt-get install -y vim software-properties-common \
&& apt-get update && apt-get install -y \
    gcc-4.9 g++-4.9 coinor-cbc \
&& update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.9 \
&& rm -rf /var/lib/apt/lists/* && apt-get clean && apt-get purge 

#HLA Typing 
#OptiType dependecies 
WORKDIR /root
RUN wget https://support.hdfgroup.org/ftp/HDF5/current18/bin/linux-centos7-x86_64-gcc485/hdf5-1.8.18-linux-centos7-x86_64-gcc485-shared.tar.gz
RUN tar -xvf hdf5-*-linux-centos7-x86_64-gcc485-shared.tar.gz \
    && mv hdf5-*-linux-centos7-x86_64-gcc485-shared/bin/* /usr/local/bin/ \
    && mv hdf5-*-linux-centos7-x86_64-gcc485-shared/lib/* /usr/local/lib/ \
    && mv hdf5-*-linux-centos7-x86_64-gcc485-shared/include/* /usr/local/include/ \
    && mv hdf5-*-linux-centos7-x86_64-gcc485-shared/share/* /usr/local/share/ \
    && rm -rf hdf5-*-linux-centos7-x86_64-gcc485-shared/ \
    && rm -f hdf5-*-linux-centos7-x86_64-gcc485-shared.tar.gz 

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

# Clean Up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#USER linuxbrew
RUN cd /home/linuxbrew && git clone https://github.com/NCBI-Hackathons/Cancer_Epitopes_CSHL.git
ENTRYPOINT [ "/usr/bin/tini", "--" ] 
CMD [ "/bin/bash" ] 
