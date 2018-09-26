Data Grid / Infinispan - JMX Exporter Prometheus Metrics
================================================================

This project builds a custom image of Red Hat Data Grid / Infinispan in order to gather metrics using Prometheus (open source monitoring and alerting toolkit) and display them in Grafana.

## Prerequisites

* Requires Openshift Container Platform 3.9 or greater with Prometheus and Grafana installed
* Requires JBoss Data Grid 7.2 image and associated templates deployed on OCP

## Clone the GitHub repository and create the Openshift project

```
    git clone https://github.com/mcouliba/datagrid-prometheus.git
    cd datagrid-prometheus
```

## Creating the new image for Red Hat Data Grid / Infinispan

```
    oc new-build https://github.com/mcouliba/datagrid-prometheus.git --name=datagrid-prometheus --strategy=docker
    oc start-build datagrid-prometheus --from-dir=.
```

## Creating the ConfigMap with JMX Exporter parameter

```
    oc create configmap datagrid-prometheus --from-file=config.yaml
```

## Deploying and update the Deployment Config
    
```
	oc rollout pause dc/datagrid-app
	oc set image dc/datagrid-app datagrid-app=playingdatagrid/datagrid-prometheus:latest
	oc volume dc/datagrid-app --add --name=prometheus-volume --mount-path=/opt/datagrid/prometheus --configmap-name=datagrid-prometheus
    oc set env dc/datagrid-app JAVA_OPTS_APPEND="-javaagent:/opt/datagrid/jmx-prometheus.jar=9404:/opt/datagrid/prometheus/config.yaml"
    oc rollout resume dc/datagrid-app
```

- containerPort: 9404
  name: prothemeus
  protocol: TCP


## Updating Services
```
	oc create service clusterip datagrid-app-prometheus --tcp=9404:9404
```

apiVersion: v1
kind: Service
metadata:
  creationTimestamp: '2018-09-13T18:20:52Z'
  labels:
    app: datagrid-app
  name: datagrid-app-prometheus
  namespace: playingdatagrid
  resourceVersion: '68460648'
  selfLink: /api/v1/namespaces/playingdatagrid/services/datagrid-app-prometheus
  uid: bf3da504-b781-11e8-99db-5254001ff7d1
spec:
  clusterIP: 172.30.212.196
  ports:
    - name: 9404-tcp
      port: 9404
      protocol: TCP
      targetPort: 9404
  selector:
    deploymentConfig: datagrid-app
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}


## Updating Prometheus CM

- job_name: 'datagrid-metrics'
  kubernetes_sd_configs:
  - role: endpoints
    namespaces:
      names:
      - playingdatagrid
  relabel_configs:
  - source_labels: [__meta_kubernetes_service_name]
    action: keep
    regex: datagrid-app-prometheus
  - source_labels: [__meta_kubernetes_pod_container_port_name]
    action: keep
    regex: prometheus


## Check the targets in Prometheus

url: https://prometheus-openshift-metrics.example.org/targets

![](images/service-target.png)


## Grafana
Add datasources for Prometheus
Add dashboard




# Reference

* https://github.com/prometheus/jmx_exporter