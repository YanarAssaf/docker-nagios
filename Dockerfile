FROM centos:7
RUN yum install -y epel-release
RUN yum install -y gcc glibc glibc-common wget unzip httpd php gd gd-devel perl postfix make gettext automake autoconf  openssl-devel net-snmp net-snmp-utils perl-Net-SNMP which nagios-plugins-nrpe && yum clean all
COPY files/* ./srv/

RUN cd /srv/ && tar xzf nagios-4.4.3.tar.gz

WORKDIR /srv/nagios-4.4.3
RUN ./configure && make all

RUN make install-groups-users
RUN usermod -a -G nagios apache
RUN make install
RUN make install-daemoninit
RUN make install-commandmode
RUN make install-config
RUN make install-webconf
RUN htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin nagiosadmin
COPY ./run.sh /srv/
EXPOSE 80
RUN mkdir -p /usr/local/nagios/etc/noc
RUN cp /usr/lib64/nagios/plugins/check_nrpe /usr/local/nagios/libexec/
RUN chmod +x /srv/run.sh

#Plugins
RUN cd /srv/ && tar xzf nagios-plugins-release-2.2.1.tar.gz
WORKDIR /srv/nagios-plugins-release-2.2.1
RUN ./tools/setup && ./configure && make && make install
WORKDIR /usr/local/nagios
CMD /srv/run.sh
