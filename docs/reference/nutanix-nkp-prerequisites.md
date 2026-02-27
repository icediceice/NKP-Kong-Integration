<!-- source: top-nkp-installation-prerequisites-c.html -->

Nutanix Kubernetes Platform Installation Prerequisites 
## 
Note the prerequisites to install Nutanix Kubernetes Platform ( NKP ) on a Nutanix infrastructure. 
The following requirements apply to installations of NKP on a Nutanix infrastructure: 
Nutanix Infrastructure Requirements 
Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix Kubernetes Platform 
Nutanix Kubernetes Platform Requirements 
Prism Central Requirements for Nutanix Kubernetes Platform Installation 
Managing VMs from VLAN Basic Subnets to Network Controller-based VLAN Subnets 
Creating the Operating System Package Bundle

---

<!-- source: top-nutanix-environment-prerequisites-c.html -->

Nutanix Infrastructure Requirements 
## 
Note the requirements for setting up the Nutanix infrastructure. 
Before installing Nutanix Kubernetes Platform ( NKP ) on a Nutanix infrastructure, verify that
      your environment meets the following basic requirements: 
The Nutanix environment must be on Prism Central version pc.7.3 or pc.7.5. 
The Nutanix environment must be on AOS version 7.3, or 7.5. 
The Nutanix environment must be either on-premises or hosted on one of the public clouds,
        such as NC2 Azure, NC2 AWS, or NC2 GCP. 
NKP is supported on Nutanix Cloud
                  Platform with the following external storage integrations: 
Dell PowerFlex: 
For the supported configuration maximums and minimums, see Configuration Maximums and Minimums for NCP with
                  Dell PowerFlex . 
For the recommendations and limitations, see Recommendations and Limitations of NCP with Dell
                  PowerFlex . 
Pure Storage FlashArray: 
For the supported configuration maximums and minimums, see Configuration Maximums and Minimums for NCP with
                  Pure Storage FlashArray . 
For the recommendations and limitations, see Recommendations and Limitations of NCP with Pure
                  Storage FlashArray . 
Configure valid values in the Prism Central instance. 
For more information, see Prism Central Settings (Infrastructure) . 
Ensure that the DNS servers configured on the Prism Central instance
            are reachable. 
You must have a pre-designated subnet. 
Ensure that a subnet is available with unused IP addresses. 
Configure either Nutanix
              IP address management (IPAM) or dynamic host configuration protocol (DHCP) on the
              subnet to automatically assign IP addresses to control plane nodes and worker
              nodes. 
Compute the number of required IP addresses: 
One IP address for each node in the Kubernetes cluster. The default cluster size
                includes three control plane nodes and four worker nodes, requiring a total of seven
                IP addresses. 
One IP address within the same classless inter-domain routing (CIDR) as the
                subnet, but outside the address pool for the Kubernetes API server. 
One IP address in the same CIDR as the subnet, but outside the address pool for
                the default ingress. 
Additional IP addresses might be required for additional load balancer services,
                such as Nutanix Data Services for
                  Kubernetes ( NDK ). 
For more information, see Prerequisites and Limitations in the Nutanix Data Services for
                  Kubernetes guide. 
Example Configuration: If your subnet uses the CIDR10.0.0.0/24 and the DHCP or
              Nutanix IPAM IP address pool range from 10.0.0.100 to 10.0.0.200, allocate seven IP
              addresses from the IP address pool (10.0.0.101 to 10.0.0.107) for each of the NKP Kubernetes nodes. Additionally, reserve two IP addresses outside the IP address
              (10.0.0.90 and 10.0.0.91) for the Kubernetes API server and Kubernetes load balancer
              service. 
For air-gapped environments, create a bastion VM host template with access to a
            configured local registry. 
Nutanix recommends using a naming pattern such as `../folder-name/NKP-bastion-template `. Each infrastructure provider
              has its own instructions for setting up a bastion host. 
For more information,
              see Creating a Bastion Host . 
You need access to a bastion VM or other network-connected host running NKP image builder. Note: Nutanix provides a complete image built on
              its infrastructure, which eliminates the need to create your own from a BaseOS image. 
Ensure that you can reach the Nutanix endpoint from where you run NKP CLI. Note: 
For an air-gapped environment, ensure that you download the bundle and extract
                        the TAR file to a local directory. 
For more information, see Downloading NKP . 
Some commands, such as `nkp push bundle `, require temporary
                        disk space. These commands write to the temporary directory, which is
                        usually /tmp . To override the directory, export the
                        TMPDIR environment variable before running a command. 
For
                        example, 
```
`export TMPDIR=/path/to/your/directory `
```

For more information on troubleshooting or additional information, see Nutanix Knowledge Base .

---

<!-- source: top-prism-central-requirements-nkp-c.html -->

Prism Central Requirements for Nutanix Kubernetes Platform Installation 
## 
Note the Prism Central requirements and configurations for Nutanix Kubernetes Platform ( NKP ) installation. 
Prism Central requirements include setting up the Prism Central credentials, user roles, and Prism Central resources for the NKP management and workload clusters. 
## Prism Central Credential Requirements 
Before updating your Prism Central credentials on a deployed Nutanix Kubernetes Platform ( NKP ) clusters, ensure that you meet the
        following requirements: 
Ensure that you have a `kubeconfig `file for the management cluster. 
Ensure that you have a `kubeconfig `file for each workload clusters that
          requires a Prism Central credential update. 
Update the following secrets with a new password for Prism Central instance: 
## Secrets for Prism Central Credentials 
Secret Name Namespace NKP Cluster 
global-nutanix-credentials capx-system Management Cluster 
${MANAGEMENT_CLUSTER_NAME}-pc-credentials ${MANAGEMENT_CLUSTER_NAMESPACE} Management Cluster 
${MANAGEMENT_CLUSTER_NAME}-pc-credentials-for-csi ${MANAGEMENT_CLUSTER_NAMESPACE} Management Cluster 
${MANAGED_CLUSTER_NAME}-pc-credentials ${MANAGED_CLUSTER_NAMESPACE} Management Cluster 
${MANAGED_CLUSTER_NAME}-pc-credentials-for-csi ${MANAGED_CLUSTER_NAMESPACE} Management Cluster 
nutanix-ccm-credentials kube-system 
Management Cluster 
Managed Cluster 
nutanix-csi-credentials ntnx-system 
Management Cluster 
Managed Cluster

---

<!-- source: top-basic-requirements-c.html -->

Basic Requirements 
## 
To attach an existing cluster in the UI, the Application Management cluster must be able to
      reach the services and the `api-server `of the target cluster. 
The cluster you want to attach can be a NKP -CLI-created cluster (which
      will become a Managed cluster upon attachment), or another Kubernetes
        cluster like AKS, EKS, or GKE (which will become an Attached cluster upon
      attachment). 
For attaching existing clusters without networking restrictions, the requirements depend on
      which NKP version you are using. Each
      version of NKP supports a specific range of
      Kubernetes versions. You must ensure that the target cluster is running a compatible
      version.