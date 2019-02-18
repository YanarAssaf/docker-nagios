FROM centos:7
RUN yum install -y epel-release
RUN yum install -y gcc glibc glibc-common wget unzip httpd php gd gd-devel perl postfix make gettext automake autoconf  openssl-devel net-snmp net-snmp-utils perl-Net-SNMP which nagios-plugins-nrpe && yum clean all
RUN yum install rrdtool rrdtool-perl perl-Time-HiRes perl-GD -y
COPY files/* ./srv/

RUN cd /srv/ && tar xzf nagios-4.4.3.tar.gz

#Nagios Core
WORKDIR /srv/nagios-4.4.3
RUN ./configure && make all

RUN make install-groups-users && usermod -a -G nagios apache && make install && make install-daemoninit && make install-commandmode && make install-config && make install-webconf && usermod --shell /bin/bash nagios
RUN htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin nagiosadmin
RUN mkdir -p /usr/local/nagios/etc/noc
RUN cp /usr/lib64/nagios/plugins/check_nrpe /usr/local/nagios/libexec/
COPY ./run.sh /srv/
RUN chmod +x /srv/run.sh

#PNP
RUN cd /srv/ && tar xzf pnp4nagios-0.6.26.tar.gz
WORKDIR /srv/pnp4nagios-0.6.26
RUN ./configure && make all && make fullinstall
RUN /usr/local/pnp4nagios/bin/npcd -d -f /usr/local/pnp4nagios/etc/npcd.cfg
RUN rm -f /usr/local/pnp4nagios/share/install.php

#NRPE
RUN cd /srv/ && tar xzf nagios-plugins-release-2.2.1.tar.gz
WORKDIR /srv/nagios-plugins-release-2.2.1
RUN ./tools/setup && ./configure && make && make install

RUN cp /srv/templates.cfg /usr/local/nagios/etc/objects
RUN cp /srv/nagios.cfg /usr/local/nagios/etc/nagios.cfg
RUN cp /srv/commands.cfg /usr/local/nagios/etc/noc/
RUN cp /srv/contacts.cfg /usr/local/nagios/etc/noc/
RUN cp /srv/groups.cfg /usr/local/nagios/etc/noc/
RUN cp /srv/hosts.cfg /usr/local/nagios/etc/noc/
RUN cp /srv/services.cfg /usr/local/nagios/etc/noc/

WORKDIR /usr/local/nagios
EXPOSE 80
CMD /srv/run.sh
