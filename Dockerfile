# syntax=docker/dockerfile:1
FROM ubuntu
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# ...
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get -y install gcc mono-mcs

RUN rm -rf /var/lib/apt/lists/*
RUN apt-get update
RUN apt-get install -y
RUN apt-get install build-essential  -y
RUN apt-get install libssl-dev   -y
RUN apt-get install uuid-dev  -y
RUN apt-get install libgpgme11-dev -y
RUN apt-get install squashfs-tools  -y
RUN apt-get install libseccomp-dev  -y
RUN apt-get install pkg-config -y

CMD export VERSION=1.11 OS=linux ARCH=amd64
RUN apt-get install wget -y
CMD wget https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz
CMD tar -C /usr/local -xzvf go$VERSION.$OS-$ARCH.tar.gz
CMD rm go$VERSION.$OS-$ARCH.tar.gz
CMD echo 'export GOPATH=${HOME}/go' >> ~/.bashrc
CMD echo 'export PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin' >> ~/.bashrc
CMD source ~/.bashrc

CMD go get -u github.com/golang/dep/cmd/dep
RUN export VERSION=3.0.3 #&& # adjust this as necessary \
CMD mkdir -p $GOPATH/src/github.com/sylabs
CMD cd $GOPATH/src/github.com/sylabs
CMD wget https://github.com/sylabs/singularity/releases/download/v${VERSION}/singularity-${VERSION}.tar.gz
CMD tar -xzf singularity-${VERSION}.tar.gz
CMD cd ./singularity
CMD ./mconfig
COPY requirements.txt requirements.txt
RUN apt-get install python3.9 python-pip -y
CMD pip install -r requirements.txt -y
EXPOSE 5000
COPY . .
CMD ["flask", "run"]