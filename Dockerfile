FROM rhel7

RUN yum clean all && \
	yum-config-manager --disable rhel-sjis-for-rhel-7-server-rpms && \
	yum-config-manager --enable rhel-7-server-extras-rpms && \
	yum-config-manager --enable rhel-7-server-rpms && \
	yum install -y docker openssh-clients && \
	yum clean all

ENV HOME /root

USER 0

ADD ./run.sh /root/run.sh
RUN chmod +x /root/run.sh

CMD ["/root/run.sh"]

