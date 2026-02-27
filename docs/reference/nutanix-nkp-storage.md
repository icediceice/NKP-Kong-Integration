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
Persistent volumes and dynamic provisioning: volume types