FROM centos:7
RUN yum install -y epel-release
RUN yum install -y gcc glibc glibc-common wget unzip httpd php gd gd-devel perl postfix make gettext automake autoconf  openssl-devel net-snmp net-snmp-utils perl-Net-SNMP which nagios-plugins-nrpe && yum clean all
COPY files/* ./srv/

RUN cd /srv/ && tar xzf nagios-4.4.3.tar.gz

WORKDIR /srv/nagios-4.4.3
RUN ./configure && make all

#Nagios Core
RUN make install-groups-users && usermod -a -G nagios apache && make install && make install-daemoninit && make install-commandmode && make install-config && make install-webconf && usermod --shell /bin/bash nagios
RUN htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin nagiosadmin
RUN mkdir -p /usr/local/nagios/etc/noc
RUN cp /usr/lib64/nagios/plugins/check_nrpe /usr/local/nagios/libexec/
COPY ./run.sh /srv/
RUN chmod +x /srv/run.sh

#Plugins
RUN cd /srv/ && tar xzf nagios-plugins-release-2.2.1.tar.gz
WORKDIR /srv/nagios-plugins-release-2.2.1
RUN ./tools/setup && ./configure && make && make install

WORKDIR /usr/local/nagios
EXPOSE 80
CMD /srv/run.sh
