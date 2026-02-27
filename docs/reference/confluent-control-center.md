[ Stream ](https://docs.confluent.io/control-center/current/overview.html)
[ Confluent Cloud Fully-managed data streaming platform with a cloud-native Kafka engine (KORA) for elastic scaling, with enterprise security, stream processing, governance. ](https://docs.confluent.io/cloud/current/get-started/index.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fcontrol-center%2Fcurrent%2Foverview.html)[ Confluent Platform An on-premises enterprise-grade distribution of Apache Kafka with enterprise security, stream processing, governance. ](https://docs.confluent.io/platform/current/get-started/platform-quickstart.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fcontrol-center%2Fcurrent%2Foverview.html)
[ Connect ](https://docs.confluent.io/control-center/current/overview.html)
[ Managed Use fully-managed connectors with Confluent Cloud to connect to data sources and sinks. ](https://docs.confluent.io/cloud/current/connectors/index.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fcontrol-center%2Fcurrent%2Foverview.html)[ Self-Managed Use self-managed connectors with Confluent Platform to connect to data sources and sinks. ](https://docs.confluent.io/platform/current/connect/index.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fcontrol-center%2Fcurrent%2Foverview.html)
[ Govern ](https://docs.confluent.io/control-center/current/overview.html)
[ Managed Use fully-managed Schema Registry and Stream Governance with Confluent Cloud. ](https://docs.confluent.io/cloud/current/stream-governance/index.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fcontrol-center%2Fcurrent%2Foverview.html)[ Self-Managed Use self-managed Schema Registry and Stream Governance with Confluent Platform. ](https://docs.confluent.io/platform/current/schema-registry/index.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fcontrol-center%2Fcurrent%2Foverview.html)
[ Process ](https://docs.confluent.io/control-center/current/overview.html)
[ Managed Use Flink on Confluent Cloud to run complex, stateful, low-latency streaming applications. ](https://docs.confluent.io/cloud/current/flink/index.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fcontrol-center%2Fcurrent%2Foverview.html)[ Self-Managed Use Flink on Confluent Platform to run complex, stateful, low-latency streaming applications. ](https://docs.confluent.io/platform/current/flink/overview.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fcontrol-center%2Fcurrent%2Foverview.html)
[Get Started Free](https://www.confluent.io/get-started/?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fcontrol-center%2Fcurrent%2Foverview.html)
Page Options
Copy MarkdownCopy as Markdown
Open as MarkdownOpen markdown in a new tab
# Control Center for Confluent Platform[](https://docs.confluent.io/control-center/current/overview.html#c3-short-for-cp "Link to this heading")
Confluent Control Center is a web-based tool for managing and monitoring Apache Kafka® in Confluent Platform. Control Center provides a user interface that enables you to get a quick overview of cluster health, observe and control messages, topics, and Schema Registry, and to develop and run ksqlDB queries.
Looking for a fully managed cloud-native service for Apache Kafka®?
Sign up for [Confluent Cloud](https://www.confluent.io/confluent-cloud/?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fcontrol-center%2Fcurrent%2Foverview.html) and get started for free using the [Cloud quick start](https://docs.confluent.io/cloud/current/get-started/index.html).
## Install and access[](https://docs.confluent.io/control-center/current/overview.html#install-and-access "Link to this heading")
Install Control Center with a supported version of Confluent Platform. For details about install and configuration, see [Confluent Control Center Installation](https://docs.confluent.io/control-center/current/installation/overview.html#install-c3) and [Control Center Configuration Reference for Confluent Platform](https://docs.confluent.io/control-center/current/installation/configuration.html#controlcenter-configuration).
To access Control Center on the default host and port, go to: `http://localhost:9021/`
## Monitoring services[](https://docs.confluent.io/control-center/current/overview.html#monitoring-services "Link to this heading")
Control Center monitors Confluent Platform by collecting metrics about brokers, topics, and consumer group lag.
For monitoring Connect, Replicator, and ksqlDB clusters and underlying resources, metrics aren’t collected. Control Center requests information from these services to display status.
The following image shows an example of the monitoring capabilities of Control Center.
## Management services[](https://docs.confluent.io/control-center/current/overview.html#management-services "Link to this heading")
To provide management services, Control Center acts as a client that redirects requests to their appropriate servers. For example, requests to update broker settings or to create a new topic will be redirected to Kafka; requests to create a new connector will be redirected to Kafka Connect.
## Reduced infrastructure mode[](https://docs.confluent.io/control-center/current/overview.html#reduced-infrastructure-mode "Link to this heading")
To conserve resources, you can run Control Center in Reduced infrastructure mode. You don’t get any metrics or monitoring data in Reduced infrastructure mode. For more information, see [Confluent Control Center Installation](https://docs.confluent.io/control-center/current/installation/overview.html#install-c3).
Configure Control Center to run in Reduced infrastructure mode with the [mode](https://docs.confluent.io/control-center/current/installation/configuration.html#mode-settings) property. If you don’t explicitly set Reduced infrastructure mode, you get metrics and monitoring.
Management services are provided in Reduced infrastructure mode.
## Control Center features[](https://docs.confluent.io/control-center/current/overview.html#c3-short-features "Link to this heading")
Control Center includes the following pages where you can drill down to view data and configure features in your Kafka environment. The following table lists Control Center pages and what they display depending on the mode for Confluent Control Center.
Control Center feature | Normal mode | Reduced infrastructure mode  
---|---|---  
[Clusters overview](https://docs.confluent.io/control-center/current/clusters.html#controlcenter-userguide-clusters) | View healthy and unhealthy clusters at a glance and search for a cluster being managed by Control Center. Click on a cluster tile to drill into views of critical metrics and connected services for that cluster. | View healthy and unhealthy clusters, the number of topics, and connected services.  
[Brokers overview](https://docs.confluent.io/control-center/current/brokers.html#controlcenter-userguide-brokers) | View broker partitioning and replication status, which broker is the active controller, and broker metrics like throughput and more. | Same as Normal mode. To access the Brokers page in Reduced infrastructure mode, Use the **Brokers** navigation menu entry.  
| Add and edit topics, view production and consumption metrics for a topic. Browse, create, and download messages, and manage Schema Registry for topics. | Add and edit topics. Browse, create, download messages, and manage Schema Registry for topics. Note that internal topics are not created in Reduced infrastructure mode.  
| Manage, monitor, and configure connectors with [Kafka Connect](https://docs.confluent.io/platform/current/connect/index.html#kafka-connect), the toolkit for connecting external systems to Kafka. | Same as Normal mode.  
| Develop applications against ksqlDB, the streaming SQL engine for Kafka. Use the ksqlDB page in Control Center to: run, view, and terminate SQL queries; browse and download messages from query results; add, describe, and drop streams and tables; and view schemas of available streams and tables in a cluster. | Same as Normal mode.  
[Client monitoring](https://docs.confluent.io/control-center/current/clients/overview.html#clients-c3) | Monitor client metrics for producers and consumers. For a selected Kafka cluster, view data about consumer groups and lag, including the number of consumers in each group. | For a selected Kafka cluster, view data about consumer groups, including the number of consumers in each group, the number of topics being consumed, and the consumer lag across all relevant topics.  
[Replicators](https://docs.confluent.io/control-center/current/replicators.html#controlcenter-userguide-replicators) | Monitor and configure replicated topics and create replica topics that preserve topic configuration in the source cluster. | Configure replicated topics and create replica topics that preserve topic configuration in the source cluster.  
[Cluster Settings](https://docs.confluent.io/control-center/current/clusters.html#controlcenter-userguide-cluster-settings) | View and edit cluster properties and broker configurations. | Same as Normal mode.  
| Use Alerts to define the trigger criteria for anomalous events that occur during data monitoring and to trigger an alert when those events occur. Set triggers, actions, and view alert history across all of your Control Center clusters. | No Alerts are supported.  
## Control Center security[](https://docs.confluent.io/control-center/current/overview.html#c3-short-security "Link to this heading")
Control Center offers several security options for authentication and authorization to help you secure your deployment. For more information, see the following topics:
  * [Configure TLS for Control Center on Confluent Platform](https://docs.confluent.io/control-center/current/security/ssl.html#controlcenter-security-ssl)
  * [Configure SASL for Control Center on Confluent Platform](https://docs.confluent.io/control-center/current/security/sasl.html#controlcenter-security-sasl)
  * [Configure HTTP Basic Authentication with Control Center on Confluent Platform](https://docs.confluent.io/control-center/current/security/authentication.html#ui-authentication)
  * [Configure Control Center to work with Kafka ACLs on Confluent Platform](https://docs.confluent.io/control-center/current/security/config-c3-for-kafka-acls.html#c3-auth-acls)
  * [Configure Control Center with LDAP authentication on Confluent Platform](https://docs.confluent.io/control-center/current/security/c3-auth-ldap.html#controlcenter-security-ldap)
  * [Configure RBAC for Control Center on Confluent Platform](https://docs.confluent.io/control-center/current/security/c3-rbac.html#controlcenter-security-rbac)
  * [Single Sign-On (SSO) for Confluent Control Center on Confluent Platform](https://docs.confluent.io/platform/current/security/authentication/sso-for-c3/overview.html#sso-for-c3)
  * [Manage RBAC roles with Control Center on Confluent Platform](https://docs.confluent.io/control-center/current/security/c3-rbac-manage-roles-ui.html#c3-rbac-manage-roles-ui)


By clicking “Accept All Cookies”, you agree to the storing of cookies on your device to enhance site navigation, analyze site usage, and assist in our marketing efforts. 
Accept All Cookies
Reject All
Cookies Settings

[ Stream ](https://docs.confluent.io/control-center/current/installation/overview.html)
[ Confluent Cloud Fully-managed data streaming platform with a cloud-native Kafka engine (KORA) for elastic scaling, with enterprise security, stream processing, governance. ](https://docs.confluent.io/cloud/current/get-started/index.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fcontrol-center%2Fcurrent%2Finstallation%2Foverview.html)[ Confluent Platform An on-premises enterprise-grade distribution of Apache Kafka with enterprise security, stream processing, governance. ](https://docs.confluent.io/platform/current/get-started/platform-quickstart.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fcontrol-center%2Fcurrent%2Finstallation%2Foverview.html)
[ Connect ](https://docs.confluent.io/control-center/current/installation/overview.html)
[ Managed Use fully-managed connectors with Confluent Cloud to connect to data sources and sinks. ](https://docs.confluent.io/cloud/current/connectors/index.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fcontrol-center%2Fcurrent%2Finstallation%2Foverview.html)[ Self-Managed Use self-managed connectors with Confluent Platform to connect to data sources and sinks. ](https://docs.confluent.io/platform/current/connect/index.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fcontrol-center%2Fcurrent%2Finstallation%2Foverview.html)
[ Govern ](https://docs.confluent.io/control-center/current/installation/overview.html)
[ Managed Use fully-managed Schema Registry and Stream Governance with Confluent Cloud. ](https://docs.confluent.io/cloud/current/stream-governance/index.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fcontrol-center%2Fcurrent%2Finstallation%2Foverview.html)[ Self-Managed Use self-managed Schema Registry and Stream Governance with Confluent Platform. ](https://docs.confluent.io/platform/current/schema-registry/index.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fcontrol-center%2Fcurrent%2Finstallation%2Foverview.html)
[ Process ](https://docs.confluent.io/control-center/current/installation/overview.html)
[ Managed Use Flink on Confluent Cloud to run complex, stateful, low-latency streaming applications. ](https://docs.confluent.io/cloud/current/flink/index.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fcontrol-center%2Fcurrent%2Finstallation%2Foverview.html)[ Self-Managed Use Flink on Confluent Platform to run complex, stateful, low-latency streaming applications. ](https://docs.confluent.io/platform/current/flink/overview.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fcontrol-center%2Fcurrent%2Finstallation%2Foverview.html)
[Get Started Free](https://www.confluent.io/get-started/?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fcontrol-center%2Fcurrent%2Finstallation%2Foverview.html)
  1. [Manage Control Center for Confluent Platform](https://docs.confluent.io/control-center/current/installation/index.html)


Page Options
Copy MarkdownCopy as Markdown
Open as MarkdownOpen markdown in a new tab
# Confluent Control Center Installation[](https://docs.confluent.io/control-center/current/installation/overview.html#c3-installation "Link to this heading")
This topic offers instruction for installing Control Center. For Confluent Platform installations, see [Install Confluent Platform On-Premises](https://docs.confluent.io/platform/current/installation/overview.html).
For Control Center system requirements and compatibility with Confluent Platform, see [System Requirements and Compatibility](https://docs.confluent.io/control-center/current/installation/system-requirements.html#system-requirements-c3).
## Single-node manual installation[](https://docs.confluent.io/control-center/current/installation/overview.html#single-node-manual-installation "Link to this heading")
Use these steps for single-node manual installation of Control Center with Confluent Platform.
### Docker[](https://docs.confluent.io/control-center/current/installation/overview.html#docker "Link to this heading")
The following steps install Confluent Platform 8.0 and Control Center 2.2.
**To install Control Center with Docker**
  1. Clone Control Center public repo.
```
gitclone--branchcontrol-centerhttps://github.com/confluentinc/cp-all-in-one.git

```

  2. Change directory into: [cp-all-in-one](https://github.com/confluentinc/cp-all-in-one/tree/control-center/cp-all-in-one)
```
cdcp-all-in-one/cp-all-in-one

```

  3. Checkout branch: `8.0.0-post`
```
gitcheckout8.0.0-post

```

  4. Run the docker compose command.
```
dockercomposeup-d

```



### Archive[](https://docs.confluent.io/control-center/current/installation/overview.html#archive "Link to this heading")
Install Control Center and Confluent Platform using archives on a single node. 

Considerations:
    
  * Control Center introduces a new directory structure that differs from the directory structure used with Control Center (Legacy).
  * In earlier versions of the Confluent Platform, there was a single main directory, commonly referenced as `CONFLUENT_HOME` and all components, including Control Center (Legacy), were inside this main directory (i.e. `CONFLUENT_HOME/control-center`).
  * Control Center now has its own top-level directory, `CONTROL_CENTER_HOME`.
  * `CONTROL_CENTER_HOME` is placed at the same hierarchical level as `CONFLUENT_HOME`, not inside it.
  * The steps below offer the optimal order in which to install Confluent Platform with Control Center.



Prerequisites:
    
  * Provision a new virtual machine (VM) for Control Center on the same network as the Confluent Platform clusters that you want to monitor.
  * For VM sizing recommendations, see [System requirements](https://docs.confluent.io/control-center/current/installation/system-requirements.html#install-c3-system-reqs).
  * Install the same version of openjdk that is on your existing Control Center (Legacy) (openjdk-8-jdk, openjdk-11-jdk, or openjdk-17-jdk).
  * On the Control Center VM, open ports 9090 (Control Center) and 9021 (Control Center user interface).
  * On every broker or KRaft controller, ensure that you can send outgoing http traffic to port 9090 on the Control Center VM.


KRaft
Confluent Platform 8.1 

Considerations:
    
  * With local installations, the default port settings are as follows: Alertmanager uses port 9098 and controllers in KRaft mode use port 9093.


  1. Download the Confluent Platform archive 8.1 and run these commands:
```
wgethttps://packages.confluent.io/archive/8.1/confluent-8.1.0.tar.gz

```

```
tar-xvfconfluent-8.1.0.tar.gz

```

```
cdconfluent-8.1.0

```

```
exportCONFLUENT_HOME=`pwd`

```

  2. Download the Control Center archive and run these commands:
```
wgethttps://packages.confluent.io/confluent-control-center-next-gen/archive/confluent-control-center-next-gen-2.3.1.tar.gz

```

```
tar-xvfconfluent-control-center-next-gen-2.3.1.tar.gz

```

```
cdconfluent-control-center-next-gen-2.3.1

```

```
exportCONTROL_CENTER_HOME=`pwd`

```

  3. Change directory to the `$CONFLUENT_HOME/bin` directory:
```
export PATH=$PATH:$CONFLUENT_HOME/bin

```

  4. Use the Confluent CLI to run the following command:
```
confluentlocalservicesstart

```



Confluent Platform 7.7 - 8.0 

Considerations:
    
  * You must use a special command to start Prometheus on MacOS.
  * By default Alertmanager and controllers in KRaft mode use port 9093. To run Prometheus and Alertmanager and KRaft mode controllers on the same host, you must manually edit the provided Control Center scripts.


  1. Download the Confluent Platform archive (7.7 to 8.0 supported) and run these commands:
```
wgethttps://packages.confluent.io/archive/8.0/confluent-8.0.0.tar.gz

```

```
tar-xvfconfluent-8.0.0.tar.gz

```

```
cdconfluent-8.0.0

```

```
exportCONFLUENT_HOME=`pwd`

```

  2. Update the broker and controller configurations to emit metrics to Prometheus by adding the following configurations to: `etc/kafka/controller.properties` and `etc/kafka/broker.properties`
The fifth line (`confluent.telemetry.exporter._c3.metrics.include=<value>`) is very long. Simply copy the code block as provided and append it to the end of the properties files. Pasting the fifth line results in a single line, even though it shows as wrapped in the documentation.
```
metric.reporters=io.confluent.telemetry.reporter.TelemetryReporter
confluent.telemetry.exporter._c3.type=http
confluent.telemetry.exporter._c3.enabled=true
confluent.telemetry.exporter._c3.metrics.include=io.confluent.kafka.server.request.(?!.*delta).*|io.confluent.kafka.server.server.broker.state|io.confluent.kafka.server.replica.manager.leader.count|io.confluent.kafka.server.request.queue.size|io.confluent.kafka.server.broker.topic.failed.produce.requests.rate.1.min|io.confluent.kafka.server.tier.archiver.total.lag|io.confluent.kafka.server.request.total.time.ms.p99|io.confluent.kafka.server.broker.topic.failed.fetch.requests.rate.1.min|io.confluent.kafka.server.broker.topic.total.fetch.requests.rate.1.min|io.confluent.kafka.server.partition.caught.up.replicas.count|io.confluent.kafka.server.partition.observer.replicas.count|io.confluent.kafka.server.tier.tasks.num.partitions.in.error|io.confluent.kafka.server.broker.topic.bytes.out.rate.1.min|io.confluent.kafka.server.request.total.time.ms.p95|io.confluent.kafka.server.controller.active.controller.count|io.confluent.kafka.server.session.expire.listener.zookeeper.disconnects.total|io.confluent.kafka.server.request.total.time.ms.p999|io.confluent.kafka.server.controller.active.broker.count|io.confluent.kafka.server.request.handler.pool.request.handler.avg.idle.percent.rate.1.min|io.confluent.kafka.server.session.expire.listener.zookeeper.disconnects.rate.1.min|io.confluent.kafka.server.controller.unclean.leader.elections.rate.1.min|io.confluent.kafka.server.replica.manager.partition.count|io.confluent.kafka.server.controller.unclean.leader.elections.total|io.confluent.kafka.server.partition.replicas.count|io.confluent.kafka.server.broker.topic.total.produce.requests.rate.1.min|io.confluent.kafka.server.controller.offline.partitions.count|io.confluent.kafka.server.socket.server.network.processor.avg.idle.percent|io.confluent.kafka.server.partition.under.replicated|io.confluent.kafka.server.log.log.start.offset|io.confluent.kafka.server.log.tier.size|io.confluent.kafka.server.log.size|io.confluent.kafka.server.tier.fetcher.bytes.fetched.total|io.confluent.kafka.server.request.total.time.ms.p50|io.confluent.kafka.server.tenant.consumer.lag.offsets|io.confluent.kafka.server.session.expire.listener.zookeeper.expires.rate.1.min|io.confluent.kafka.server.log.log.end.offset|io.confluent.kafka.server.broker.topic.bytes.in.rate.1.min|io.confluent.kafka.server.partition.under.min.isr|io.confluent.kafka.server.partition.in.sync.replicas.count|io.confluent.telemetry.http.exporter.batches.dropped|io.confluent.telemetry.http.exporter.items.total|io.confluent.telemetry.http.exporter.items.succeeded|io.confluent.telemetry.http.exporter.send.time.total.millis|io.confluent.kafka.server.controller.leader.election.rate.(?!.*delta).*|io.confluent.telemetry.http.exporter.batches.failed
confluent.telemetry.exporter._c3.client.base.url=http://localhost:9090/api/v1/otlp
confluent.telemetry.exporter._c3.client.compression=gzip
confluent.telemetry.exporter._c3.api.key=dummy
confluent.telemetry.exporter._c3.api.secret=dummy
confluent.telemetry.exporter._c3.buffer.pending.batches.max=80
confluent.telemetry.exporter._c3.buffer.batch.items.max=4000
confluent.telemetry.exporter._c3.buffer.inflight.submissions.max=10
confluent.telemetry.metrics.collector.interval.ms=60000
confluent.telemetry.remoteconfig._confluent.enabled=false
confluent.consumer.lag.emitter.enabled=true

```

  3. Download the Control Center archive and run these commands:
```
wgethttps://packages.confluent.io/confluent-control-center-next-gen/archive/confluent-control-center-next-gen-2.3.1.tar.gz

```

```
tar-xvfconfluent-control-center-next-gen-2.3.1.tar.gz

```

```
cdconfluent-control-center-next-gen-2.3.1

```

```
exportC3_HOME=`pwd`

```

  4. Start Prometheus and Alertmanager
To start Control Center, you must have three dedicated command windows: one for Prometheus, another for the Control Center process, and a third dedicated command window for Alertmanager. Run the following commands from `$C3_HOME` in all command windows.
    1. Open `etc/confluent-control-center/prometheus-generated.yml` and change `localhost:9093` to `localhost:9098`
```
alerting:
alertmanagers:
-static_configs:
-targets:
-localhost:9098

```

    2. Start Prometheus.
All operating systems except MacOS:
```
bin/prometheus-start

```

MacOS:
```
bashbin/prometheus-start

```

Note
Prometheus runs but does not output any information to the screen.
    3. Start Alertmanager.
      1. Run this command:
```
exportALERTMANAGER_PORT=9098

```

      2. All operating systems except MacOS:
```
bin/alertmanager-start

```

MacOS
```
bashbin/alertmanager-start

```

  5. Start Control Center.
    1. Open `etc/confluent-control-center/control-center-dev.properties` and update port `9093` to `9098`:
```
confluent.controlcenter.alertmanager.url=http://localhost:9098

```

    2. Run this command:
```
bin/control-center-startetc/confluent-control-center/control-center-dev.properties

```

  6. Start Confluent Platform.
To start Confluent Platform, you must have two dedicated command windows, one for the controller and another for the broker process. All the following commands are meant to be run from `CONFLUENT_HOME` in both command windows. The Confluent Platform start sequence requires you to generate a single random ID and use that _same_ ID for both the controller and the broker process.
    1. In the command window dedicated to running the controller, change directories into `CONFLUENT_HOME`.
```
cdCONFLUENT_HOME

```

    2. Generate a random value for `KAFKA_CLUSTER_ID`.
```
KAFKA_CLUSTER_ID="$(bin/kafka-storagerandom-uuid)"

```

    3. Use the following command to get the random ID and save the output. You need this value to start the controller _and_ the broker.
```
echo$KAFKA_CLUSTER_ID

```

    4. Format the log directories for the controller:
```
bin/kafka-storageformat--cluster-id$KAFKA_CLUSTER_ID-cetc/kafka/kraft/controller.properties--standalone

```

    5. Start the controller:
```
bin/kafka-server-startetc/kafka/kraft/controller.properties

```

    6. Open a command window for the broker and navigate to `CONFLUENT_HOME`.
```
cdCONFLUENT_HOME

```

    7. Set the `KAFKA_CLUSTER_ID` variable to the random ID you generated earlier with `kafka-storage random-uuid`.
```
exportKAFKA_CLUSTER_ID=<KAFKA-CLUSTER-ID>

```

    8. Format the log directories for this broker:
```
bin/kafka-storageformat--cluster-id$KAFKA_CLUSTER_ID-cetc/kafka/kraft/broker.properties

```

    9. Start the broker:
```
bin/kafka-server-startetc/kafka/kraft/broker.properties

```



ZooKeeper 

Considerations:
    
  * You must use a special command to start Prometheus on MacOS.


  1. Download the Confluent Platform archive (7.7 to 7.9 supported) and run these commands:
```
wgethttps://packages.confluent.io/archive/7.9/confluent-7.9.0.tar.gz

```

```
tar-xvfconfluent-7.9.0.tar.gz

```

```
cdconfluent-7.9.0

```

```
exportCONFLUENT_HOME=`pwd`

```

  2. Update broker configurations to emit metrics to Prometheus by adding the following configurations to: `etc/kafka/server.properties`
```
metric.reporters=io.confluent.telemetry.reporter.TelemetryReporter
confluent.telemetry.exporter._c3.type=http
confluent.telemetry.exporter._c3.enabled=true
confluent.telemetry.exporter._c3.metrics.include=io.confluent.kafka.server.request.(?!.*delta).*|io.confluent.kafka.server.server.broker.state|io.confluent.kafka.server.replica.manager.leader.count|io.confluent.kafka.server.request.queue.size|io.confluent.kafka.server.broker.topic.failed.produce.requests.rate.1.min|io.confluent.kafka.server.tier.archiver.total.lag|io.confluent.kafka.server.request.total.time.ms.p99|io.confluent.kafka.server.broker.topic.failed.fetch.requests.rate.1.min|io.confluent.kafka.server.broker.topic.total.fetch.requests.rate.1.min|io.confluent.kafka.server.partition.caught.up.replicas.count|io.confluent.kafka.server.partition.observer.replicas.count|io.confluent.kafka.server.tier.tasks.num.partitions.in.error|io.confluent.kafka.server.broker.topic.bytes.out.rate.1.min|io.confluent.kafka.server.request.total.time.ms.p95|io.confluent.kafka.server.controller.active.controller.count|io.confluent.kafka.server.session.expire.listener.zookeeper.disconnects.total|io.confluent.kafka.server.request.total.time.ms.p999|io.confluent.kafka.server.controller.active.broker.count|io.confluent.kafka.server.request.handler.pool.request.handler.avg.idle.percent.rate.1.min|io.confluent.kafka.server.session.expire.listener.zookeeper.disconnects.rate.1.min|io.confluent.kafka.server.controller.unclean.leader.elections.rate.1.min|io.confluent.kafka.server.replica.manager.partition.count|io.confluent.kafka.server.controller.unclean.leader.elections.total|io.confluent.kafka.server.partition.replicas.count|io.confluent.kafka.server.broker.topic.total.produce.requests.rate.1.min|io.confluent.kafka.server.controller.offline.partitions.count|io.confluent.kafka.server.socket.server.network.processor.avg.idle.percent|io.confluent.kafka.server.partition.under.replicated|io.confluent.kafka.server.log.log.start.offset|io.confluent.kafka.server.log.tier.size|io.confluent.kafka.server.log.size|io.confluent.kafka.server.tier.fetcher.bytes.fetched.total|io.confluent.kafka.server.request.total.time.ms.p50|io.confluent.kafka.server.tenant.consumer.lag.offsets|io.confluent.kafka.server.session.expire.listener.zookeeper.expires.rate.1.min|io.confluent.kafka.server.log.log.end.offset|io.confluent.kafka.server.broker.topic.bytes.in.rate.1.min|io.confluent.kafka.server.partition.under.min.isr|io.confluent.kafka.server.partition.in.sync.replicas.count|io.confluent.telemetry.http.exporter.batches.dropped|io.confluent.telemetry.http.exporter.items.total|io.confluent.telemetry.http.exporter.items.succeeded|io.confluent.telemetry.http.exporter.send.time.total.millis|io.confluent.kafka.server.controller.leader.election.rate.(?!.*delta).*|io.confluent.telemetry.http.exporter.batches.failed
confluent.telemetry.exporter._c3.client.base.url=http://localhost:9090/api/v1/otlp
confluent.telemetry.exporter._c3.client.compression=gzip
confluent.telemetry.exporter._c3.api.key=dummy
confluent.telemetry.exporter._c3.api.secret=dummy
confluent.telemetry.exporter._c3.buffer.pending.batches.max=80
confluent.telemetry.exporter._c3.buffer.batch.items.max=4000
confluent.telemetry.exporter._c3.buffer.inflight.submissions.max=10
confluent.telemetry.metrics.collector.interval.ms=60000
confluent.telemetry.remoteconfig._confluent.enabled=false
confluent.consumer.lag.emitter.enabled=true

```

  3. Download the Control Center archive and run these commands:
```
wgethttps://packages.confluent.io/confluent-control-center-next-gen/archive/confluent-control-center-next-gen-2.3.1.tar.gz

```

```
tar-xvfconfluent-control-center-next-gen-2.3.1.tar.gz

```

```
cdconfluent-control-center-next-gen-2.3.1

```

  4. Start Control Center.
To start Control Center, you must have three dedicated command windows: one for Prometheus, another for the Control Center process, and a third for Alertmanager. Run the following commands from `CONTROL_CENTER_HOME` in all command windows.
    1. Start Prometheus.
```
bin/prometheus-start

```

    2. Start Alertmanager.
```
bin/alertmanager-start

```

    3. Start Control Center.
```
bin/control-center-startetc/confluent-control-center/control-center-dev.properties

```

  5. Start Confluent Platform.
Start ZooKeeper.
```
bin/zookeeper-server-startetc/kafka/zookeeper.properties

```

Start Kafka.
```
bin/kafka-server-startetc/kafka/server.properties

```



## Multi-node manual installation[](https://docs.confluent.io/control-center/current/installation/overview.html#multi-node-manual-installation "Link to this heading")
Use these steps for multi-node manual installation of Control Center and Confluent Platform.
  1. Provision a new node using any of the Confluent Platform supported operating systems. For more information, see [Supported operating systems](https://docs.confluent.io/platform/current/installation/versions-interoperability.html#operating-systems). Login to the VM on which you will install Confluent Platform.
Install Control Center on a new node/VM. To ensure a smooth transition, allow Control Center (Legacy) users to continue using Control Center (Legacy) until the Control Center has gathered 7-15 days of historical metrics. For more information, see [Migration](https://docs.confluent.io/control-center/current/installation/overview.html#install-c3-migration).
  2. Login to the VM and install Control Center. For more information, see [Compatibility with Confluent Platform](https://docs.confluent.io/control-center/current/installation/system-requirements.html#install-c3-supported-cp).
Use the instructions for installing Confluent Platform but make sure to use the base URL and properties from these instructions to install Control Center.
For more information, see [Confluent Platform System Requirements](https://docs.confluent.io/platform/current/installation/system-requirements.html#system-requirements), [Install Confluent Platform using Systemd on Ubuntu and Debian](https://docs.confluent.io/platform/current/installation/installing_cp/deb-ubuntu.html#systemd-ubuntu-debian-install), and [Install Confluent Platform using Systemd on RHEL, CentOS, and Fedora-based Linux](https://docs.confluent.io/platform/current/installation/installing_cp/rhel-centos.html#systemd-rhel-centos-install).
Ubuntu and Debian
```
exportBASE_URL=https://packages.confluent.io/confluent-control-center-next-gen/deb/
sudoapt-getupdate
wget${BASE_URL}archive.key
sudoapt-keyaddarchive.key
sudoadd-apt-repository-y"deb ${BASE_URL} stable main"
sudoaptupdate

```

```
sudoaptinstall-yconfluent-control-center-next-gen

```

RHEL, CentOS, and Fedora-based Linux
```
exportbase_url=https://packages.confluent.io/confluent-control-center-next-gen/rpm/
cat<<EOF | sudo tee /etc/yum.repos.d/Confluent.repo > /dev/null
[Confluent]
name=Confluent repository
baseurl=${base_url}
gpgcheck=1
gpgkey=${base_url}archive.key
enabled=1
EOF

```

```
sudoyuminstall-yconfluent-control-center-next-gencyrus-saslopenssl-devel

```

  3. Install Java for your operating system (if not installed).
```
sudoyuminstalljava-17-openjdk-y----RHEL/CentOs/Fedora

```

```
sudoaptinstallopenjdk-17-jdk-y----Ubuntu/Debian

```

  4. Copy `/etc/confluent-control-center/control-center-production.properties` from your current Control Center (Legacy) into the Control Center node on the VM and add this property:
```
confluent.controlcenter.id=10
confluent.controlcenter.prometheus.enable=true
confluent.controlcenter.prometheus.url=http://localhost:9090
confluent.controlcenter.prometheus.rules.file=/etc/confluent-control-center/trigger_rules-generated.yml
confluent.controlcenter.alertmanager.config.file=/etc/confluent-control-center/alertmanager-generated.yml

```

  5. If you are using SSL, copy the certs at `/var/ssl/private` from your current Control Center (Legacy) into the Control Center node on the VM. If you are not using SSL, skip this step.
  6. Change ownership of the configuration files. Give the Control Center process write permissions to the alert manager, so that the process can properly manage alert triggers. Use the `chown` command to set the Control Center process as the owner of the `trigger_rules-generated.yml` and `alertmanager-generated.yml` files.
```
chown-ccp-control-center/etc/confluent-control-center/trigger_rules-generated.yml
chown-ccp-control-center/etc/confluent-control-center/alertmanager-generated.yml

```

  7. Start the following services on the Control Center node:
```
systemctlenableprometheus
systemctlstartprometheus

systemctlenablealertmanager
systemctlstartalertmanager

systemctlenableconfluent-control-center
systemctlstartconfluent-control-center

```

  8. Login to each broker you intend to monitor and verify brokers can reach the Control Center node on port 9090.
```
curlhttp://<c3-internal-dns-url>:9090/-/healthy

```

All brokers must have access to the Control Center node on port 9090, but port 9090 does not require public access. Restrict access as you prefer.
  9. Update the following properties for every Kafka broker and KRaft controller. Pay attention to the notes on the highlighted lines that follow the code example.
KRaft controller properties are located here: `/etc/controller/server.properties`
```
metric.reporters=io.confluent.telemetry.reporter.TelemetryReporter,io.confluent.metrics.reporter.ConfluentMetricsReporter---[1]
confluent.telemetry.exporter._c3.type=http
confluent.telemetry.exporter._c3.enabled=true
confluent.telemetry.exporter._c3.metrics.include=io.confluent.kafka.server.request.(?!.*delta).*|io.confluent.kafka.server.server.broker.state|io.confluent.kafka.server.replica.manager.leader.count|io.confluent.kafka.server.request.queue.size|io.confluent.kafka.server.broker.topic.failed.produce.requests.rate.1.min|io.confluent.kafka.server.tier.archiver.total.lag|io.confluent.kafka.server.request.total.time.ms.p99|io.confluent.kafka.server.broker.topic.failed.fetch.requests.rate.1.min|io.confluent.kafka.server.broker.topic.total.fetch.requests.rate.1.min|io.confluent.kafka.server.partition.caught.up.replicas.count|io.confluent.kafka.server.partition.observer.replicas.count|io.confluent.kafka.server.tier.tasks.num.partitions.in.error|io.confluent.kafka.server.broker.topic.bytes.out.rate.1.min|io.confluent.kafka.server.request.total.time.ms.p95|io.confluent.kafka.server.controller.active.controller.count|io.confluent.kafka.server.session.expire.listener.zookeeper.disconnects.total|io.confluent.kafka.server.request.total.time.ms.p999|io.confluent.kafka.server.controller.active.broker.count|io.confluent.kafka.server.request.handler.pool.request.handler.avg.idle.percent.rate.1.min|io.confluent.kafka.server.session.expire.listener.zookeeper.disconnects.rate.1.min|io.confluent.kafka.server.controller.unclean.leader.elections.rate.1.min|io.confluent.kafka.server.replica.manager.partition.count|io.confluent.kafka.server.controller.unclean.leader.elections.total|io.confluent.kafka.server.partition.replicas.count|io.confluent.kafka.server.broker.topic.total.produce.requests.rate.1.min|io.confluent.kafka.server.controller.offline.partitions.count|io.confluent.kafka.server.socket.server.network.processor.avg.idle.percent|io.confluent.kafka.server.partition.under.replicated|io.confluent.kafka.server.log.log.start.offset|io.confluent.kafka.server.log.tier.size|io.confluent.kafka.server.log.size|io.confluent.kafka.server.tier.fetcher.bytes.fetched.total|io.confluent.kafka.server.request.total.time.ms.p50|io.confluent.kafka.server.tenant.consumer.lag.offsets|io.confluent.kafka.server.session.expire.listener.zookeeper.expires.rate.1.min|io.confluent.kafka.server.log.log.end.offset|io.confluent.kafka.server.broker.topic.bytes.in.rate.1.min|io.confluent.kafka.server.partition.under.min.isr|io.confluent.kafka.server.partition.in.sync.replicas.count|io.confluent.telemetry.http.exporter.batches.dropped|io.confluent.telemetry.http.exporter.items.total|io.confluent.telemetry.http.exporter.items.succeeded|io.confluent.telemetry.http.exporter.send.time.total.millis|io.confluent.kafka.server.controller.leader.election.rate.(?!.*delta).*|io.confluent.telemetry.http.exporter.batches.failed
confluent.telemetry.exporter._c3.client.base.url=http://c3-internal-dns-hostname:9090/api/v1/otlp---[2]
confluent.telemetry.exporter._c3.client.compression=gzip
confluent.telemetry.exporter._c3.api.key=dummy
confluent.telemetry.exporter._c3.api.secret=dummy
confluent.telemetry.exporter._c3.buffer.pending.batches.max=80---[3]
confluent.telemetry.exporter._c3.buffer.batch.items.max=4000---[4]
confluent.telemetry.exporter._c3.buffer.inflight.submissions.max=10---[5]
confluent.telemetry.metrics.collector.interval.ms=60000---[6]
confluent.telemetry.remoteconfig._confluent.enabled=false
confluent.consumer.lag.emitter.enabled=true

```

     * [1] To enable metrics for both Control Center (Legacy) and Control Center, update your existing Control Center (Legacy) property `metric.reporters` to use the following values:
```
metric.reporters=io.confluent.telemetry.reporter.TelemetryReporter,io.confluent.metrics.reporter.ConfluentMetricsReporter

```

If you decommission Control Center (Legacy), enable only TelemetryReporter plugin with the following value:
```
metric.reporters=io.confluent.telemetry.reporter.TelemetryReporter

```

     * [2] Ensure the URL in `confluent.telemetry.exporter._c3.client.base.url` is the actual Control Center URL, reachable from the broker host.
```
confluent.telemetry.exporter._c3.client.base.url=http://c3-internal-dns-hostname:9090/api/v1/otlp

```

     * [3] [4] [5] [6] Use the following configurations for clusters up to 100,000 or fewer replicas. To get an accurate count of replicas, use the sum of all replicas across all clusters monitored in Control Center (Legacy) (including the Control Center (Legacy) bootstrap cluster).
```
confluent.telemetry.exporter._c3.buffer.pending.batches.max=80
confluent.telemetry.exporter._c3.buffer.batch.items.max=4000
confluent.telemetry.exporter._c3.buffer.inflight.submissions.max=10
confluent.telemetry.metrics.collector.interval.ms=60000

```

Configurations for clusters with 100,000 to 400,000 replicas 
Clusters with a replica count of 100,000 - 200,000:
```
confluent.telemetry.exporter._c3.buffer.pending.batches.max=80
confluent.telemetry.exporter._c3.buffer.batch.items.max=4000
confluent.telemetry.exporter._c3.buffer.inflight.submissions.max=20
confluent.telemetry.metrics.collector.interval.ms=60000

```

Clusters with a replica count of 200,000 - 400,000:
```
confluent.telemetry.exporter._c3.buffer.pending.batches.max=80
confluent.telemetry.exporter._c3.buffer.batch.items.max=4000
confluent.telemetry.exporter._c3.buffer.inflight.submissions.max=20
confluent.telemetry.metrics.collector.interval.ms=120000

```

For clusters with a replica count of 200,000 - 400,000, also update the following Control Center (Legacy) configuration:
```
confluent.controlcenter.prometheus.trigger.threshold.time=2m

```

  10. Perform a rolling restart for the brokers (zero downtime). For more information, see [Rolling restart](https://docs.confluent.io/platform/current/kafka/post-deployment.html#rolling-restart).
```
systemctlrestartconfluent-server

```

  11. (Optional) Setup log rotation for Prometheus and Alertmanager.
Prometheus
    1. Create a new configuration file at `/etc/logrotate.d/prometheus` with the following content:
```
/var/log/confluent/control-center/prometheus.log{
size10MB
rotate5
compress
delaycompress
missingok
notifempty
copytruncate
}

```

    2. Create a script at `/usr/local/bin/logrotate-prometheus.sh`:
```
#!/bin/bash
/usr/sbin/logrotate-s/var/lib/logrotate/status-prometheus/etc/logrotate.d/prometheus

```

    3. Make the script executable
```
chmod+x/usr/local/bin/logrotate-prometheus.sh

```

    4. To schedule with Cron, add the following line to your crontab (crontab -e):
```
*/10****/usr/local/bin/logrotate-prometheus.sh>>/tmp/prometheus-rotate.log2>1

```

    5. Restart Prometheus
```
systemctlrestartprometheus

```

    6. Perform similar steps for Alertmanager logs.
Alertmanager
    1. Create a new configuration file at `/etc/logrotate.d/alertmanager` with the following content:
```
/var/log/confluent/control-center/alertmanager.log{
size10MB
rotate5
compress
delaycompress
missingok
notifempty
copytruncate
}

```

    2. Create a script at `/usr/local/bin/logrotate-alertmanager.sh`:
```
#!/bin/bash
/usr/sbin/logrotate-s/var/lib/logrotate/status-alertmanager/etc/logrotate.d/alertmanager

```

    3. Make the script executable
```
chmod+x/usr/local/bin/logrotate-alertmanager.sh

```

    4. To schedule with Cron, add the following line to your crontab (crontab -e):
```
*/10****/usr/local/bin/logrotate-alertmanager.sh>>/tmp/alertmanager-rotate.log2>1

```

    5. Restart Alertmanager
```
systemctlrestartalertmanager

```



## Verify Control Center is running[](https://docs.confluent.io/control-center/current/installation/overview.html#verify-c3-short-is-running "Link to this heading")
After the installation is complete, visit `http(s)://<c3-url>:9021` and wait for the metrics to start showing up in Control Center. It may take a couple of minutes. Control Center looks exactly like Control Center (Legacy).
To confirm Control Center is running, use the following steps:
  1. Open the network tab in Control Center.
  2. Reload Control Center.
  3. Locate the following API call: `/2.0/feature/flags`
  4. Verify the following key is present in the response: `confluent.controlcenter.prometheus.enable: true`


## Confluent Ansible installation steps[](https://docs.confluent.io/control-center/current/installation/overview.html#ansible-short-installation-steps "Link to this heading")
For Confluent Ansible installation of Control Center, see [Configure Ansible Playbooks for Confluent Platform](https://docs.confluent.io/ansible/current/ansible-configure.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fcontrol-center%2Fcurrent%2Finstallation%2Foverview.html).
## Confluent for Kubernetes installation steps[](https://docs.confluent.io/control-center/current/installation/overview.html#co-long-installation-steps "Link to this heading")
For Confluent for Kubernetes (CFK) installation of Control Center, see [Monitor Confluent Platform with Confluent for Kubernetes](https://docs.confluent.io/operator/current/co-monitor-cp.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fcontrol-center%2Fcurrent%2Finstallation%2Foverview.html).
## High-availability setup[](https://docs.confluent.io/control-center/current/installation/overview.html#high-availability-setup "Link to this heading")
Use these steps to configure Control Center for Active/Active high-availability deployment. 

Considerations:
    
  * You must manually duplicate alerts in one of your Control Center instances.
  * For a Confluent Ansible example of Control Center Active/Active high-availability setup, see: [GitHub repo](https://github.com/confluentinc/cp-ansible/tree/d31730fa1b14db2833c40ad7308e89de9f96b734/docs/sample_inventories/c3-next-gen-active-active-setup)
  * For CFK example of Control Center Active/Active high-availability setup, see: [GitHub repo](https://github.com/confluentinc/confluent-kubernetes-examples/tree/master/control-center-next-gen/plain-active-active-setup)


To configure Control Center Active/Active high-availability, use the following steps:
  1. Configure two instances of Control Center for your Kafka cluster.
  2. For every Kafka broker and KRaft controller, you must add and configure two HttpExporters.
Consider the following example HttpExporter configurations:
```
confluent.telemetry.exporter._c3-1.client.base.url=http://{C3-1-internal-dns-hostname}:9090/api/v1/otlp

confluent.telemetry.exporter._c3-2.client.base.url=http://{C3-2-internal-dns-hostname}:9090/api/v1/otlp

```

     * Replace `{C3-1-internal-dns-hostname}` with the base URL for the corresponding Prometheus instance in your cluster.
  3. For every Kafka broker and KRaft controller, add the following configurations:
```
#common configs

confluent.telemetry.metrics.collector.interval.ms=60000
confluent.telemetry.remoteconfig._confluent.enabled=false
confluent.consumer.lag.emitter.enabled=true
metric.reporters=io.confluent.telemetry.reporter.TelemetryReporter

# instance 1 configs

confluent.telemetry.exporter._c3.type=http
confluent.telemetry.exporter._c3.enabled=true
confluent.telemetry.exporter._c3.client.base.url=http://{C3-1-internal-dns-hostname}:9090/api/v1/otlp
confluent.telemetry.exporter._c3.client.compression=gzip
confluent.telemetry.exporter._c3.api.key=dummy
confluent.telemetry.exporter._c3.api.secret=dummy
confluent.telemetry.exporter._c3.buffer.pending.batches.max=80
confluent.telemetry.exporter._c3.buffer.batch.items.max=4000
confluent.telemetry.exporter._c3.buffer.inflight.submissions.max=10
confluent.telemetry.exporter._c3.metrics.include=io.confluent.kafka.server.request.(?!.*delta).*|io.confluent.kafka.server.server.broker.state|io.confluent.kafka.server.replica.manager.leader.count|io.confluent.kafka.server.request.queue.size|io.confluent.kafka.server.broker.topic.failed.produce.requests.rate.1.min|io.confluent.kafka.server.tier.archiver.total.lag|io.confluent.kafka.server.request.total.time.ms.p99|io.confluent.kafka.server.broker.topic.failed.fetch.requests.rate.1.min|io.confluent.kafka.server.broker.topic.total.fetch.requests.rate.1.min|io.confluent.kafka.server.partition.caught.up.replicas.count|io.confluent.kafka.server.partition.observer.replicas.count|io.confluent.kafka.server.tier.tasks.num.partitions.in.error|io.confluent.kafka.server.broker.topic.bytes.out.rate.1.min|io.confluent.kafka.server.request.total.time.ms.p95|io.confluent.kafka.server.controller.active.controller.count|io.confluent.kafka.server.session.expire.listener.zookeeper.disconnects.total|io.confluent.kafka.server.request.total.time.ms.p999|io.confluent.kafka.server.controller.active.broker.count|io.confluent.kafka.server.request.handler.pool.request.handler.avg.idle.percent.rate.1.min|io.confluent.kafka.server.session.expire.listener.zookeeper.disconnects.rate.1.min|io.confluent.kafka.server.controller.unclean.leader.elections.rate.1.min|io.confluent.kafka.server.replica.manager.partition.count|io.confluent.kafka.server.controller.unclean.leader.elections.total|io.confluent.kafka.server.partition.replicas.count|io.confluent.kafka.server.broker.topic.total.produce.requests.rate.1.min|io.confluent.kafka.server.controller.offline.partitions.count|io.confluent.kafka.server.socket.server.network.processor.avg.idle.percent|io.confluent.kafka.server.partition.under.replicated|io.confluent.kafka.server.log.log.start.offset|io.confluent.kafka.server.log.tier.size|io.confluent.kafka.server.log.size|io.confluent.kafka.server.tier.fetcher.bytes.fetched.total|io.confluent.kafka.server.request.total.time.ms.p50|io.confluent.kafka.server.tenant.consumer.lag.offsets|io.confluent.kafka.server.session.expire.listener.zookeeper.expires.rate.1.min|io.confluent.kafka.server.log.log.end.offset|io.confluent.kafka.server.broker.topic.bytes.in.rate.1.min|io.confluent.kafka.server.partition.under.min.isr|io.confluent.kafka.server.partition.in.sync.replicas.count|io.confluent.telemetry.http.exporter.batches.dropped|io.confluent.telemetry.http.exporter.items.total|io.confluent.telemetry.http.exporter.items.succeeded|io.confluent.telemetry.http.exporter.send.time.total.millis|io.confluent.kafka.server.controller.leader.election.rate.(?!.*delta).*|io.confluent.telemetry.http.exporter.batches.failed

# instance 2 configs

confluent.telemetry.exporter._c3-2.type=http
confluent.telemetry.exporter._c3-2.enabled=true
confluent.telemetry.exporter._c3-2.client.compression=gzip
confluent.telemetry.exporter._c3-2.api.key=dummy
confluent.telemetry.exporter._c3-2.api.secret=dummy
confluent.telemetry.exporter._c3-2.buffer.pending.batches.max=80
confluent.telemetry.exporter._c3-2.buffer.batch.items.max=4000
confluent.telemetry.exporter._c3-2.buffer.inflight.submissions.max=10
confluent.telemetry.exporter._c3-2.client.base.url=http://{C3-2-internal-dns-hostname}:9090/api/v1/otlp
confluent.telemetry.exporter._c3-2.metrics.include=io.confluent.kafka.server.request.(?!.*delta).*|io.confluent.kafka.server.server.broker.state|io.confluent.kafka.server.replica.manager.leader.count|io.confluent.kafka.server.request.queue.size|io.confluent.kafka.server.broker.topic.failed.produce.requests.rate.1.min|io.confluent.kafka.server.tier.archiver.total.lag|io.confluent.kafka.server.request.total.time.ms.p99|io.confluent.kafka.server.broker.topic.failed.fetch.requests.rate.1.min|io.confluent.kafka.server.broker.topic.total.fetch.requests.rate.1.min|io.confluent.kafka.server.partition.caught.up.replicas.count|io.confluent.kafka.server.partition.observer.replicas.count|io.confluent.kafka.server.tier.tasks.num.partitions.in.error|io.confluent.kafka.server.broker.topic.bytes.out.rate.1.min|io.confluent.kafka.server.request.total.time.ms.p95|io.confluent.kafka.server.controller.active.controller.count|io.confluent.kafka.server.session.expire.listener.zookeeper.disconnects.total|io.confluent.kafka.server.request.total.time.ms.p999|io.confluent.kafka.server.controller.active.broker.count|io.confluent.kafka.server.request.handler.pool.request.handler.avg.idle.percent.rate.1.min|io.confluent.kafka.server.session.expire.listener.zookeeper.disconnects.rate.1.min|io.confluent.kafka.server.controller.unclean.leader.elections.rate.1.min|io.confluent.kafka.server.replica.manager.partition.count|io.confluent.kafka.server.controller.unclean.leader.elections.total|io.confluent.kafka.server.partition.replicas.count|io.confluent.kafka.server.broker.topic.total.produce.requests.rate.1.min|io.confluent.kafka.server.controller.offline.partitions.count|io.confluent.kafka.server.socket.server.network.processor.avg.idle.percent|io.confluent.kafka.server.partition.under.replicated|io.confluent.kafka.server.log.log.start.offset|io.confluent.kafka.server.log.tier.size|io.confluent.kafka.server.log.size|io.confluent.kafka.server.tier.fetcher.bytes.fetched.total|io.confluent.kafka.server.request.total.time.ms.p50|io.confluent.kafka.server.tenant.consumer.lag.offsets|io.confluent.kafka.server.session.expire.listener.zookeeper.expires.rate.1.min|io.confluent.kafka.server.log.log.end.offset|io.confluent.kafka.server.broker.topic.bytes.in.rate.1.min|io.confluent.kafka.server.partition.under.min.isr|io.confluent.kafka.server.partition.in.sync.replicas.count|io.confluent.telemetry.http.exporter.batches.dropped|io.confluent.telemetry.http.exporter.items.total|io.confluent.telemetry.http.exporter.items.succeeded|io.confluent.telemetry.http.exporter.send.time.total.millis|io.confluent.kafka.server.controller.leader.election.rate.(?!.*delta).*|io.confluent.telemetry.http.exporter.batches.failed

```



## Security configuration[](https://docs.confluent.io/control-center/current/installation/overview.html#security-configuration "Link to this heading")
Control Center introduces components like Prometheus and Alertmanager. The security configuration you use to secure communication for Control Center depends on the version of Confluent Platform you use.
**Considerations** :
  * Control Center supports TLS + Basic Auth for Confluent Platform versions 7.5.x and higher
  * Control Center supports mTLS for Confluent Platform versions 7.9.1 and higher


For more information, see [Control Center Security on Confluent Platform](https://docs.confluent.io/control-center/current/security/overview.html#security-control-center).
## Migration[](https://docs.confluent.io/control-center/current/installation/overview.html#migration "Link to this heading")
Migration of metrics from Control Center (Legacy) to Control Center is not supported. For migration of alerts, see [Control Center (Legacy) to Confluent Control Center Alert Migration](https://docs.confluent.io/control-center/current/installation/alert-migrate.html#alert-migration-c3).
**Considerations** :
  * For clusters where historical metrics are of no value, you can shut down Control Center (Legacy) as soon as Control Center is up and running.
  * For clusters where historical metrics are needed (say, for a period of N days), consider the following recommendations:
    * Run both Control Center (Legacy) and Control Center simultaneously for N days.
    * Control Center (Legacy) users should continue using Control Center (Legacy) until the N days of history is populated in Control Center.
    * Once historical metrics are available in Control Center, you can shut down Control Center (Legacy) and move users to Control Center.


By clicking “Accept All Cookies”, you agree to the storing of cookies on your device to enhance site navigation, analyze site usage, and assist in our marketing efforts. 
Accept All Cookies
Reject All
Cookies Settings

