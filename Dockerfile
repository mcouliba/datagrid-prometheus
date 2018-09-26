FROM registry.access.redhat.com/jboss-datagrid-7/datagrid72-openshift:latest

RUN mkdir -p ${JBOSS_HOME}/prometheus \
    && curl http://central.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.10/jmx_prometheus_javaagent-0.10.jar \
    -o ${JBOSS_HOME}/jmx-prometheus.jar

EXPOSE 9404