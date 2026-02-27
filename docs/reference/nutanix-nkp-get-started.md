<!-- source: top-get-started-nkp-t.html -->

Getting Started with NKP 
## 
At Nutanix, we partner with you throughout the entire cloud-native journey as
        follows: 
## About this task 
Help you in getting started with Nutanix Kubernetes Platform ( NKP ) by introducing
                    concepts. 
Guide you with the Basic Installations by Infrastructure through the NKP software installation and
                    start-up. 
Guide you with the Cluster Operations Management , which
                    involves customizing applications and managing operations. 
You can install in multiple ways: 
On Nutanix infrastructure. 
On a public cloud infrastructure, such as Amazon Web Services (AWS), Google
                    Cloud Platform (GCP), and Azure. 
On an internal network, on-premises environment, or with a physical or virtual
                    infrastructure. 
On an air-gapped environment. 
With or without Federal Information Processing Standards
                        (FIPS) and graphics processing unit (GPU). 
Before you install NKP : 
## Procedure 
Complete the prerequisites (see Nutanix Kubernetes Platform Requirements ) required
                    to install NKP . 
Determine the infrastructure (see Control Plane Nodes and Worker Nodes Resource Requirements for Nutanix Kubernetes Platform ) on which
                    you want to deploy NKP . 
After you choose your environment, download NKP , and select the Basic Installations by Infrastructure for your infrastructure provider and
                    environment. The basic installations set up the cluster with the Konvoy component and then
                    install the Kommander component to access the dashboards through the NKP UI. The topics in the Basic Installations by Infrastructure chapter help you explore NKP and prepare clusters for
                    production to deploy and enable the applications that support Cluster Operations Management . 
(Optional) After you complete the basic installation and are ready to
                    customize, perform Custom Installation and Additional Infrastructure
                        Tools , if required. 
To prepare the software, perform the steps described in the Cluster
                        Operations Management chapter. 
Deploy and test your workloads.

---

<!-- source: top-overview-nkp-architecture-c.html -->

NKP Insights Architecture 
## 
This section describes the architecture for Nutanix Kubernetes Platform
                  Insights ( NKP Insights ). 
Following diagram details the architecture for Nutanix Kubernetes Platform
                  Insights ( NKP Insights ). 
The NKP Insights Architecture diagram shows how NKP Managed Clusters generate events and
      metrics through the Insights Engine. NKP Insights Management processes these insights, stores
      them in the Alerts Table, and shares them as notifications with collaboration tools such as
      Slack and Teams. Insight alerts include anomaly descriptions, root cause analysis, solutions,
      and best practices. Figure. NKP Insights Architecture Click to enlarge