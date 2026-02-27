<!-- source: top-storage-c.html -->

Storage 
## 
This document describes the model used in Kubernetes for managing persistent, cluster-scoped
      storage for workloads requiring access to persistent data. 
A workload on Kubernetes typically requires the following types of storage: 
Ephemeral Storage 
Persistent Volume 
Objects 
## Ephemeral Storage 
Ephemeral storage, by its name, is ephemeral because it is cleaned up when the workload is
        deleted or the container crashes. For example, the following are examples of ephemeral
        storage provided by Kubernetes: Table 1. Types of Ephemeral Storage 
Ephemeral Storage Type Location 
EmptyDir volume Managed by kubelet under `/var/lib/kubelet `
Container logs Typically under `/var/logs/containers `
Container image layers Managed by container runtime (for example, under `/var/lib/containerd `) 
Container writable layers Managed by container runtime (e.g., under `/var/lib/containerd `) 
Kubernetes automatically manages ephemeral storage and typically does not require explicit
        settings. However, you might need to express capacity requests for temporary storage so that `kubelet `can use that information to ensure that each node has enough. 
## Persistent Volume 
Persistent Volumes are storage resources that can be used by the cluster. Persistent
        Volumes are volume plug-ins that have lifecycle capabilities that are independent of any
        Kubernetes Pod or Deployment. A Kubernetes persistent volume (PV) is an object that allows
        pods to access persistent storage on a storage device and defined via a Kubernetes
        StorageClass. Unlike regular volumes, which are transient in nature, PVs are persistent,
        supporting stateful application use cases. 
You may have stateful workloads requiring persistent storage whose lifecycle is longer than
        that of Pods or containers. For instance, a database server needs to recover database files
        after it crashes. For those cases, the workloads need to use PersistentVolumes (PV). 
Persistent Volumes are resources that represent storage in the cluster that has been
        provisioned by an administrator or dynamically provisioned using Storage Classes. Unlike
        ephemeral storage, the lifecycle of a PersistentVolume is independent of that of the
        workload that uses it. 
The Persistent Volume API objects capture the details of the implementation of the storage,
        be that NFS, iSCSI, or a cloud-provider-specific storage system. In order to use a
        Persistent Volume (PV), your application needs to invoke a Persistent Volume Claim
        (PVC). 
## Persistent Volume Claim 
A persistent volume claim (PVC) is a storage request. A workload that requires persistent
        volumes uses a persistent volume claim (PVC) to express its request for persistent storage.
        A PVC can request a specific size and Access Modes (for example, they can be mounted after
        read/write or many times read-only). 
Any workload can specify a PersistentVolumeClaim. For example, a Pod may need a volume that
        is at least 4Gi large or a volume mounted under `/data `in the container’s
        filesystem. If a PersistentVolume (PV) satisfies the specified requirements in the
        PersistentVolumeClaim (PVC), it will be bound to the PVC before the Pod starts. 
Related Information : 
Storage for Applications in the Kommander component 
Kubernetes Storage: https://kubernetes.io/docs/concepts/storage/ 
Kubernetes persistent storage design document: https://github.com/kubernetes/design-proposals-archive/tree/main/storage 
Default Storage Providers

---

<!-- source: top-default-storageclass-c.html -->

