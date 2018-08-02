#目前dockerhub上Python官方支持的镜像，基础镜像是debian9.5
#python3.6.3镜像中使用的python版本是3.6.3，已安装配置pip工具

FROM python:3.6.3
MAINTAINER jamesz2011 <jamesz2011@126.com>

#指定docker容器的工作目录为"/opt",容器一启动就进入“/opt”目录
WORKDIR /opt

#复制资源文件
COPY ./sources.list /opt
COPY ./requirements.txt /opt

#复制debian的souces.list到/etc/apt下
RUN cp -vf sources.list /etc/apt/

#更新debian镜像源和安装一些基础的应用工具
RUN apt-get update \
    && apt-get install -y vim lrzsz tzdata wget curl  dos2unix openssh-server  \
	&& apt-get install -y openjdk-8-jre openjdk-8-jdk

#ssh的相关配置
RUN mkdir /var/run/sshd \
    && echo root:apitest_123456 | chpasswd \
	&& sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
	&& sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config 

#容器时区设置，更改为CST[中国标准]
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata


#pip批量安装python的第三方库	
RUN pip install -r /opt/requirements.txt 


#清除apt-get的缓存
RUN  apt-get clean \ 
 &&   rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
 
#暴露ssh服务的端口22，便于外部映射连接 
EXPOSE 22

#设置容器启动默认开启ssh服务
CMD ["/usr/sbin/sshd", "-D"]
