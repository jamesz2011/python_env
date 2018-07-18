FROM python
MAINTAINER jamesz2011 <jamesz2011@126.com>


WORKDIR /opt
COPY ./sources.list /opt
COPY ./requirements.txt /opt


RUN cp -vf sources.list /etc/apt/

#RUN echo "deb http://http.us.debian.org/debian stable main" >> /etc/apt/sources.list 

RUN apt-get update \
    && apt-get install -y apt-transport-https  vim lrzsz tzdata sudo wget curl  dos2unix openssh-server  gcc make \
	&& apt-get install -y openjdk-8-jre openjdk-8-jdk
RUN mkdir /var/run/sshd \
        && echo root:apitest_123456 | chpasswd \
	&& sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
	&& sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config 

RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata
RUN pip install -r /opt/requirements.txt \ 
 && apt-get clean \ 
 &&   rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
EXPOSE 22
CMD    ["/usr/sbin/sshd", "-D"]