Default StorageClass 
## 
Kommander requires a default StorageClass. 
For the supported cloud providers, the Konvoy component handles the creation of a default `StorageClass `. 
For pre-provisioned environments, the Konvoy component handles the creation of a StorageClass
      in the form of a local volume provisioner, which is not suitable for production use. Before
      installing the Kommander component, you should identify and install a Kubernetes CSI (see https://kubernetes.io/docs/concepts/storage/volumes/#volume-types ) compatible storage provider that is suitable for production, and then
      ensure it is set as the default, as shown below. For more information, see Provisioning a Static Local Volume .. 
For infrastructure driver specifics, see Default Storage Providers .

---

<!-- source: top-create-a-default-storageclass-t.html -->

Creating a Default StorageClass 
## 
## About this task 
To deploy many of the services on the attached cluster, a default ▷StorageClass◁ must
                be configured. 
## Procedure 
Run the following command on the cluster you want to attach. 
```
`kubectl get sc `
```
The output should look similar to this. Note the `(default) `after the
                    name: 
```
`NAME               PROVISIONER       RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
ebs-sc (default)   ebs.csi.aws.com   Delete          WaitForFirstConsumer   false                  41s `
```

If the `StorageClass `is not set as default, add the following
                    annotation to the `StorageClass `manifest. 
```
`annotations:
  storageclass.kubernetes.io/is-default-class: "true" `
```

---

<!-- source: top-identify-modify-your-storageclass-t.html -->

Identifying and Modifying Your StorageClass 
## 
This `StorageClass `is required to install Kommander. 
## Procedure 
Execute the following command to verify one is configured. 
```
`kubectl get sc --kubeconfig ${CLUSTER_NAME}.conf `
```
For example, output, note the (default) after the
                    name: 
```
`NAME               PROVISIONER       RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
ebs-sc (default)   ebs.csi.aws.com   Delete          WaitForFirstConsumer   false                  41s `
```

If the desired `StorageClass `is not set as default, add the
                    following annotation to the `StorageClass `manifest. 
```
`annotations:
  storageclass.kubernetes.io/is-default-class: "true" `
```
For more information on setting a StorageClass as default, see https://kubernetes.io/docs/tasks/administer-cluster/change-default-storage-class/ .

---

<!-- source: top-change-manage-storageclasses-c.html -->

Change or Manage Multiple StorageClasses 
## 
The default `StorageClass `provisioned with Nutanix Kubernetes Platform ( NKP ) is suitable for production but if your
      workload has different requirements, you can create additional `StorageClass `types with specific configurations. You can change the default `StorageClass `by referring to the Change the default StorageClass section in Kubernetes
      web site. 
## Driver Information 
Below is infrastructure provider CSI driver specifics. 
## Amazon Elastic Block Store (EBS) CSI Driver 
NKP EBS default `StorageClass `: 
```
`kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  annotations:
    storageclass.kubernetes.io/is-default-class: "true" # This tells kubernetes to make this the default storage class
  name: ebs-sc
provisioner: ebs.csi.aws.com
reclaimPolicy: Delete  # volumes are automatically reclaimed when no longer in use and PVCs are deleted
volumeBindingMode: WaitForFirstConsumer #  Physical volumes will not be created until a pod is created that uses the PVC, required to use CSI's Topology feature
parameters:
  csi.storage.k8s.io/fstype: ext4
  type: gp3 # General Purpose SSD `
```

NKP deploys with gp3 (general purpose SSDs) EBS volumes. 
Driver documentation: aws-ebs-csi-driver 
Volume types and pricing: volume types 
## Nutanix CSI Driver 
NKP default storage class for Nutanix
        supports dynamic provisioning of block volumes. 
Driver documentation: Nutanix CSI Driver Configuration 
Nutanix Volumes documentation: Nutanix Creating a Storage Class - Nutanix
          Volumes 
Hypervisor Attached Volumes documentation: Nutanix Creating a Storage Class - Hypervisor Attached
            Volumes 
The CLI and UI allow you to enable or disable Hypervisor Attached volumes. The selection
        passes to the CSI driver's storage class. See Manage Hypervisor . 
```
`allowVolumeExpansion: true
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
    name: default-hypervisorattached-storageclass
parameters: 
   csi.storage.k8s.io/fstype: file-system type
   hypervisorAttached: ENABLED | DISABLED <========== Enabled by Default
   flashMode: ENABLED | DISABLED
   storageContainer: storage-container-name
   storageType: NutanixVolumes
provisioner: csi.nutanix.com
reclaimPolicy: Delete | Retain
mountOptions:
   -option1
   -option2 `
```

## Azure CSI Driver 
NKP deploys with StandardSSD_LRS for Azure Virtual Disks. 
Driver documentation: azuredisk-csi-driver 
Volume types and pricing: volume types 
Specifics for Azure using Pre-provisioning can be found here: Pre-provisioned
            Azure-only Configurations 
## vSphere CSI Driver 
NKP default storage class for vSphere supports dynamic provisioning and static provisioning
        of block volumes. 
Driver documentation: VMware vSphere Container Storage Plug-in
            Documentation 
Specifics for using vSphere storage driver: Using vSphere Container Storage Plug-in 
## Pre-provisioned CSI Driver 
In a Pre-provisioned environment, NKP will also deploy a CSI-compatible driver and configure a default StorageClass - `localvolumeprovisioner `. For more information, see Pre-provisioned Infrastructure . 
Driver documentation: local-static-provisioner 
NKP uses
          ( `localvolumeprovisioner `) as the default storage provider for a
        pre-provisioned environment. However, `localvolumeprovisioner `is not
        suitable for production use. Use an alternate  compatible storage that is suitable for
        production. See local-static-provisioner and Kubernetes CSI . 
To disable the default that Konvoy deploys, set the default StorageClass `localvolumeprovisioner `as non-default. Then, set your newly created
        StorageClass by following the steps in the Kubernetes documentation: See Change the default StorageClass . You can choose from
        any of the storage options available for Kubernetes and make your storage choice the default
        storage. See Storage choice 
Ceph can also be used as CSI storage. For information on how to use Rook Ceph, see Rook Ceph in NKP . 
## GCP CSI Driver 
This driver allows volumes backed by Google Cloud Filestore instances to be dynamically
        created and mounted by workloads. 
Driver documentation: gcp-filestore-csi-driver 
Persistent volumes and dynamic provisioning: volume types<!-- source: top-nkp-configure-metallb-c.html -->

Pre-provisioned: Configuring MetalLB 
## 
Create MetalLB configuration for your pre-provisioned infrastructure. 
Nutanix recommends that an external load balancer be the control plane endpoint. To
      distribute request load among the control plane machines, configure the load balancer to send
      requests to all the control plane machines. Configure the load balancer to send requests only
      to control plane machines that are responding to API requests. If you do not have one, you can
      use Metal LB to create MetalLB  custom resources for your pre-provisioned infrastructure. 
Choose one of the following two protocols you want to use to define service IPs. If your
      environment is not currently equipped with a load balancer, use MetalLB. Otherwise, your load
      balancer will work, and you can continue the installation process with Pre-provisioned: Installing Kommander . To use MetalLB, create MetalLB custom resources
      for your pre-provisioned infrastructure. MetalLB uses one of two protocols for exposing
      Kubernetes services: 
Layer 2, with Address Resolution Protocol (ARP) 
Border Gateway Protocol (BGP) 
## Layer 2 Configuration 
Layer 2 mode is the simplest to configure. In many cases, you do not require any
        protocol-specific configuration, only IP addresses. 
Layer 2 mode does not require the IPs to be bound to the network interfaces of your worker
        nodes. It works by responding to ARP requests on your local network directly to give the
        machine’s MAC address to clients. Warning: 
MetalLB IP address ranges or Classless Inter-Domain Routing (CIDR) needs to be within
            the node’s primary network subnets. For more information, see Cluster Pod and Services Subnets . 
MetalLB IP address ranges or CIDRs and node subnets must not conflict with the
            Kubernetes cluster pod and service subnets. 
For example, the following configuration gives MetalLB control over IPs from 192.168.1.240
        to 192.168.1.250 and configures Layer 2 mode: 
The following values are generic; enter your specific values into the fields where
        applicable. 
```
`cat << EOF > metallb-conf.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default
  namespace: metallb-system
spec:
  addresses:
  - 192.168.1.240-192.168.1.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default
  namespace: metallb-system
spec:
  ipAddressPools:
  - default
EOF `
```

After this is complete, run the `kubectl apply -f metallb-conf.yaml `command. 
## Border Gateway Protocol (BGP) Configuration 
For a basic configuration featuring one BGP router and one IP address range, you need the
        following four pieces of information: 
The router IP address that MetalLB must connect to. 
The router’s autonomous systems (AS) number. 
The AS number MetalLB to use. 
An IP address range is expressed as a CIDR prefix. 
As an example, if you want to specify the MetalLB range as 192.168.10.0/24 and AS number as
        64500 and connect it to a router at 10.0.0.1 with AS number 64501, your configuration will
        be as follows. 
```
`cat << EOF > metallb-conf.yaml
apiVersion: metallb.io/v1beta2
kind: BGPPeer
metadata:
  name: default
  namespace: metallb-system
spec:
  myASN: 64500
  peerASN: 64501
  peerAddress: 10.0.0.1
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default
  namespace: metallb-system
spec:
  addresses:
  - 192.168.10.0/24
---
apiVersion: metallb.io/v1beta1
kind: BGPAdvertisement
metadata:
  name: example
  namespace: metallb-system
spec:
  ipAddressPools:
  - default
EOF `
```

After this is complete, run the `kubectl apply -f metallb-conf.yaml `command.

---

<!-- source: top-load-balancers-c.html -->

Load Balancers 
## 
In a Kubernetes cluster, depending on the flow of traffic direction, there are two kinds of
      load balancing: 
Internal load balancing for the traffic within a Kubernetes cluster 
External load balancing for the traffic coming from outside the cluster 
Nutanix Kubernetes Platform ( NKP ) includes both internal and external
      load balancing solutions for the supported cloud
        infrastructure providers and pre-provisioned environments. For more information, see Load Balancing .

---

<!-- source: top-specify-the-metallb-info-t.html -->

Specifying the MetalLB Information 
## 
Specify the MetalLB Information. 
## Procedure The MetalLB load balancer is needed for cluster installation, and requires
                    these values. 
Provide a Starting IP address range value for the
                            load balancing allocation. 
Provide an Ending IP address range value for the
                            load balancing allocation.

---

<!-- source: top-external-load-balancer-c.html -->

External Load Balancer 
## 
Load Balancing for External Traffic in NKP . 
NKP includes a load-balancing solution for
      the Supported Infrastructure Operating Systems and for pre-provisioned environments. For more
      information, see Load Balancing . 
If you want to use a non- NKP load balancer (for example, as an alternative to MetalLB in
      pre-provisioned environments), NKP supports setting up an external load balancer. 
When enabled, the external load balancer routes incoming traffic requests to a single point
      of entry in your cluster. Users and services can then access the NKP UI through an established
      IP or DNS address. Note: In NKP environments, the external load balancer must be configured without TLS
      termination.

---

<!-- source: top-configure-ingress-for-load-balancing-t.html -->

Configuring Ingress for Load Balancing 
## 
Learn how to configure Ingress settings for load balancing (layer-7). 
## About this task 
Ingress is the name used to describe an API object that manages external access to
                the services in a cluster. Typically, an Ingress exposes HTTP and HTTPS routes from
                outside the cluster to services running within the cluster. 
The object is called an Ingress because it acts as a gateway for inbound traffic. The
                Ingress receives inbound requests and routes them according to the rules you defined
                for the Ingress resource as part of your cluster configuration. 
Expose an application running on your cluster by configuring an Ingress for load
                balancing (layer-7). 
## Before you begin 
You must: 
Have access to a Linux, macOS, or Windows computer with a supported operating
                    system version. 
Have a properly deployed and running cluster. 
To expose a pod using an Ingress (L7) 
## Procedure 
Deploy two web application Pods on your Kubernetes cluster by running the
                    following command. 
```
`kubectl run --restart=Never --image hashicorp/http-echo --labels app=http-echo-1 --port 80 http-echo-1 -- -listen=:80 --text="Hello from http-echo-1"
kubectl run --restart=Never --image hashicorp/http-echo --labels app=http-echo-2 --port 80 http-echo-2 -- -listen=:80 --text="Hello from http-echo-2" `
```

Expose the Pods with a service type of ClusterIP by running the following
                    commands. 
```
`kubectl expose pod http-echo-1 --port 80 --target-port 80 --name "http-echo-1"
kubectl expose pod http-echo-2 --port 80 --target-port 80 --name "http-echo-2" `
```

Create the Ingress to expose the application to the outside world by running
                    the following command. 
```
`cat <<EOF | kubectl create -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: kommander-traefik
    traefik.ingress.kubernetes.io/router.tls: "true"
  generation: 7
  name: echo
  namespace: default
spec:
  rules:
  - http:
      paths:
      - backend:
          service:
            name: http-echo-1
            port:
              number: 80
        path: /echo1
        pathType: Prefix
  - http:
      paths:
      - backend:
          service:
            name: http-echo-2
            port:
              number: 80
        path: /echo2
        pathType: Prefix
EOF `
```
The configuration settings in this example illustrate: 
setting the `kind `to `Ingress `. 
setting the `service.name `to be exposed as each `backend `. 
Run the following command to get the URL of the load balancer created on AWS
                    for the Traefik service. 
```
`kubectl get svc kommander-traefik -n kommander `
```
This command displays the internal and external IP addresses for the exposed
                    service. (Note that IP addresses and host names are for illustrative purposes.
                    Always use the information from your own cluster) 
```
`NAME                 TYPE           CLUSTER-IP    EXTERNAL-IP                                                             PORT(S)                                     AGE
kommander-traefik    LoadBalancer   10.0.24.215   abf2e5bda6ca811e982140acb7ee21b7-37522315.us-west-2.elb.amazonaws.com   80:31169/TCP,443:32297/TCP,8080:31923/TCP   4h22m `
```

Validate that you can access the web application Pods by running the following
                    commands: (Note that IP addresses and host names are for illustrative purposes.
                    Always use the information from your own cluster) 
```
`curl -k https://abf2e5bda6ca811e982140acb7ee21b7-37522315.us-west-2.elb.amazonaws.com/echo1
curl -k https://abf2e5bda6ca811e982140acb7ee21b7-37522315.us-west-2.elb.amazonaws.com/echo2 `
```