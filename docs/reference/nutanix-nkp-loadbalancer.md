<!-- source: top-nkp-configure-metallb-c.html -->

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