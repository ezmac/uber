FROM ubuntu:14.04


# Install all software

RUN apt-get update
#RUN apt-get dist-upgrade -y
RUN apt-get install -y apache2 php5 php5-curl php5-ldap php5-intl php5-mysql php5-xcache samba phpmyadmin openssh-server php5-fpm 
RUN apt-get install -y incron
RUN apt-get install -y supervisor

#install nginx 1.6
RUN apt-get install -y python-software-properties software-properties-common
RUN add-apt-repository ppa:nginx/stable
RUN apt-get update
RUN apt-get install -y nginx pwgen


# install
RUN add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe"
RUN add-apt-repository -y ppa:ondrej/mysql-5.6
RUN DEBIAN_FRONTEND=noninteractive && apt-get install -y mysql-server
EXPOSE 3306


# add the basic machine provisioning configuration tools.  Maybe this is why puppet + docker would be useful?

RUN mkdir -p /provision/


ADD ./config/authorized_keys /root/.ssh/
# files will be moved to /data and will need to be symlinked into the right place.
ADD provision.sh /provision/
RUN chmod u+x /provision/provision.sh
ADD ./config /provision/config/
ADD ./run.sh /
ADD ./create_mysql_admin_user.sh /provision/
RUN rm /etc/nologin

RUN mkdir -p /var/log/nginx /var/run/sshd /var/log/supervisor && chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys && chown -R root /root/.ssh && chown -R root /root/


RUN update-rc.d mysql defaults

RUN apt-get install -y libapache2-mod-php5



# Web (apache/nginx)
EXPOSE 80 8080
# Samba
EXPOSE 135 137 139 445 88 138


RUN apt-get install -y php5-mcrypt
RUN /usr/sbin/php5enmod mcrypt
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/run.sh"]
