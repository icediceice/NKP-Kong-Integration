<!-- source: top-nutanix-custom-create-mgmtcluster-t.html -->

Creating the Nutanix Kubernetes Platform Management Cluster 
## 
Create a Nutanix Kubernetes Platform ( NKP ) management cluster in a
        non-air-gapped and air-gapped environment using the NKP default settings. 
## About this task 
To create the NKP management
                cluster, follow these steps: Note: To create a NKP management
                cluster when the bootstrap cluster is running on the host, you need a minimum of 2
                CPUs and 4GB memory available for successful creation of the management
                cluster. 
## Procedure 
Open the terminal with access to the NKP CLI. 
(Required for air-gapped environment and optional for non-air-gapped
                    environment) Load the NKP bootstrap cluster container image into the local container runtime store: 
```
`docker load --input "nkp-nkp-version/konvoy-bootstrap-image-nkp-version.tar" `
```

The NKP CLI uses a
                        container image to create the bootstrap cluster. In an air-gapped
                        environment, you cannot automatically download the image from the public
                        registry. The image is included in the air-gapped bundle, and you must load
                        the image into the container runtime. 
Assign a name to your cluster and store it in an environment variable: `export CLUSTER_NAME= Name of the
                            NKP Cluster `
Replace Name of the NKP
                            Cluster with the name of the NKP management
                        cluster. Note: NKP also uses the cluster name for some Kubernetes resources. Ensure that you
                        only use lowercase alphabets `a-z `, numbers `0-9 `, `. `, and `- `in the
                        cluster name. For more information, see Kubernetes . 
Provide the Prism Central endpoint. The NKP CLI uses the Prism Central API to create the NKP cluster, and this API is hosted at the Prism Central endpoint. 
The endpoint must be in one of three formats: 
host 
host:port 
A valid URL. For example, https:// host:port For
                    example: 
```
`export NUTANIX_ENDPOINT= URL of Prism Central Endpoint `
```
Replace URL of Prism Central Endpoint with the URL of Prism Central endpoint. 
Provide the Prism Central credentials: 
```
`export NUTANIX_USER= Prism Central Username export NUTANIX_PASSWORD= Prism Central Password `
```
Replace: 
Prism Central Username with the Prism Central username. 
Prism Central Password with the Prism Central password. The NKP CLI needs a username and password to access Prism Central . 
(Optional) Access an HTTPS Prism Central endpoint without a trusted Certificate
                    Authority (CA) certificate: 
```
`export INSECURE=true `
```
The NKP CLI can only verify
                    server certificates signed by a trusted CA. Ensure that you allow insecure
                    access to the Prism Central endpoint if the Prism Central server certificate is
                    not signed by a trusted CA certificate, and use HTTPS to access the endpoint. 
If the Prism Central endpoint uses a self-signed CA certificate, the CA
                        certificate is untrusted. When creating an NKP cluster, use `--additional-trust-bundle `to pass only the Prism Central self‑signed certificate file. Do not include the full CA bundle, as
                        large files can exceed the 16 KB `cloud‑init `user data limit
                        and cause node VM creation errors. 
Choose the name of a Prism Element cluster: 
```
`export NUTANIX_CLUSTER= Name of Prism Central Cluster `
```

Replace Name of the Prism Central Cluster with the name of
                        the Prism Element cluster. 
The system creates the NKP control plane and worker nodes virtual machines in the Prism Element cluster. 
In this step, a single Prism Element cluster is used for both the control
                        plane and worker nodes. However, you can modify the NKP CLI command to use
                        separate Prism Element clusters for the control plane and worker nodes. 
Choose the name of a Nutanix storage container to use for Kubernetes persistent
                    volumes: 
```
`export STORAGE_CONTAINER_NAME= Name of Storage Container `
```

Replace Name of Storage Container with the name of the
                        Nutanix storage container. By default, Kubernetes persistent volumes are
                    provisioned using Nutanix volumes in a Nutanix storage container. The storage
                    container configuration controls features such as replication, compression, and
                    deduplication. You can dedicate a storage container to your cluster, or share
                    the storage container. Important: The storage container must be in
                        the Prism Element cluster that you selected in step 4 . 
