[ Stream ](https://docs.confluent.io/platform/current/kafka-metadata/kraft.html)
[ Confluent Cloud Fully-managed data streaming platform with a cloud-native Kafka engine (KORA) for elastic scaling, with enterprise security, stream processing, governance. ](https://docs.confluent.io/cloud/current/get-started/index.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fplatform%2Fcurrent%2Fkafka-metadata%2Fkraft.html)[ Confluent Platform An on-premises enterprise-grade distribution of Apache Kafka with enterprise security, stream processing, governance. ](https://docs.confluent.io/platform/current/get-started/platform-quickstart.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fplatform%2Fcurrent%2Fkafka-metadata%2Fkraft.html)
[ Connect ](https://docs.confluent.io/platform/current/kafka-metadata/kraft.html)
[ Managed Use fully-managed connectors with Confluent Cloud to connect to data sources and sinks. ](https://docs.confluent.io/cloud/current/connectors/index.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fplatform%2Fcurrent%2Fkafka-metadata%2Fkraft.html)[ Self-Managed Use self-managed connectors with Confluent Platform to connect to data sources and sinks. ](https://docs.confluent.io/platform/current/connect/index.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fplatform%2Fcurrent%2Fkafka-metadata%2Fkraft.html)
[ Govern ](https://docs.confluent.io/platform/current/kafka-metadata/kraft.html)
[ Managed Use fully-managed Schema Registry and Stream Governance with Confluent Cloud. ](https://docs.confluent.io/cloud/current/stream-governance/index.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fplatform%2Fcurrent%2Fkafka-metadata%2Fkraft.html)[ Self-Managed Use self-managed Schema Registry and Stream Governance with Confluent Platform. ](https://docs.confluent.io/platform/current/schema-registry/index.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fplatform%2Fcurrent%2Fkafka-metadata%2Fkraft.html)
[ Process ](https://docs.confluent.io/platform/current/kafka-metadata/kraft.html)
[ Managed Use Flink on Confluent Cloud to run complex, stateful, low-latency streaming applications. ](https://docs.confluent.io/cloud/current/flink/index.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fplatform%2Fcurrent%2Fkafka-metadata%2Fkraft.html)[ Self-Managed Use Flink on Confluent Platform to run complex, stateful, low-latency streaming applications. ](https://docs.confluent.io/platform/current/flink/overview.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fplatform%2Fcurrent%2Fkafka-metadata%2Fkraft.html)
[Get Started Free](https://www.confluent.io/get-started/?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fplatform%2Fcurrent%2Fkafka-metadata%2Fkraft.html)
  1. [Configure and Manage Confluent Platform](https://docs.confluent.io/platform/current/administer.html)
  2. [Manage Kafka Clusters Using Confluent Platform](https://docs.confluent.io/platform/current/clusters/index.html)
  3. [Cluster Metadata Management in Confluent Platform](https://docs.confluent.io/platform/current/kafka-metadata/index.html)


Page Options
Copy MarkdownCopy as Markdown
Open as MarkdownOpen markdown in a new tab
# KRaft Overview for Confluent Platform[](https://docs.confluent.io/platform/current/kafka-metadata/kraft.html#kraft-overview-for-cp "Link to this heading")
Starting with Confluent Platform version 8.0, KRaft (pronounced craft) mode is how metadata is managed in Apache Kafka®.
Kafka Raft (KRaft) is the consensus protocol that greatly simplifies Kafka’s architecture by consolidating responsibility for metadata into Kafka itself.
The following image provides a simple illustration of Kafka running with KRaft managing metadata for the cluster. Each KRaft controller is a node in a Raft quorum, and each node is a broker that can handle client requests.
## The controller quorum[](https://docs.confluent.io/platform/current/kafka-metadata/kraft.html#the-controller-quorum "Link to this heading")
The KRaft controller nodes comprise a Raft quorum which manages the Kafka metadata log. This log contains information about each change to the cluster metadata. Metadata about topics, partitions, ISRs, configurations, and so on, is stored in this log.
Using the Raft consensus protocol, the controller nodes maintain consistency and leader election without relying on any external system. The leader of the metadata log is called the active controller. The active controller handles all RPCs made from the brokers. The follower controllers replicate the data which is written to the active controller, and serve as hot standbys if the active controller should fail. With the concept of a metadata log, brokers use offsets to keep track of the latest metadata stored in the KRaft controllers, which results in more efficient propagation of metadata and faster recovery from controller failovers.
KRaft requires a majority of nodes to be running. For example, a three-node controller cluster can survive one failure. A five-node controller cluster can survive two failures, and so on.
Periodically, the controllers will write out a snapshot of the metadata to disk. This is conceptually similar to compaction, but state is read from memory rather than re-reading the log from disk.
## Scaling Kafka with KRaft[](https://docs.confluent.io/platform/current/kafka-metadata/kraft.html#scaling-ak-with-kraft "Link to this heading")
There are two properties that determine the number of partitions an Kafka cluster can support: the per-node partition count limit and cluster-wide partition limit.
KRaft mode is designed to handle a large number of partitions per cluster, however Kafka’s scalability still primarily depends on adding nodes to get more capacity, so the cluster-wide limit still defines the upper bounds of scalability within the system.
In KRaft, the quorum controller reduces the time taken to move critical metadata in a controller failover scenario. The result of this change is a near-instantaneous controller failover. The following image shows the results of a Confluent lab experiment on a Kafka cluster running 2 million partitions, which is 10 times the maximum number of partitions for a cluster running ZooKeeper. The experiment shows that controlled shutdown time and recovery time after uncontrolled shutdown are greatly improved with a quorum controller versus ZooKeeper.
### Configure Confluent Platform with KRaft[](https://docs.confluent.io/platform/current/kafka-metadata/kraft.html#configure-cp-with-kraft "Link to this heading")
For details on how to configure Confluent Platform with KRaft, see [KRaft Configuration for Confluent Platform](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#configure-kraft).
Client configurations are not impacted by Confluent Platform moving to KRaft to manage metadata.
### Migrate from ZooKeeper to KRaft[](https://docs.confluent.io/platform/current/kafka-metadata/kraft.html#migrate-from-zk-to-kraft "Link to this heading")
If you haven’t already migrated to KRaft, see [Migrate from ZooKeeper to KRaft on Confluent Platform](https://docs.confluent.io/platform/current/installation/migrate-zk-kraft.html#migrate-zk-kraft). You must do this before you upgrade to Confluent Platform 8.0.
### Manage topic assignment to offline brokers[](https://docs.confluent.io/platform/current/kafka-metadata/kraft.html#manage-topic-assignment-to-offline-brokers "Link to this heading")
You can assign new topics to offline brokers. This behavior enables you to roll clusters when the cluster size equals the replication factor. For example, you can roll a cluster by shrinking it from 4 brokers to 3 brokers.
To prevent new topics from being assigned to offline brokers that are no longer considered part of the Confluent Platform cluster, unregister the broker using the [kafka-cluster](https://docs.confluent.io/kafka/operations-tools/kafka-tools.html#kafka-cluster-sh) command. This command calls the `UnregisterBroker` API and removes all traces of the broker from the cluster metadata.
To unregister a broker, run the following command:
```
kafka-clusterunregister--bootstrap-controller<controller-host:port>--id<broker-id>

```

To list brokers you may need to unregister, run the following command:
```
kafka-clusterlist-endpoints--bootstrap-controller<controller-host:port>

```

### Limitations and known issues[](https://docs.confluent.io/platform/current/kafka-metadata/kraft.html#limitations-and-known-issues "Link to this heading")
  * Combined mode, where a Kafka node acts as both a broker and a KRaft controller, is not currently supported by Confluent. You can start a new KRaft cluster in combined mode for testing purposes in development or testing environments. However, Confluent does not support migration to KRaft in combined mode or direct deployment in combined mode, even for development or test clusters. There are key security and feature gaps between combined mode and isolated mode in Confluent Platform.
  * Confluent Platform versions older than 7.9 do not support dynamic controllers, so you cannot add or remove KRaft controllers while the cluster is running. Confluent Platform 7.9 adds this feature, but only for clusters that were bootstrapped to use dynamic controllers. For more information, see [KIP-853](https://cwiki.apache.org/confluence/display/KAFKA/KIP-853%3A+KRaft+Controller+Membership+Changes). Confluent recommends three or five controllers for production. For hardware requirements, see [Hardware](https://docs.confluent.io/platform/current/installation/system-requirements.html#cp-hardware).
  * For information about upgrading from static controllers to dynamic controllers, and for the full KRaft server compatibility matrix showing static and dynamic controller support across Confluent Platform versions, see [KRaft server compatibility](https://docs.confluent.io/platform/current/installation/versions-interoperability.html#kraft-server-compatibility).
  * You cannot currently use [Schema Registry Topic ACL Authorizer for Confluent Platform](https://docs.confluent.io/platform/current/confluent-security-plugins/schema-registry/authorization/topicacl_authorizer.html#confluentsecurityplugins-topicacl-authorizer) for Schema Registry with Confluent Platform in KRaft mode. As an alternative, you can use [Schema Registry ACL Authorizer for Confluent Platform](https://docs.confluent.io/platform/current/confluent-security-plugins/schema-registry/authorization/sracl_authorizer.html#confluentsecurityplugins-sracl-authorizer) or [Configure Role-Based Access Control for Schema Registry in Confluent Platform](https://docs.confluent.io/platform/current/schema-registry/security/rbac-schema-registry.html#schemaregistry-rbac).
  * Currently, Health+ reports KRaft controllers as brokers and as a result, alerts may not function as expected.


## Broker behavior during controller failures[](https://docs.confluent.io/platform/current/kafka-metadata/kraft.html#broker-behavior-during-controller-failures "Link to this heading")
To operate a production cluster, you need to understand how KRaft behaves during failure scenarios. The following sections describe what happens when brokers lose connectivity to the controller quorum, or when the controller quorum itself cannot achieve consensus.
### Broker partition from the active controller[](https://docs.confluent.io/platform/current/kafka-metadata/kraft.html#broker-partition-from-the-active-controller "Link to this heading")
When one or more brokers are partitioned from the active controller (that is, they can’t successfully heartbeat to the active controller), the brokers continue to accept produce and consume requests from clients. However, brokers continuously attempt to reconnect to the active quorum controller.
Important
While brokers continue to serve client requests in this state, this state is not sustainable for an extended period. You should resolve the network partition or connectivity issue as soon as possible.
The following operations continue to work when brokers are partitioned from the active controller:
  * **Produce requests** : Brokers can continue to accept and process produce requests from clients for existing partitions. However, if the network partition also prevents data replication, producer requests requiring acknowledgments from other replicas (for example, `acks=all`) might time out.
  * **Consume requests** : Brokers can continue to serve consume requests from clients for existing partitions.


The following operations do not continue to work when brokers are partitioned from the active controller:
  * **ISR (In-Sync Replicas) changes** : The controller cannot update the ISR list for partitions, which means replicas cannot be added or removed from the ISR.
  * **Partition changes** : Partitions cannot be added to or removed from topics.
  * **Leadership re-elections** : Partition leadership cannot be reassigned, even if the current leader fails.
  * **Admin operations** : Topic configuration changes, topic creation and deletion, and other administrative operations do not succeed.
  * **Consumer group rebalancing** : Consumer groups cannot rebalance, which means new consumers cannot join groups and existing consumers cannot leave.
  * **Metadata updates** : Brokers cannot receive metadata updates from the controller, so they operate with stale metadata. This can lead to clients making decisions based on outdated information (for example, trying to produce to a stale leader).


### Loss of controller quorum[](https://docs.confluent.io/platform/current/kafka-metadata/kraft.html#loss-of-controller-quorum "Link to this heading")
When the controller quorum cannot achieve quorum (for example, when 2 out of 3 controller nodes are down), the active controller cannot be elected or maintained. In this scenario, the controller quorum is unable to process metadata changes, and brokers cannot successfully heartbeat to an active controller.
Similar to the broker partition scenario, brokers continue to accept produce and consume requests from clients while continuously attempting to reconnect to the controller quorum.
The following operations continue to work when the controller quorum is lost:
  * **Produce requests** : Brokers can continue to accept and process produce requests from clients for existing partitions. However, as the control plane is down, any failure requiring leader re-election or ISR changes will not be serviceable, and producers using `acks=all` might time out.
  * **Consume requests** : Brokers can continue to serve consume requests from clients for existing partitions.


However, the same limitations apply: ISR changes, partition changes, leadership re-elections, admin operations, consumer group rebalancing, and metadata updates do not work.
Important
This is a critical failure state that requires immediate attention. You should restore the controller quorum to a healthy state (where a majority of controllers are available) as soon as possible.
To prevent quorum loss, ensure you have an adequate number of controller nodes. As mentioned in the [controller quorum section](https://docs.confluent.io/platform/current/kafka-metadata/kraft.html#kraft-controller-quorum), a three-node controller cluster can survive one failure, and a five-node controller cluster can survive two failures. For production environments, always run at least three controllers, with three or five controllers is the recommended configuration.
## Related content[](https://docs.confluent.io/platform/current/kafka-metadata/kraft.html#related-content "Link to this heading")
  * [Metadata Management of Kafka in Confluent Platform](https://docs.confluent.io/platform/current/kafka-metadata/overview.html#zk-or-kraft)
  * [KRaft Configuration for Confluent Platform](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#configure-kraft)
  * [Migrate from ZooKeeper to KRaft on Confluent Platform](https://docs.confluent.io/platform/current/installation/migrate-zk-kraft.html#migrate-zk-kraft)
  * [KRaft: Apache Kafka Without ZooKeeper](https://developer.confluent.io/learn/kraft/?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fplatform%2Fcurrent%2Fkafka-metadata%2Fkraft.html)
  * [The Truth About ZooKeeper Removal and the KIP-500 Release in Apache Kafka (podcast)](https://developer.confluent.io/podcast/the-truth-about-zookeeper-removal-and-the-kip-500-release-in-apache-kafka-ft-jason-gustafson-and-colin-mccabe?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fplatform%2Fcurrent%2Fkafka-metadata%2Fkraft.html)
  * [A Kafkaesque Raft Protocol (video)](https://videos.confluent.io/watch/MNF8XK8ZgiYm8bEoinh1aC?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fplatform%2Fcurrent%2Fkafka-metadata%2Fkraft.html)


By clicking “Accept All Cookies”, you agree to the storing of cookies on your device to enhance site navigation, analyze site usage, and assist in our marketing efforts. 
Accept All Cookies
Reject All
Cookies Settings



---


[ Stream ](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html)
[ Confluent Cloud Fully-managed data streaming platform with a cloud-native Kafka engine (KORA) for elastic scaling, with enterprise security, stream processing, governance. ](https://docs.confluent.io/cloud/current/get-started/index.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fplatform%2Fcurrent%2Fkafka-metadata%2Fconfig-kraft.html)[ Confluent Platform An on-premises enterprise-grade distribution of Apache Kafka with enterprise security, stream processing, governance. ](https://docs.confluent.io/platform/current/get-started/platform-quickstart.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fplatform%2Fcurrent%2Fkafka-metadata%2Fconfig-kraft.html)
[ Connect ](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html)
[ Managed Use fully-managed connectors with Confluent Cloud to connect to data sources and sinks. ](https://docs.confluent.io/cloud/current/connectors/index.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fplatform%2Fcurrent%2Fkafka-metadata%2Fconfig-kraft.html)[ Self-Managed Use self-managed connectors with Confluent Platform to connect to data sources and sinks. ](https://docs.confluent.io/platform/current/connect/index.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fplatform%2Fcurrent%2Fkafka-metadata%2Fconfig-kraft.html)
[ Govern ](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html)
[ Managed Use fully-managed Schema Registry and Stream Governance with Confluent Cloud. ](https://docs.confluent.io/cloud/current/stream-governance/index.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fplatform%2Fcurrent%2Fkafka-metadata%2Fconfig-kraft.html)[ Self-Managed Use self-managed Schema Registry and Stream Governance with Confluent Platform. ](https://docs.confluent.io/platform/current/schema-registry/index.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fplatform%2Fcurrent%2Fkafka-metadata%2Fconfig-kraft.html)
[ Process ](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html)
[ Managed Use Flink on Confluent Cloud to run complex, stateful, low-latency streaming applications. ](https://docs.confluent.io/cloud/current/flink/index.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fplatform%2Fcurrent%2Fkafka-metadata%2Fconfig-kraft.html)[ Self-Managed Use Flink on Confluent Platform to run complex, stateful, low-latency streaming applications. ](https://docs.confluent.io/platform/current/flink/overview.html?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fplatform%2Fcurrent%2Fkafka-metadata%2Fconfig-kraft.html)
[Get Started Free](https://www.confluent.io/get-started/?session_ref=direct&url_ref=https%3A%2F%2Fdocs.confluent.io%2Fplatform%2Fcurrent%2Fkafka-metadata%2Fconfig-kraft.html)
  1. [Configure and Manage Confluent Platform](https://docs.confluent.io/platform/current/administer.html)
  2. [Manage Kafka Clusters Using Confluent Platform](https://docs.confluent.io/platform/current/clusters/index.html)
  3. [Cluster Metadata Management in Confluent Platform](https://docs.confluent.io/platform/current/kafka-metadata/index.html)


Page Options
Copy MarkdownCopy as Markdown
Open as MarkdownOpen markdown in a new tab
# KRaft Configuration for Confluent Platform[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#kraft-configuration-for-cp "Link to this heading")
This document covers hardware recommendations, configuration, debugging tools, and monitoring options for running Apache Kafka® in KRaft (pronounced craft) mode.
## Hardware and JVM requirements[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#hardware-and-jvm-requirements "Link to this heading")
A production KRaft server can cover a wide variety of use cases. In general, you should run KRaft on a server with similar specifications to the following:
  * Minimum of 4 GB of RAM
  * Dedicated CPU core should be considered when the server is shared
  * An SSD disk at least 64 GB in size is highly recommended
  * JVM heap size of at least 1 GB is recommended


Currently, it is recommended that you run at least three (3) KRaft controllers in production.
For more details, see [Hardware](https://docs.confluent.io/platform/current/installation/system-requirements.html#cp-hardware).
## Configuration options[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#configuration-options "Link to this heading")
Consider that a KRaft controller is also a Kafka broker processing event records that contain metadata related to the Kafka cluster. However, not all broker properties need to be set on controllers.
There are some settings that must be included for a cluster to run in KRaft mode, and are unique per server, but there are other settings that you configure for a controller because the controller process itself uses that property to perform its controller duties, or the property affects cluster metadata that controllers manage.
For a full list of configuration properties, see [Kafka Broker and Controller Configuration Reference for Confluent Platform](https://docs.confluent.io/platform/current/installation/configuration/broker-configs.html#cp-config-brokers).
Settings for KRaft mode are listed in the following sections with links to the configuration reference for those properties.
### Required settings[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#required-settings "Link to this heading")
These entries must be included for each server (controllers and brokers) running in KRaft mode.     
When you operate Apache Kafka® in KRaft mode, you must set the `process.roles` property. This property specifies whether the server acts as a controller, broker, or both, although currently both is not supported for production workloads. In KRaft mode, specific Kafka servers are selected to be controllers, storing metadata for the cluster in the metadata log, and other servers are selected to be brokers. The servers selected to be controllers will participate in the metadata quorum. Each controller is either an active or a hot standby for the current active controller.
In a production environment, the controller quorum will be deployed on multiple nodes. This is called an ensemble. An ensemble is a set of 2n + 1 controllers where n is any number greater than 0. The odd number of controllers allows the controller quorum to perform majority elections for leadership. At any given time, there can be up to n failed servers in an ensemble and cluster will keep quorum. For example, with three controllers, the cluster can tolerate one controller failure. If at any time, quorum is lost, the cluster will go down. For production, you should have typically have 3 or 5 controllers, but at least 3. For more information, see [Hardware](https://docs.confluent.io/platform/current/installation/system-requirements.html#cp-hardware).
  * Type: string
  * Default:
  * Importance: required for KRaft mode


`process.roles` can have the following values:
Value | Result  
---|---  
Not set | The server is assumed to be in ZooKeeper mode. This is not supported in Confluent Platform version 8.0 and later.  
`broker` | The server operates only as a broker.  
`controller` | The server operates in isolated mode as a controller only.  
`broker,controller` | The server operates in combined mode, where it is both a broker and a controller. Combined mode is for local experimentation only and is not supported by Confluent. For an example of combined mode, see the [confluent-local](https://docs.confluent.io/platform/current/installation/docker/config-reference.html#confluent-local-example) Docker image.       
The unique identifier for this server. Each node ID must be unique across all the brokers and controllers in a particular cluster. No two servers can have the same node ID regardless of their `process.roles` value. This identifier replaces `broker.id`, which was used when operating in ZooKeeper mode.
  * Type: int
  * Default:
  * Importance: required for KRaft mode



[controller.quorum.voters](https://docs.confluent.io/platform/current/installation/configuration/broker-configs.html#controller-quorum-voters)
    
A comma-separated list of quorum voters. All of the servers (controllers and brokers) in a Kafka cluster discover the quorum voters using this property, and you must identify all of the controllers by including them in the list you provide for the property.
Each controller is identified with their ID, host and port information in the format of `{id}@{host}:{port}`. Multiple entries are separated by commas and might look like the following:
`controller.quorum.voters=1@host1:port1,2@host2:port2,3@host3:port3`
The node ID supplied in the `controller.quorum.voters` property must match the corresponding ID on the controller servers. For example, on controller1, `node.id` must be set to . If a server is a broker only, its node ID should not appear in the `controller.quorum.voters` list.
Note
`controller.quorum.voters` is used for static controller configurations. For dynamic controller configurations (available in Confluent Platform 8.0 and later), use `controller.quorum.bootstrap.servers` instead. See [Upgrade from static controllers to dynamic controllers](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#upgrade-static-to-dynamic-controllers) for information on upgrading from static to dynamic controllers.
  * Type: string
  * Default:
  * Importance: required



[controller.quorum.bootstrap.servers](https://docs.confluent.io/platform/current/installation/configuration/broker-configs.html#controller-quorum-bootstrap-servers)
    
A comma-separated list of controller endpoints used for dynamic controller configurations. This property is used instead of `controller.quorum.voters` when running with dynamic controllers (`kraft.version=1` or later).
Each controller endpoint is specified with host and port information in the format of `{host}:{port}`. Multiple entries are separated by commas and might look like the following:
`controller.quorum.bootstrap.servers=controller1.example.com:9093,controller2.example.com:9093,controller3.example.com:9093`
Note
Dynamic controller configuration is available starting with Confluent Platform 8.0. To upgrade from static controllers to dynamic controllers, see [Upgrade from static controllers to dynamic controllers](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#upgrade-static-to-dynamic-controllers).
New clusters can be configured to use dynamic controllers from the start by using `controller.quorum.bootstrap.servers` during the initial bootstrap process, without any `controller.quorum.voters` configuration.
  * Type: string
  * Default:
  * Importance: required for dynamic controller configurations



[controller.listener.names](https://docs.confluent.io/platform/current/installation/configuration/broker-configs.html#controller-listener-names)
    
A comma-separated list of `listener_name` entries for listeners used by the controller. On a node with `process.roles=broker`, only the first listener in the list will be used by the broker. For KRaft controllers in isolated or combined mode, the node will listen as a KRaft controller on all listeners that are listed for this property, and each must appear in the `listeners` property. They shouldn’t appear in the `advertised.listeners` property.
  * Type: string
  * Default: null
  * Importance: required


### Inter-broker listeners[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#inter-broker-listeners "Link to this heading")
Listeners are an important part of your configuration. In addition to `controller.listener.names` described in the previous section, you should configure how KRaft controllers will communicate with brokers. This can be done with the `security.inter.broker.protocol` property or the `inter.broker.listener.name` property, but not both.
If `inter.broker.listener.name` is set then it will be used as a key for lookup in the `listener.security.protocol.map` property to yield a security protocol, otherwise `security.inter.broker.protocol` will be used. The default for `security.inter.broker.protocol` is `PLAINTEXT`, which is what will be used for communication with brokers if neither property is explicitly set.
Note that controllers do not listen at the `inter.broker.listener.name` value, but this property defines a listener that the brokers create, and controllers must specify in their security protocol and configuration so it can communicate with the brokers.
Following are descriptions of these properties: 

[inter.broker.listener.name](https://docs.confluent.io/platform/current/installation/configuration/broker-configs.html#inter-broker-listener-name)
    
The listener name that is used for inter-broker communication. If this is not set, inter-broker communication is defined by the `security.inter.broker.protocol` property. Set one of these, but not both, or an error will occur. This property must be set on KRaft brokers, but note that you must also set this property for KRaft controllers because controllers sometimes need to talk to Kafka brokers in Confluent Platform.
The inter-broker listener name for a controller node **must not** appear in `controller.listener.names` property, and this applies regardless of whether the node is a controller in isolated or combined mode. Following is an example configuration file for a KRaft controller that shows how to configure this property as well as the security map for the listener.
```
process.roles=controller
node.id=100
controller.quorum.voters=100@node1:9093,101@node2:9093,102@node3:9093
controller.listener.names=CONTROLLER
listeners=CONTROLLER://:9093
inter.broker.listener.name=BROKER
listener.security.protocol.map=CONTROLLER:SSL,BROKER:SSL

# Define the controller's listener and how we will use it.
listener.name.controller.ssl.keystore.location=/some/keystore/path
listener.name.controller.ssl.truststore.location=/some/truststore/path
# etc...

# Define how we will use the broker's listener.
# No keystore needed since the controller isn't listening here; only need a truststore.
listener.name.broker.ssl.truststore.location=/some/truststore/path
# etc...

```


[listener.security.protocol.map](https://docs.confluent.io/platform/current/installation/configuration/broker-configs.html#listener-security-protocol-map)
    
The security protocol to use for inter-broker communication specified by the `inter.broker.listener.name` property. The security protocol to use for the declared listener names. Note that this includes controller-to-broker communication with the listener identified by the `inter.broker.listener.name` property for the controller. 

[security.inter.broker.protocol](https://docs.confluent.io/platform/current/installation/configuration/broker-configs.html#security-inter-broker-protocol)
    
Security protocol used to communicate between brokers. Set this property or `inter.broker.listener.name`, but not both.
### Other listeners and logs[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#other-listeners-and-logs "Link to this heading")
Following are additional properties you should be familiar with.     
A comma-separated list of addresses where the socket server listens.
For controllers in isolated mode: Only controller listeners are allowed in this list when `process.roles=controller`, and this listener should be consistent with `controller.quorum.voters` value. If not configured, the host name will be equal to the value of `java.net.InetAddress.getCanonicalHostName()` with the `PLAINTEXT` listener name, and port `9092`.
For controllers in combined mode, you should list the controller listeners as well as the broker listeners. For brokers: see [listeners](https://docs.confluent.io/platform/current/installation/configuration/broker-configs.html#listeners).
  * Type: string with the format `listener_name://host_name:port`
  * Default: If not configured, the host name will be equal to the value of `java.net.InetAddress.getCanonicalHostName()`, with `PLAINTEXT` listener name, and port `9092`. Example: `listeners=PLAINTEXT://your.host.name:9092`
  * Importance: high

    
Use to specify where the metadata log for clusters in KRaft mode is placed after storage is formatted as described in [Generate and format IDs](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#generate-format-ids). If not set, the metadata log is placed in the first log directory specified in the `log-dirs` property described below.
  * Type: string
  * Default: null
  * Importance: high

    
If `metadata.log.dir` is not specified, the KRaft metadata log is placed in the first log directory specified by this property after storage is formatted as described in [Generate and format IDs](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#generate-format-ids).
  * Type: string
  * Default: null
  * Importance: high


### Controller configuration example[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#controller-configuration-example "Link to this heading")
You can find the example KRaft configuration files in `/etc/kafka/`. You will see three different example files in this folder after you install Confluent Platform:
  * `broker.properties` - An example of the settings to use when the server is a broker only.
  * `controller.properties` - An example of the settings to use when the server is a controller only.
  * `server.properties` - An example of the settings to use when the server is both a broker and a controller. This configuration is not supported for production use.


Following is an example excerpt from a properties file for a controller on a system with three controllers.
```
############################# Server Basics #############################

# The role of this server. Setting this puts us in KRaft mode.
process.roles=controller

# The node id associated with this instance's roles.
node.id=1

# The connect string for the controller quorum.
controller.quorum.voters=1@controller1.example.com:9093,2@controller2.example.com:9093,3@controller3.example.com:9093

############################# Socket Server Settings #############################

# The address the socket server listens on.
# Note that only the controller listeners are allowed here when `process.roles=controller`, and this listener should be consistent with `controller.quorum.voters` value.
#   FORMAT:
#     listeners = listener_name://host_name:port
#   EXAMPLE:
#     listeners = PLAINTEXT://your.host.name:9092
listeners=CONTROLLER://controller1.example.com:9093

# A comma-separated list of the names of the listeners used by the controller.
# This is required if running in KRaft mode.
controller.listener.names=CONTROLLER

# How to communicate with brokers.
inter.broker.listener.name=BROKER

# Maps listener names to security protocols, the default is for them to be the same.
listener.security.protocol.map=CONTROLLER:SSL,BROKER:SSL

############################# Log Basics #############################

# A comma separated list of directories under which to store log files
log.dirs=/tmp/kraft-controller-logs


# ... # Additional property settings to match broker settings.

```

### Security[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#security "Link to this heading")
For configuring SASL/SCRAM for broker-to-broker communication, see [KRaft-based Confluent Platform clusters](https://docs.confluent.io/platform/current/security/authentication/sasl/scram/overview.html#sasl-scram-kraft-based-clusters). For general security information for KRaft, see [KRaft Security in Confluent Platform](https://docs.confluent.io/platform/current/security/component/kraft-security.html#kraft-security).
### Other properties[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#other-properties "Link to this heading")
KRaft controllers need a property only if:
  1. The controller process itself uses that property to perform its controller duties, or
  2. The property affects cluster metadata that controllers manage


Brokers handle everything else—even if it’s cluster-wide configuration. If a property is only consumed by brokers for data-plane operations (like reading or writing data), it does not need to be in the controller’s configuration file.
For example:
  * `confluent.schema.registry.url`: Controllers need this because Schema Registry integration affects metadata operations that controllers coordinate. Controllers must validate schema references during topic creation and modification, which is a metadata-layer function.
  * `confluent.tier.enable`: Controllers don’t need this because tiered storage is a broker-only, data-plane feature. Tiered storage operations (uploading and downloading segments to object storage) are only broker responsibilities.


Based on this rule, many properties related to topic management and cluster-wide behavior must be present on the controllers because they affect cluster metadata that controllers manage. This includes security properties such as the truststore locations needed for secure communication with brokers.
The following list provides an example of common settings that are required on KRaft controllers because they relate to cluster metadata. This is not an exhaustive list.
  * `auto.create.topics.enable`
  * `compression.type`
  * `confluent.metrics.reporter.bootstrap.servers`
  * `confluent.license.topic.replication.factor`
  * `confluent.metadata.topic.replication.factor`
  * `default.replication.factor`
  * `delete.topic.enable`
  * `message.max.bytes`
  * `metrics.reporters`
  * `min.insync.replicas`
  * `num.partitions`
  * `offsets.retention.minutes`
  * `offsets.topic.replication.factor`
  * `transaction.state.log.replication.factor`
  * `transaction.state.log.min.isr`
  * `unclean.leader.election.enable`


## Settings for other Kafka and Confluent Platform components[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#settings-for-other-ak-and-cp-components "Link to this heading")
You must use current, non-deprecated, configurations settings. The settings to use are described in the following table.
Feature | Allowed with ZooKeeper | Required with KRaft  
---|---|---  
Clients and services | `zookeeper.connect=zookeeper:2181` | `bootstrap.servers=broker:9092`  
Schema Registry | `kafkastore.connection.url=zookeeper:2181` | `kafkastore.bootstrap.servers=broker:9092`  
Administrative tools | `kafka-topics --zookeeper zookeeper:2181` (deprecated) |  

`kafka-topics --bootstrap-server broker:9092` …
    `--command-config properties` to connect to brokers  
Retrieve Kafka cluster ID | `zookeeper-shell zookeeper:2181 get/cluster/id` | From the command line, use `kafka-metadata-quorum` (See [kafka-metadata-quorum](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#describe-runtime-status)) or `confluent cluster describe --url`, or view `metadata.properties`. or `http://broker:8090 --output json`  
## Generate and format IDs[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#generate-and-format-ids "Link to this heading")
Before you start Kafka, you must use the [kafka-storage](https://docs.confluent.io/kafka/operations-tools/kafka-tools.html#kafka-storage-sh) tool with the `random-uuid` command to generate a cluster ID for each new cluster. You only need one cluster ID, which you will use to format each node in the cluster.
```
bin/kafka-storage random-uuid

```

This results in output like the following:
```
q1Sh-9_ISia_zwGINzRvyQ

```

Then use the cluster ID to format storage for each node in the cluster with the `kafka-storage` tool that is provided with Confluent Platform, and the `format` command like the following example, specifying the properties file for a controller.
```
bin/kafka-storage format -t q1Sh-9_ISia_zwGINzRvyQ -c etc/kafka/controller.properties

```

Previously, Kafka would format blank storage directories automatically and generate a new cluster ID automatically. One reason for the change is that auto-formatting can sometimes obscure an error condition. This is particularly important for the metadata log maintained by the controller and broker servers. If a majority of the controllers were able to start with an empty log directory, a leader might be able to be elected with missing committed data. To configure the log directory, either set `metadata.log.dir` or `log.dirs`. For more information, see [Inter-broker listeners](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#kraft-log-settings).
### Configure SCRAM[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#configure-scram "Link to this heading")
To configure SCRAM for brokers in a Kafka cluster running in KRaft mode, you must create the credentials before your brokers are up and running. You then use the `--add-scram` option with the `kafka-storage` tool. For more information, see [SASL for KRaft-based clusters](https://docs.confluent.io/platform/current/security/authentication/sasl/scram/overview.html#sasl-scram-kraft-based-clusters).
## Upgrade from static controllers to dynamic controllers[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#upgrade-from-static-controllers-to-dynamic-controllers "Link to this heading")
Confluent Platform 8.0 and later supports upgrading a KRaft cluster from a static controller configuration to a dynamic controller configuration.
Dynamic controllers provide significantly greater operational flexibility. Unlike the static approach, a dynamic configuration allows you to add or remove controllers from a running cluster without updating configuration files on all nodes or performing a full cluster restart. See [KRaft server compatibility](https://docs.confluent.io/platform/current/installation/versions-interoperability.html#kraft-server-compatibility) for compatibility information.
### Static versus dynamic quorums[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#static-versus-dynamic-quorums "Link to this heading")
Understanding the difference in configuration is key to the upgrade process.
  * **Static quorum (original approach)** : Requires the `controller.quorum.voters` property on every broker and controller. This list must explicitly specify the IDs, hostnames, and ports of all controllers. You cannot modify the quorum without updating this configuration on every node and restarting them.
  * **Dynamic quorum (recommended)** : Uses the `controller.quorum.bootstrap.servers` property instead. Much like the `bootstrap.servers` configuration used by Kafka clients, this key does not need to list every controller—only enough to allow servers to locate the quorum. This enables you to change the controller set dynamically while the cluster is running.


### Prerequisites[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#prerequisites "Link to this heading")
Before starting the upgrade, ensure that:
  * Your cluster is running Confluent Platform 8.0 or later.
  * All brokers and controllers are running and healthy.
  * You have a backup of your cluster configuration.


### Verify current KRaft version[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#verify-current-kraft-version "Link to this heading")
Dynamic controller clusters are added in KRaft version (Kafka 4.0). To determine which KRaft feature version your cluster is using, execute the following CLI command:
```
bin/kafka-features.sh--bootstrap-controllerlocalhost:9093describe

```

If the `kraft.version` field shows `FinalizedVersionLevel: 0` or is absent, you are using a static quorum. If it shows `FinalizedVersionLevel: 1` or above, you are using a dynamic quorum.
Example output for a static quorum:
```
Feature: kraft.version  SupportedMinVersion: 0  SupportedMaxVersion: 1  FinalizedVersionLevel: 0  Epoch: 9

```

Example output for a dynamic quorum:
```
Feature: kraft.version  SupportedMinVersion: 0  SupportedMaxVersion: 1  FinalizedVersionLevel: 1  Epoch: 9

```

### Upgrade KRaft version[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#upgrade-kraft-version "Link to this heading")
If your `FinalizedVersionLevel` is , you must upgrade the feature level before changing configurations If `FinalizedVersionLevel` is , you can skip to [Update KRaft configuration](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#update-kraft-config).
To upgrade the KRaft version from to , use the `kafka-features` tool:
```
bin/kafka-features.sh--bootstrap-controllerlocalhost:9093upgrade--featurekraft.version=1

```

After the upgrade completes, verify the new version:
```
bin/kafka-features.sh--bootstrap-controllerlocalhost:9093describe

```

The output should show `FinalizedVersionLevel: 1` for `kraft.version`:
```
Feature: kraft.version  SupportedMinVersion: 0  SupportedMaxVersion: 1  FinalizedVersionLevel: 1        Epoch: 8

```

### Update KRaft configuration[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#update-kraft-configuration "Link to this heading")
After upgrading the KRaft version, you must update the configuration on all brokers and controllers to use `controller.quorum.bootstrap.servers` instead of `controller.quorum.voters`.
  1. Update controller configuration on each controller node:
    1. Remove or comment out the `controller.quorum.voters` property.
    2. Add the `controller.quorum.bootstrap.servers` property with a comma-separated list of controller endpoints.
The `controller.quorum.bootstrap.servers` property should contain as many controller endpoints as possible so that all servers can locate the quorum. Unlike `controller.quorum.voters`, this property does not need to contain all controllers, but it should contain enough to ensure connectivity.
Example `server.properties` file configuration:
```
# Remove or comment out:
# controller.quorum.voters=1@controller1.example.com:9093,2@controller2.example.com:9093,3@controller3.example.com:9093

# Add:
controller.quorum.bootstrap.servers=controller1.example.com:9093,controller2.example.com:9093,controller3.example.com:9093

```

  2. Update broker configuration on each broker node:
    1. Remove or comment out the `controller.quorum.voters` property.
    2. Add the `controller.quorum.bootstrap.servers` property with the same list of controller endpoints.
  3. Restart all nodes:
    1. Restart each controller node, one at a time, allowing each to fully start before restarting the next.
    2. After all controllers are restarted and healthy, restart each broker, one at a time.
  4. Verify the upgrade by running the following command:
```
bin/kafka-metadata-quorum.sh--bootstrap-serverlocalhost:9092describe--status

```

The cluster should show the same number of controllers as before, and all should be listed as `CurrentVoters`.
```
ClusterId:M51W2LQQSRiDQ1tA0l8tew
LeaderId:1
LeaderEpoch:1
HighWatermark:148595
MaxFollowerLag:0
MaxFollowerLagTimeMs:0
CurrentVoters:[{"id":1,"directoryId":"QWOv0BvKQP2KwR_5kMXYUA","endpoints":["CONTROLLER://localhost:9093"]}]
CurrentObservers:[{"id":2,"directoryId":"R5VtfFv_hW-tlqYssdW7iw"}]

```



## Controller membership changes[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#controller-membership-changes "Link to this heading")
After upgrading to dynamic controllers, you can add or remove controllers from your cluster without updating configuration files on all nodes or performing a full cluster restart.
### Add a new controller[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#add-a-new-controller "Link to this heading")
If a dynamic controller cluster already exists, it can be expanded by first provisioning a new controller using the `kafka-storage.sh` tool and starting the controller. After starting the controller, the replication to the new controller can be monitored using the `bin/kafka-metadata-quorum.sh describe --replication` command. Once the new controller has caught up to the active controller, it can be added to the cluster using the `bin/kafka-metadata-quorum.sh add-controller` command.
To add a new controller:
  1. Provision the new controller node with the appropriate configuration. For details about required configuration properties, see [Required settings](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#server-basics).
  2. Format the storage directory for the new controller using the `kafka-storage` tool. For information about formatting storage, including the `--no-initial-controllers` flag, see [Generate and format IDs](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#generate-format-ids).
  3. Start the new controller and allow it to start up.
  4. Monitor the replication status to ensure the new controller catches up to the active controller:
When using broker endpoints:
```
bin/kafka-metadata-quorum.sh--bootstrap-serverlocalhost:9092describe--replication

```

When using controller endpoints:
```
bin/kafka-metadata-quorum.sh--bootstrap-controllerlocalhost:9093describe--replication

```

  5. Once the new controller has caught up to the active controller, add it to the cluster using the `kafka-metadata-quorum` tool.
When using broker endpoints:
```
bin/kafka-metadata-quorum.sh--command-configconfig/controller.properties--bootstrap-serverlocalhost:9092add-controller

```

When using controller endpoints:
```
bin/kafka-metadata-quorum.sh--command-configconfig/controller.properties--bootstrap-controllerlocalhost:9093add-controller

```



### Remove a controller[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#remove-a-controller "Link to this heading")
If the dynamic controller cluster already exists, it can be shrunk using the `bin/kafka-metadata-quorum.sh remove-controller` command. It is recommended to shutdown the controller that will be removed before running the remove-controller command.
You can obtain the controller ID and directory ID from the `kafka-metadata-quorum.sh describe --status` command output. For more information, see [Describe runtime status](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#describe-runtime-status).
When using broker endpoints:
```
bin/kafka-metadata-quorum.sh--bootstrap-serverlocalhost:9092remove-controller--controller-id<id>--controller-directory-id<directory-id>

```

When using controller endpoints:
```
bin/kafka-metadata-quorum.sh--bootstrap-controllerlocalhost:9092remove-controller--controller-id<id>--controller-directory-id<directory-id>

```

## Tools for debugging KRaft mode[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#tools-for-debugging-kraft-mode "Link to this heading")
Kafka provides tools to help you debug a cluster running in KRaft-mode.
### Describe runtime status[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#describe-runtime-status "Link to this heading")
You can describe the runtime state of the cluster metadata partition using the [kafka-metadata-quorum tool](https://docs.confluent.io/kafka/operations-tools/kafka-tools.html#kafka-metadata-quorum-sh) and specify either a Kafka broker with the `--bootstrap-server` option or a KRaft controller with the `--bootstrap-controller` option.
For example, the following command specifies a broker and displays a summary of the metadata quorum:
```
bin/kafka-metadata-quorum --bootstrap-server  host1:9092 describe --status

```

```
Output might look like the following:

   ClusterId:              fMCL8kv1SWm87L_Md-I2hg
   LeaderId:               3002
   LeaderEpoch:            2
   HighWatermark:          10
   MaxFollowerLag:         0
   MaxFollowerLagTimeMs:   -1
   CurrentVoters:          [3000,3001,3002]
   CurrentObservers:       [0,1,2]

```

You can specify a controller with the `--bootstrap-controller` option. This is useful when the brokers are not accessible.
```
bin/kafka-metadata-quorum --bootstrap-controller  host1:9093 describe --status

```

### Debug log segments[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#debug-log-segments "Link to this heading")
The [kafka-dump-log tool](https://docs.confluent.io/kafka/operations-tools/kafka-tools.html#kafka-dump-log-sh) tool can be used to debug the log segments and snapshots for the cluster metadata directory. The tool will scan the provided files and decode the metadata records. For example, the following command decodes and prints the records in the first log segment:
```
bin/kafka-dump-log --cluster-metadata-decoder --files tmp/kraft-controller-logs/_cluster_metadata-0/00000000000000023946.log

```

### Inspect the metadata partition[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#inspect-the-metadata-partition "Link to this heading")
You can use the `kafka-metadata-shell` to inspect the metadata partition.
The Kafka version of the `kafka-metadata-shell` tool enables you to interactively examine the metadata stored in a KRaft cluster. To analyze metadata, point the `kafka-metadata-shell` tool to a log directory, run the `kafka-metadata-shell.sh` command, using the `--directory` flag to specify the path to your cluster metadata log.
```
./kafka-metadata-shell.sh--directory/tmp/kraft-combined-logs/__cluster_metadata-0/

```

Once the shell loads, you can use commands like and `cat` to explore the metadata records. For more information, see [kafka-metadata-shell tool](https://docs.confluent.io/kafka/operations-tools/kafka-tools.html#kafka-metadata-shell.sh).
The Confluent Platform version of `kafka-metadata-shell` includes additional options for connecting directly to a running controller, which is necessary for clusters using security features like SSL/TLS.
The following is the help output for the `kafka-metadata-shell` tool.
```
kafka-metadata-shell.sh--help

usage:kafka-metadata-shell.sh[-h][--cluster-idCLUSTER_ID][--offsetOFFSET][--configCONFIG](--directoryDIRECTORY|
--controllersCONTROLLERS)[command[command...]]

TheApacheKafkametadatashelltool

positionalarguments:
commandThecommandtorun.

optionalarguments:
-h,--helpshowthishelpmessageandexit
--cluster-idCLUSTER_ID,-tCLUSTER_ID
Theclusterid.Requiredwhenusing--controllers
--directoryDIRECTORY,-dDIRECTORY
The__cluster_metadata-0directorytoread.
--controllersCONTROLLERS,-qCONTROLLERS
Thecontroller.quorum.voters.
--offsetOFFSET,-oOFFSET
The(exclusive)offsettoreadupto
--configCONFIGPathtopropertyfilecontainingaKafkaconfiguration

```

You use the `--config` flag to point to a client properties file that contains your security settings.
**Example: Connecting to a controller over SSL**
The following example shows how to connect to a controller that’s configured to require SSL on its listener.
  1. Create a client configuration file. This file contains the properties the shell needs to authenticate with the controller.


```
# client.properties

# Maps the listener name from the server to the SSL security protocol.
listener.security.protocol.map=CONTROLLER:SSL,PLAINTEXT:PLAINTEXT

# Provides the location and password for your client's truststore.
ssl.truststore.location=/path/to/your/truststore.jks
ssl.truststore.password=your-password
ssl.truststore.type=JKS

```

  1. Run the `kafka-metadata-shell` command, pointing to your controller, cluster ID, and the new client configuration file:


```
./bin/kafka-metadata-shell\
--cluster-idyour-cluster-id\
--controllerscontroller-host:9593\
--config/path/to/your/client.properties

```

The shell uses the properties in the config file to establish a secure, trusted connection to the controller.
### Check migration status[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#check-migration-status "Link to this heading")
You can check the migration status of a KRaft cluster using Confluent-provided `kafka-migration-check` tool. This tool is included in Confluent Platform 7.9.2 or later, and can be found in the `bin` directory of your Confluent Platform installation. For detailed instructions on how to run this tool, see [Check Clusters for KRaft Migration](https://docs.confluent.io/platform/current/tools/kraft-migration-tool.html#kraft-migration-tool).
## Monitor KRaft[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#monitor-kraft "Link to this heading")
Following are some JMX metrics to monitor on the controller and broker when operating in KRaft mode. Some of the metrics depend on the setting for [process.roles](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#server-basics).
For more broker metrics, see [Broker metrics](https://docs.confluent.io/platform/current/kafka/broker-metrics.html#kafka-monitoring-metrics-broker).
### KRaft quorum monitoring metrics[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#kraft-quorum-monitoring-metrics "Link to this heading")
The following table lists KRaft controller quorum metrics.
`kafka.server:type=raft-metrics` MBean name | Description  
---|---  
`append-records-rate` | The average number of records appended per second by the leader of the raft quorum.  
`commit-latency-avg` | The average time in milliseconds to commit an entry in the raft log.  
`commit-latency-max` | The maximum time in milliseconds to commit an entry in the raft log.  
`current-epoch` | The current quorum epoch.  
`current-leader` | The current quorum leader’s id; -1 indicates unknown.  
`current-state` | The current state of this member; possible values are leader, candidate, voted, follower, unattached, observer.  
`current-vote` | The current voted leader’s id; -1 indicates not voted for anyone.  
`election-latency-avg` | The average time in milliseconds spent on electing a new leader.  
`election-latency-max` | The maximum time in milliseconds spent on electing a new leader.  
`fetch-records-rate` | The average number of records fetched from the leader of the raft quorum.  
`high-watermark` | The high watermark maintained on this member; -1 if it is unknown.  
`log-end-offset` | The current raft log end offset.  
`number-unknown-voter-connections` | Number of unknown voters whose connection information is not cached. This value of this metric is always 0.  
`poll-idle-ratio-avg` | The average fraction of time the client’s poll() is idle as opposed to waiting for the user code to process records.  
Other quorum metrics:
MBean | Description  
---|---  
`kafka.server:type=MetadataLoader,name=CurrentMetadataVersion` | Outputs the feature level of the current metadata version.  
`kafka.server:type=MetadataLoader,name=HandleLoadSnapshotCount` | The total number of times that a KRaft snapshot has been loaded since the process was started.  
`kafka.server:type=SnapshotEmitter,name=LatestSnapshotGeneratedBytes` | The total size in bytes of the latest snapshot that the node has generated. If a snapshot has not been generated yet, this is the size of the latest snapshot that was loaded. If no snapshots have been generated or loaded, this is 0.  
`kafka.server:type=SnapshotEmitter,name=LatestSnapshotGeneratedAgeMs` | The interval in milliseconds since the latest snapshot was generated. If no snapshot has been generated yet, this is the approximate time delta since the process was started.  
### Controller metrics[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#controller-metrics "Link to this heading")
With KRaft, Kafka adds a controller quorum to the cluster. These controllers must be able to commit records for Kafka to be available so you need to monitor their health.
For the full list of KRaft metrics, see [KRaft broker metrics](https://docs.confluent.io/platform/current/kafka/broker-metrics.html#kraft-broker-metrics) and [KRaft Quorum metrics](https://docs.confluent.io/platform/current/kafka/broker-metrics.html#kraft-quorum-metrics).
`kafka.controller:type=KafkaController` MBean name | Description  
---|---  
`ActiveBrokerCount` | When using KRaft, the number of registered and unfenced brokers as observed by this controller. When using ZooKeeper, this value is the number of brokers known to the controller.  
`ActiveControllerCount` | The number of active controllers on this node. Valid values are ‘0’ or ‘1’. Alert if the aggregated sum across all brokers in the cluster is anything other than 1 because there should be exactly one controller per cluster.  
`FencedBrokerCount` | When using KRaft, the number of registered but fenced brokers as observed by this controller.  
`GlobalPartitionCount` | The number of all partitions in the cluster as observed by this controller.  
`GlobalTopicCount` | The number of all topics in the cluster as observed by this controller.  
`LastAppliedRecordLagMs` | Reports the difference between the local time and the append time of the last applied record batch. For active controllers the value of this lag is always zero.  
`LastAppliedRecordOffset` | The offset of the last record that was applied by the controller to the cluster metadata partition. For the active controller this may include uncommitted records. For the inactive controller this always includes committed records only.  
`LastAppliedRecordTimestamp` | The timestamp of the last record that was applied by the controller to the cluster metadata partition.  
`LastCommittedRecordOffset` | The active controller reports the offset of the last committed offset it consumed. Inactive controllers will always report the same value as `LastAppliedRecordOffset`. You can monitor the last committed offsets to see that they are advancing. You can also use these metrics to check that all of the brokers and controllers are at a similar offset.  
`LastAppliedRecordTimestamp` | The timestamp of the last record that was applied by the controller to the cluster metadata partition.  
`MetadataErrorCount` | The number of times this controller node has encountered an error during metadata log processing.  
`NewActiveControllerCount` | Counts the number of times this node has seen a new controller elected. A transition to the “no leader” state is not counted here. If the same controller as before becomes active, that still counts.  
`EventQueueOperationsStartedCount` | The total number of controller event queue operations that were started. This count includes deferred operations.  
`EventQueueOperationsTimedOutCount` | The total number of controller event queue operations that timed out before they could be performed.  
`OfflinePartitionsCount` | The number of offline topic partitions (non-internal) as observed by this controller.  
`PreferredReplicaImbalanceCount` | The count of topic partitions for which the leader is not the preferred leader.  
`TimedOutBrokerHeartbeatCount` | The number of broker heartbeats that timed out on this controller since the process was started. Note that only active controllers handle heartbeats, so only they will see increases in this metric.  
ControllerEventManager metrics:
`kafka.controller:type=ControllerEventManager` MBean name | Description  
---|---  
`EventQueueProcessingTimeMs` | A histogram of the time in milliseconds that requests spent being processed in the controller event queue.  
`EventQueueTimeMs` | A histogram of the time in milliseconds that requests spent waiting in the controller event queue.  
### Raft Controller metrics[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#raft-controller-metrics "Link to this heading")
In KRaft mode, use these metrics to get insights into the Raft protocol’s performance and health.
`kafka.raft:type=KafkaRaftServer` MBean name | Description  
---|---  
`CurrentLeader` | The current leader’s broker ID. Alarm if this value is -1 (no leader) for more than 30 seconds. You should also monitor for frequent changes in this value, which can indicate instability.  
`CurrentVotedCandidate` | The broker ID of the candidate this node voted for in the current term.  
`CurrentTerm` | The current term of the Raft state machine.  
`LastAppliedRecordOffset` | The offset of the last record applied to the state machine.  
### KRaft Broker metrics[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#kraft-broker-metrics "Link to this heading")
`kafka.server:type=broker-metadata-metrics` MBean name | Description  
---|---  
`last-applied-record-offset` | The offset of the last record from the cluster metadata partition that was applied by the broker.  
`last-applied-record-timestamp` | The timestamp of the last record from the cluster metadata partition that was applied by the broker.  
`last-applied-record-lag-ms` | The difference between now and the timestamp of the last record from the cluster metadata partition that was applied by the broker.  
`metadata-load-error-count` | The number of errors encountered by the `BrokerMetadataListener` while loading the metadata log and generating a new metadata delta based on it.  
`metadata-apply-error-count` | The number of errors encountered by the `BrokerMetadataPublisher` while applying a new metadata imaged based on the latest metadata delta.  
## Related content[](https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html#related-content "Link to this heading")
  * [KRaft Overview for Confluent Platform](https://docs.confluent.io/platform/current/kafka-metadata/kraft.html#kraft-overview)
  * [Quick Start for Confluent Platform](https://docs.confluent.io/platform/current/get-started/platform-quickstart.html#quickstart)
  * [ZooKeeper Topic Guide](https://docs.confluent.io/platform/current/kafka-metadata/zk-production.html#zk-prod-deployment)


By clicking “Accept All Cookies”, you agree to the storing of cookies on your device to enhance site navigation, analyze site usage, and assist in our marketing efforts. 
Accept All Cookies
Reject All
Cookies Settings

