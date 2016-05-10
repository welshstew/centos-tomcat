FROM registry.access.redhat.com/jboss-fuse-6/fis-java-openshift:latest

USER root

RUN yum -y update && \
	yum -y install wget && \
	yum -y install tar 

# Prepare environment 
ENV CATALINA_HOME /opt/tomcat 
ENV PATH $PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin:$CATALINA_HOME/scripts

#http://mirror.catn.com/pub/apache/tomcat/tomcat-8/v8.0.33/bin/apache-tomcat-8.0.33.zip

# Install Tomcat
RUN wget http://mirror.catn.com/pub/apache/tomcat/tomcat-8/v8.0.33/bin/apache-tomcat-8.0.33.zip && \
	tar -xvf apache-tomcat-8.0.33.tar.gz && \
	rm apache-tomcat*.tar.gz && \
	mv apache-tomcat* ${CATALINA_HOME} 

RUN chmod +x ${CATALINA_HOME}/bin/*sh

# Create Tomcat admin user
ADD create_admin_user.sh $CATALINA_HOME/scripts/create_admin_user.sh
ADD tomcat.sh $CATALINA_HOME/scripts/tomcat.sh
RUN chmod +x $CATALINA_HOME/scripts/*.sh

# Create tomcat user
RUN useradd -g jboss -d ${CATALINA_HOME} -s /sbin/nologin  -c "Tomcat user" jboss && \
	chown -R jboss:jboss ${CATALINA_HOME}


EXPOSE 8080
EXPOSE 8009

USER jboss
CMD ["tomcat.sh"]