Choose an IP address for the control plane endpoint: 
```
`export CONTROLPLANE_IP= Dedicated static IP `
```
Replace Dedicated static IP with a static IP address for the
                    control plane endpoint. The NKP cluster control
                    plane consists of multiple nodes, each capable of responding to Kubernetes API
                    requests. However, only one node serves the requests at a time. The control
                    plane endpoint uses a virtual IP (VIP) address, which is assigned to an active
                    node. This VIP ensures that API requests are always directed to the current
                    active control plane node. Important: Ensure that the IP address for
                        the control plane endpoint adheres to the following guidelines: 
Routable from the control plane and worker subnets 
A static IP that is not part of a dynamic host configuration
                                protocol (DHCP) or IP address management (IPAM) pool 
Not used for any other purpose 
(Optional) Configure an external endpoint to access the control plane: 
```
`export CONTROLPLANE_EXTERNAL_ENDPOINT_FLAG="
--control-plane-external-endpoint=<IP or DNS name>" `
```

The external endpoint can be used to access the cluster from outside the
                        control plane and worker subnets. The endpoint can be an IP or a
                        fully-qualified domain name. Note: 
Inside the VPC: To access a cluster in a Virtual Private Cloud
                                (VPC), you can use a floating IP as the external endpoint. Use Prism Central to request a new floating IP, or choose a floating IP that
                                is not associated. Finally, associate the floating IP with the
                                static IP you chose in the previous step. 
To access the cluster in the VPC, use the Bastion VM or any other VM
                                in the same VPC. 
Outside the VPC: To access a cluster from outside the VPC, link the
                                floating IP to an internal IP used as `CONTROL_PLANE_ENDPOINT_IP `while deploying the
                                cluster. For information on Floating IP, see the topic Request Floating IPs in Flow Virtual
                  Networking . 
Access the cluster in the VPC from outside using updated `kubeconfig `after creating the cluster. 
To access the UI outside the VPC, you need to request three floating IPs. 
One IP for the bastion 
One IP for passing the `--extra-sans `flag
                                        during cluster creation 
One IP for the UI 
Choose an IP address range for Kubernetes load balancer services: 
```
`export SERVICE_LB_IP_RANGE=" IP range in  first IP-last IP format " `
```
Replace IP range in first IP-last IP format with the IP range in
                    first IP-last IP format. For example, 100.0.0.30-100.0.0.56. 
The NKP cluster assigns an
                        external IP address from a predefined range to expose a Kubernetes service.
                        The NKP UI uses the first
                        IP address in this range. Important: Ensure that the IP
                        addresses for the Kubernetes load balancer services adhere to the following guidelines: 
Routable from the control plane and worker subnets 
A static IP that is not part of a dynamic host configuration
                                protocol (DHCP) or IP address management (IPAM) pool 
Not used for any other purpose 
Choose a subnet for control plane and worker nodes: 
```
`export SUBNET= Subnet name `
```
Replace Subnet name with the name of the subnet for control plane
                    and worker nodes. 
Every control plane and worker node is assigned an IP
                        address from this subnet. Important: Ensure that the subnet
                        is in the Prism Element cluster that you selected in Step 4 . In
                    this step, one subnet is used for both the control plane and the worker nodes.
                    However, you can modify the NKP CLI command to use separate subnets for the control plane and the worker
                    nodes. 
Choose a Nutanix VM image: 
```
`export VM_IMAGE= VM Image name `
```

Replace VM Image name with the name of the Nutanix VM
                        image. 
If you did not create a Nutanix VM image, you can use a prebuilt VM image.
                        For more information, see Creating a Nutanix VM Image . 
In this step, one Nutanix VM image is used for both the control plane and the
                        worker nodes. However, you can modify the NKP CLI command to use
                        separate Nutanix VM images for the control plane and the worker nodes. 
(Required for air-gapped environment and optional for non-air-gapped
                    environment) Use one of the following registry methods to manage the container
                    images: 
Internal Registry Mirror : If you want NKP to manage the
                            required container images using its internal registry with a bundled
                            image set. 
```
`export BUNDLE_FLAGS=" --bundle ./nkp-${nkp-version}/container-images/kommander-image-bundle-${nkp-version}.tar,./nkp-${nkp-version}/container-images/konvoy-image-bundle-${nkp-version}.tar" `
```

Replace nkp-version with the NKP version at
                                your site. 
NKP provides a
                                bundle that contains all the necessary container images required to
                                bootstrap an NKP cluster. 
Local Registry Mirror : If you want to configure
                            a local or user-provided registry mirror manually. 
```
`export REGISTRY_MIRROR_FLAGS="
--registry-mirror-url=$REGISTRY_MIRROR_URL \
--registry-mirror-username=$REGISTRY_MIRROR_USERNAME \
--registry-mirror-password=$REGISTRY_MIRROR_PASSWORD \
--registry-mirror-cacert=$REGISTRY_MIRROR_CA \
" `
```

By default, an NKP cluster pulls container images from public registries. If these
                                registries are not available, or you do not use them, NKP can pull the
                                images from a registry mirror. To use a registry mirror, follow the
                                steps in Preparing a Local Registry Mirror , and
                                export the following environment variables. 
For more information about the registry types, see Air-Gapped or Non-Air-Gapped Environment . 
(Required for air-gapped environment and optional for non-air-gapped
                    environment) Enable the air-gapped mode: 
```
`export AIRGAPPED=true `
```
The air-gapped mode runs the NKP UI, and other NKP applications in an
                    air-gapped environment. 
(Optional) Use registry credentials: 
```
`export REGISTRY_FLAGS="
--registry-url=<Registry URL> \
--registry-username=<Registry username> \
--registry-password=<Registry password> \
--registry-cacert=<Path to registry CA certificate file> \
" `
```
By default, an NKP cluster pulls container images from public registries. However, some registries,
                    such as Docker Hub, limit the number of image pulls unless you provide the
                        credentials. Tip: If you do not use a local registry mirror or an
                        internal registry, Nutanix recommends that you provide credentials for
                        Docker Hub. 
(Optional) Choose networks for the Kubernetes pods and services: 
```
`export KUBERNETES_PODS_NETWORK= IP range in CIDR format export KUBERNETES_SERVICES_NETWORK= IP range in CIDR format `
```

Replace IP range in CIDR format with the IP range in CIDR
                        format. For example, 192.168.0.0/16. 
Every NKP cluster has two
                        networks; one for Kubernetes pods, and another for Kubernetes services.
                        These networks are internal to the cluster. Every Kubernetes pod is assigned
                        an IP address from the Kubernetes pods network, and every Kubernetes service
                        is assigned an IP address from the Kubernetes services network. The network
                        size is based on the number of pods and services in a cluster. Important: 
The Kubernetes pods network and Kubernetes services network must not
                                overlap with each other, or with your control plane and worker nodes
                                subnets. 
After cluster creation, you cannot change the pods and services
                                    subnets. 
By default, the pods network is 192.168.0.0/16, and
                                    the services network is 10.96.0.0/12. These network sizes allow
                                    up to approximately 65 thousand pods, and one million
                                    services. 
(Optional) Enable SSH access to nodes: 
```
`export SSH_USERNAME= username export SSH_PUBLIC_KEY= path to SSH public key file `
```
Replace: 
username with the SSH user name 
path to SSH public key file with the location of SSH
                            public key file Provide a username and public SSH key to enable SSH access with these
                    credentials to all NKP cluster nodes. NKP creates
                    the user on every cluster node, and adds the public SSH key to the authorized
                    SSH keys of the user. By default, NKP cluster nodes allow SSH
                    public key authentication. 
Provide the public SSH key as a path to a
                    file. 
(Optional) To disable the automatic onboarding of
                    clusters: 
```
`export PC_ONBOARDING_FLAGS="
--onboard-to-prism-central=false \
" `
```
This is an optional step to disable the automatic onboarding of clusters,
                    which is enabled by default. Note: If the konnector agent pod is stuck in `Init `state, you
                        must enable karbon-core service in PC in version 7.3 and upgrade the
                        karbon-core version to 2.10.2. 
Create a management cluster: 
```
`nkp create cluster nutanix \
--self-managed \
--airgapped=${AIRGAPPED:-false} \
\
--cluster-name=${CLUSTER_NAME} \
--endpoint=${NUTANIX_ENDPOINT} \
--insecure=${INSECURE:=false} \
--control-plane-endpoint-ip=${CONTROLPLANE_IP} \
--${CONTROLPLANE_EXTERNAL_ENDPOINT_FLAG} \
--csi-storage-container=${STORAGE_CONTAINER_NAME} \
--kubernetes-pod-network-cidr=${KUBERNETES_PODS_NETWORK:-"192.168.0.0/16"} \
--kubernetes-service-cidr=${KUBERNETES_SERVICES_NETWORK:-"10.96.0.0/12"} \
--kubernetes-service-load-balancer-ip-range=${SERVICE_LB_IP_RANGE} \
\
--control-plane-prism-element-cluster=${NUTANIX_CLUSTER} \
--control-plane-subnets=${SUBNET} \
--control-plane-vm-image=${VM_IMAGE} \
\
--worker-prism-element-cluster=${NUTANIX_CLUSTER} \
--worker-subnets=${SUBNET} \
--worker-vm-image=${VM_IMAGE} \
--ssh-username=${SSH_USERNAME} \
--ssh-public-key-file=${SSH_PUBLIC_KEY} \
\
${BUNDLE_FLAGS} \
${REGISTRY_MIRROR_FLAGS} \
\
${REGISTRY_FLAGS}
${PC_ONBOARDING_FLAGS} `
```
Note: Do not use both `BUNDLE_FLAG `and `REGISTRY_MIRROR_FLAG `simultaneously. Use these flags
                        based on how you manage the container images. 
To assign values to flags, the NKP CLI command creates a
                        management cluster with the configuration and environment variables that you
                        exported. 
If you require the use of an HTTP/S proxy in your environment, add the flags `--http-proxy `, `--https-proxy `, and `--no-proxy `. For more information, see Cluster Creation with HTTP or HTTPS Proxy . 
When you run the command `nkp create cluster `, NKP performs a series of
                        preflight checks to prevent common issues with cluster creation. For more
                        information, see Preflight Checks . 
For example, if the VM image name is missing from the worker and control
                        plane nodes, the following error is displayed in the output while creating
                        cluster resources: 
```
`> nkp create cluster nutanix ...
Generating cluster resources
Preflight checks failed:
---
Check:   NutanixVMImage
Message: For the workers, expected to find 1 VM Image, found 0
Flag:   --worker-vm-image
---
Check:   NutanixVMImage
Message: For the control plane, expected to find 1 VM Image, found 0
Flag:   --control-plane-vm-image `
```

(Optional) Skip the preflight checks. Important: Skip the preflight checks only when you encounter an
                        error or a bug in the check. 
You can skip a specific preflight check using a flag with the name of that
                        check. For example, 
```
`--skip-preflight-checks=NutanixVMImage `
```

If you want to skip more than one preflight check, specify the flag for each
                        check individually. For example, 
```
`--skip-preflight-checks=NutanixVMImage --skip-preflight-checks=NutanixStorageContainer `
```

If you want to skip all the preflight checks, use `--skip-preflight-checks=all `.

---

<!-- source: top-specify-nutanix-cluster-info-t.html -->

Specifying Nutanix Cluster Information 
## 
## About this task 
In the section of the provisioning form, you give the cluster a name and provide some
                basic information: 
## Procedure 
In the selected workspace Dashboard, select the Add Cluster button at the top right to display the Add Cluster page. 
Select the Create Cluster card. 
Provide these cluster details in the form: 
Cluster Name : A valid Kubernetes name for the
                            cluster. 
Add Labels : Add any required Labels the cluster
                            needs for your environment by selecting the `+ Add Label `link. 
Adding a cluster label might add the cluster to NKP
                                projects. 
Infrastructure Provider : This field's value
                            corresponds to the Nutanix infrastructure provider you created. 
Kubernetes Version : Select a supported version of
                            Kubernetes for this version of NKP . 
SSH Username : This field corresponds to the name
                            of the SSH user to create or use. Leaving this field blank creates the
                            default user name 'konvoy' for the specified SSH public key. 
SSH Public Key : Paste the SSH public key that
                            specifies the user's authorized key.

---

<!-- source: top-configure-nutanix-node-pool-info-t.html -->

Configuring Nutanix Node Pool Information 
## 
## About this task 
You must configure node pool information for your control plane and worker nodes. The
                form splits these information sets into two groups. 
## Procedure 
Provide the control plane node pool name and resource sizing information. 
Nutanix Prism Project : Select Nutanix Prism
                            Project. Selecting this will associate all the NKP control plane
                            node virtual machines to this project. 
Nutanix AOS Cluster : Nutanix AOS cluster is used
                            to host the control plane virtual machines. If a Nutanix Prism Project
                            is chosen, only the AOS clusters linked to that project will be
                            shown. 
Subnet : Subnet used for the control plane nodes.
                            Subnet must be precreated in Nutanix Prism Central . If a Nutanix Prism
                            project is chosen, only the subnets associated with the Nutanix Prism
                            Project will be shown. At least one subnet must be selected. 
OS Image : Select an NKP compliant OS
                            image uploaded in Prism Central for the Kubernetes control plane
                            nodes. 
Nutanix Prism Categories : Add additional Nutanix
                            Prism Categories to the NKP control plane
                            VMs. The categories must exist in Prism Central . 
Control Plane Endpoint IP : Endpoint IP is used
                            for the NKP Kubernetes API VIP. Note: This IP
                                address should not belong to a DHCP range or Nutanix IPAM address
                                pool. 
Control plane Endpoint port : Port used for NKP Kubernetes API
                            server. By default the value is 6443. 
Control plane Node Count : This field corresponds
                            to the amount of control plane nodes for the NKP cluster. The
                            default value is 3, other options are 1 or 5. Caution: Do not use a single-node control plane in a
                                production cluster. Recommended is 3 or more. 
CPU per Node (vCPU) : The amount of vCPUs per
                            control plane node. 
Memory per node (GiB) : The amount of Memory per
                            control plane node (in GiB). 
Disk Size per node (GiB) : The amount of disk
                            size per control plane node (in GiB). Note: When you select a project, AOS cluster, subnets, and
                        images in the control plane section, these selections will automatically
                        populate the worker node pool section. This eliminates the need to input the
                        same information twice manually. However, if desired, you can modify these
                        selections for the worker node pool. 
Provide the worker node pool name and resource sizing information. 
Nutanix Prism Project : Select Nutanix Prism
                            Project. Selecting this will associate all the NKP worker node
                            virtual machines to this project. 
Nutanix AOS Cluster : Nutanix AOS cluster is used
                            to host the control plane virtual machines. If a Nutanix Prism Project
                            is chosen, only the AOS clusters linked to that project will be
                            shown. 
Subnet : Subnet used for the control plane nodes.
                            Subnet must be precreated in Nutanix Prism Central . If a Nutanix Prism
                            project is chosen, only the subnets associated with the Nutanix Prism
                            Project will be shown. At least one subnet must be selected. 
OS Image : Select an NKP compliant OS
                            image uploaded in Prism Central for the Kubernetes worker nodes. 
Nutanix Prism Categories : Add additional Nutanix
                            Prism Categories to the NKP worker node VMs.
                            The categories must exist in Prism Central . 
Worker node Autoscaling : Enable or disable worker
                            node autoscaling. If enabled, NKP will
                            automatically add or remove nodes based on workload demands. This is
                            disabled by default. 
If worker node autoscaling is enabled : 
Minimum number of nodes : Minimum
                                            amount of worker nodes in the worker node pool. 
Maximum number of nodes : Maximum
                                            amount of worker nodes in the worker node pool. 
If worker node autoscaling is disabled: : 
Worker node count: : The amount of
                                            worker nodes in the node pool. 
CPU per Node (vCPU) : The amount of vCPUs per
                            worker node. 
Memory per node (GiB) : The amount of Memory per
                            worker node (in GiB). 
Disk Size per node (GiB) : The amount of disk size
                            per worker node (in GiB). 
Provide the Storage information. 
Hypervisor attached Volumes : The hypervisor
                            attached Nutanix Volume uses the hypervisor internal network for data
                            traffic instead of external iSCSI connections. Enabled by default. 
Nutanix Storage container : The Storage container
                            is used for the Nutanix Volumes. Nutanix Storage container must be
                            pre-created in Prism Central . 
Reclaim Policy : This field corresponds to the
                            Reclaim policy for the persistent volumes. The allowed values are Retain
                            and Delete. Default is Delete. 
Provide the Networking information. 
Pod Network : The Kubernetes Pod network CIDR to
                            use in the cluster (Default is 192.168.0.0/16). Note: Ensure the CIDRs do not overlap with your host
                                subnets because they cannot be changed after cluster
                                creation. 
Service Network : The Kubernetes Service CIDR to
                            use in the cluster (Default is 10.96.0.0/12). Note: Ensure the CIDRs do not overlap with your host subnets because they
                                cannot be changed after cluster creation. 
Service load balancer start IP : Enter the first
                            IP address in the private range you're allocating for load
                                balancing. Note: These IP addresses should not
                                belong to a DHCP range or Nutanix IPAM address pool. 
Service load balancer end IP : Enter the last IP
                            address in the private range you're allocating for load balancing. Note: These IP addresses should not belong to a DHCP
                                range or Nutanix IPAM address pool. 
Provide the Image registries information. 
Image Registry Mirror : Use an image registry
                            mirror as a local copy of public registries. Defining a mirror registry
                            is recommended if you have an air-gapped environment or want to avoid
                            restrictions with firewalls. 
URL : Enter the valid URL for the image
                                    registry mirror. 
Username : Enter the Username for the
                                    registry mirror. 
Password : Enter the password for the
                                    registry mirror. 
CA certificate : Enter the CA certificate
                                    for the registry mirror. This is required in case of self-signed
                                    certificates. 
Private Registry : Use a private image registry
                            for your application images. 
URL : Enter the valid URL for the image
                                    registry mirror. 
Username : Enter the Username for the
                                    registry mirror. 
Password : Enter the password for the
                                    registry mirror. 
CA certificate : Enter the CA certificate
                                    for the registry mirror. This is required in case of self-signed
                                    certificates.

---

<!-- source: top-nutanix-infrastructure-options-t.html -->

Installing Nutanix Kubernetes Platform on Nutanix Infrastructure 
## 
Install Nutanix Kubernetes Platform ( NKP ) on a Nutanix
        infrastructure. 
## About this task To configure Nutanix infrastructure and NKP together, follow these
            steps: 
## Procedure 
Configure the Nutanix infrastructure. Note: Nutanix recommends that you do not use the Prism Central admin user
                            role to configure NKP on Nutanix AHV infrastructure. For more information, see Nutanix Kubernetes Platform Installation Prerequisites . 
If you are in an air-gapped environment, create a bastion VM host. 
For more information, see Creating a Bastion Host . 
Use the pre-built image provided by Nutanix or create a base operating system
                    image. 
After you create the base operating system image, the NKP image builder uses it
                        to generate a custom image if you are not using the pre-built image. 
You can use either the pre-built or custom image with the `nkp create
                            cluster nutanix `command to create VM nodes in your cluster
                        directly on a server. From that point, use ​ NKP ​ to provision and
                        manage your cluster. 
For more information, see Using an Image provided by Nutanix or Creating a Nutanix VM Image . 
Prepare a local registry mirror. Important: This step is required for an air-gapped environment. It
                        is optional in a non-air-gapped environment; however, it can increase
                        stability and security. In a non-air-gapped environment, you can also use a
                        registry mirror with a self-signed registry CA certificate. 
For more information, see Preparing a Local Registry Mirror . 
Push the image to the local registry mirror. 
For more information, see Pushing Images to the Registry . 
Create a new NKP management
                    cluster. 
For more information, see Creating the Nutanix Kubernetes Platform Management Cluster . 
Create a Nutanix cluster with custom Cilium Configuration. This step is optional and recommended only for advanced use-cases. For more information, see Creating a Nutanix Cluster With Custom Cilium Configuration 
Set up the NKP UI
                    access. 
For more information, see Setting up the Nutanix Kubernetes Platform User Interface Access . 
If you are in an air-gapped environment, it is mandatory to configure the
                    network time protocol (NTP) servers. 
For more information, see NTP Servers Configuration for Nutanix NKP Clusters in Air-Gapped Environment .

---

<!-- source: top-nutanix-basic-install-options-c.html -->

Nutanix Installation Options 
## 
For information on how to install NKP in a Nutanix environment, see Installing Nutanix Kubernetes Platform on Nutanix Infrastructure .