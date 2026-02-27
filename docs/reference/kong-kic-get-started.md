[Home](https://developer.konghq.com/) / [Kong Ingress Controller](https://developer.konghq.com/kubernetes-ingress-controller/)
[ Edit this Page Edit ](https://github.com/Kong/developer.konghq.com/edit/main/app/_how-tos/kubernetes-ingress-controller/kic-install.md) [ Report an Issue Report ](https://github.com/Kong/developer.konghq.com/issues/)
# Install Kong Ingress Controller
Uses:  [Kong Ingress Controller](https://developer.konghq.com/kubernetes-ingress-controller/)
Deployment Platform
konnect on-prem
Related Documentation
In This Series
  1. [Install Kong Ingress Controller](https://developer.konghq.com/kubernetes-ingress-controller/install/)


Tags
Related Resources
[All KIC documentation](https://developer.konghq.com/index/kubernetes-ingress-controller/)
TL;DR
```
helm install kong kong/ingress -n kong --create-namespace

```

Copied!
## [Prerequisites ](https://developer.konghq.com/kubernetes-ingress-controller/install/#prerequisites "Prerequisites")
### [Kong Konnect ](https://developer.konghq.com/kubernetes-ingress-controller/install/#kong-konnect)
If you don’t have a Konnect account, you can get started quickly with our [onboarding wizard](https://konghq.com/products/kong-konnect/register?utm_medium=referral&utm_source=docs).
  1. The following Konnect items are required to complete this tutorial: 
     * Personal access token (PAT): Create a new personal access token by opening the [Konnect PAT page](https://cloud.konghq.com/global/account/tokens) and selecting **Generate Token**.
  2. Set the personal access token as an environment variable:
```
export KONNECT_TOKEN='YOUR KONNECT TOKEN'

```

Copied!


### [Enable the Gateway API (Optional) ](https://developer.konghq.com/kubernetes-ingress-controller/install/#enable-the-gateway-api-optional)
  1. Install the Gateway API CRDs before installing Kong Ingress Controller.
```
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/1.4.1/standard-install.yaml

```

Copied!
  2. Create a `Gateway` and `GatewayClass` instance to use.


```
echo "
apiVersion: v1
kind: Namespace
metadata:
  name: kong

apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: kong
  annotations:
    konghq.com/gatewayclass-unmanaged: 'true'
spec:
  controllerName: konghq.com/kic-gateway-controller

apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: kong
spec:
  gatewayClassName: kong
  listeners:
  - name: proxy
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
         from: All
" | kubectl apply -n kong -f -

```

Copied!
## [Konnect setup ](https://developer.konghq.com/kubernetes-ingress-controller/install/#konnect-setup "Konnect setup")
> For UI setup instructions to install Kong Ingress Controller on Konnect, use the [control plane setup UI](https://cloud.konghq.com/gateway-manager/create-gateway).
To create a Kong Ingress Controller in Konnect deployment, you need the following items:
  1. A Kong Ingress Controller control plane, including the control plane URL.
  2. An mTLS certificate for Kong Ingress Controller to talk to Konnect.


### [Create a KIC in Konnect Control Plane ](https://developer.konghq.com/kubernetes-ingress-controller/install/#create-a-kic-in-konnect-control-plane "Create a KIC in Konnect Control Plane")
Use the Konnect API to create a new `CLUSTER_TYPE_K8S_INGRESS_CONTROLLER` Control Plane:
```
CONTROL_PLANE_DETAILS=$(curl -X POST "https://us.api.konghq.com/v2/control-planes" \
     --no-progress-meter --fail-with-body  \
"Authorization: Bearer $KONNECT_TOKEN" \
     --json '{
       "name": "My KIC CP",
       "cluster_type": "CLUSTER_TYPE_K8S_INGRESS_CONTROLLER"



```

Copied!
We’ll need the `id` and `telemetry_endpoint` for the `values.yaml` file later. Save them as environment variables:
```
CONTROL_PLANE_ID=$(echo $CONTROL_PLANE_DETAILS | jq -r .id)
CONTROL_PLANE_TELEMETRY=$(echo $CONTROL_PLANE_DETAILS | jq -r '.config.telemetry_endpoint | sub("https://";"")')

```

Copied!
### [Create mTLS certificates ](https://developer.konghq.com/kubernetes-ingress-controller/install/#create-mtls-certificates "Create mTLS certificates")
Kong Ingress Controller talks to Konnect over a connected secured with TLS certificates.
Generate a new certificate using `openssl`:
```
openssl req -new -x509 -nodes -newkey rsa:2048 -subj "/CN=kongdp/C=US" -keyout ./tls.key -out ./tls.crt

```

Copied!
The certificate needs to be a single line string to send it to the Konnect API with curl. Use `awk` to format the certificate:
```
export CERT=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' tls.crt);

```

Copied!
Next, upload the certificate to Konnect:
```
curl -X POST "https://us.api.konghq.com/v2/control-planes/$CONTROL_PLANE_ID/dp-client-certificates" \
     --no-progress-meter --fail-with-body  \
     -H "Authorization: Bearer $KONNECT_TOKEN" \
     --json '{
       "cert": "'$CERT'"


```

Copied!
Finally, store the certificate in a Kubernetes secret so that Kong Ingress Controller can read it:
```
kubectl create namespace kong -o yaml --dry-run=client | kubectl apply -f -
kubectl create secret tls konnect-client-tls -n kong --cert=./tls.crt --key=./tls.key

```

Copied!
### [Create a values.yaml ](https://developer.konghq.com/kubernetes-ingress-controller/install/#create-a-values-yaml "Create a values.yaml")
Kong Ingress Controller must be configured to send it’s configuration to Konnect. Create a `values.yaml` file by copying and pasting the following command into your terminal:
```
echo 'controller:
  ingressController:
    image:
      tag: 3.5
    env:
      feature_gates: "FillIDs=true"
    konnect:
      license:
        enabled: true
      enabled: true
      controlPlaneID: "'$CONTROL_PLANE_ID'"
      tlsClientCertSecretName: konnect-client-tls
      apiHostname: "us.kic.api.konghq.com"

gateway:
  image:
    repository: kong/kong-gateway
    tag: "3.13"
  env:
    konnect_mode: 'on'
    vitals: "off"
    cluster_mtls: pki
    cluster_telemetry_endpoint: "'$CONTROL_PLANE_TELEMETRY':443"
    cluster_telemetry_server_name: "'$CONTROL_PLANE_TELEMETRY'"
    cluster_cert: /etc/secrets/konnect-client-tls/tls.crt
    cluster_cert_key: /etc/secrets/konnect-client-tls/tls.key
    lua_ssl_trusted_certificate: system
    proxy_access_log: "off"
    dns_stale_ttl: "3600"
  resources:
    requests:
      cpu: 1
      memory: "2Gi"
  secretVolumes:
    - konnect-client-tls' values.yaml

```

Copied!
## [Install Kong ](https://developer.konghq.com/kubernetes-ingress-controller/install/#install-kong "Install Kong")
Kong provides Helm charts to install Kong Ingress Controller. Add the Kong charts repo and update to the latest version:
```
helm repo add kong https://charts.konghq.com
helm repo update

```

Copied!
The default values file installs Kong Ingress Controller in [Gateway Discovery](https://developer.konghq.com/kubernetes-ingress-controller/install/) mode with a DB-less Kong Gateway. This is the recommended deployment topology.
Run the following command to install Kong Ingress Controller:
```
helm upgrade --install kong kong/ingress -n kong --values ./values.yaml

```

Copied!
```
helm install kong kong/ingress -n kong --create-namespace

```

Copied!
## [Test connectivity to Kong ](https://developer.konghq.com/kubernetes-ingress-controller/install/#test-connectivity-to-kong "Test connectivity to Kong")
Call the proxy IP:
```
export PROXY_IP=$(kubectl get svc --namespace kong kong-gateway-proxy -o jsonpath='{range .status.loadBalancer.ingress[0]}{@.ip}{@.hostname}{end}')
curl -i $PROXY_IP

```

Copied!
You will receive an `HTTP 404` response as there are no routes configured:
```
HTTP/1.1 404 Not Found
Content-Type: application/json; charset=utf-8
Connection: keep-alive
Content-Length: 48
X-Kong-Response-Latency: 0
Server: kong/3.9.1

{"message":"no Route matched with those values"}

```

Copied!
[ Why is my KIC instance read-only in Konnect? ](https://developer.konghq.com/kubernetes-ingress-controller/install/#why-is-my-kic-instance-read-only-in-konnect)
Because Kubernetes resources are the source of truth for configuring Kong Gateway in Kubernetes, the KIC instance configuration in Konnect is marked as read-only. This prevents configuration drift in Kong Gateway caused by changes made outside the Ingress or Kubernetes Gateway API.
For example, if a Route is created via the Kubernetes Gateway API and then modified in Kong Gateway, those changes wouldn’t be reflected in the CRD and would conflict with the desired state defined in the CRD.
[ I’m using AWS CDK, can I manage Kong resources with CDK instead of Kong Ingress Controller? ](https://developer.konghq.com/kubernetes-ingress-controller/install/#i-m-using-aws-cdk-can-i-manage-kong-resources-with-cdk-instead-of-kong-ingress-controller)
Currently, you can’t manage Kong resources via AWS CDK. We recommend managing Kong configurations by [deploying decK](https://developer.konghq.com/deck/) or custom automation (for example, Lambda functions) through CDK that interact with the [Admin API](https://developer.konghq.com/admin-api/).
[ Next → 2. Services and Routes ](https://developer.konghq.com/kubernetes-ingress-controller/get-started/services-and-routes/)
### Did this doc help?
YesNo
Something wrong?
[Report an Issue](https://github.com/Kong/developer.konghq.com/issues/) | [Edit this Page](https://github.com/Kong/developer.konghq.com/edit/main/app/_how-tos/kubernetes-ingress-controller/kic-install.md)
### Help us make these docs great!
Kong Developer docs are open source. If you find these useful and want to make them better, contribute today!
### Still need help
[ Ask in our Forum ](https://discuss.konghq.com/) [ Contact Support ](https://support.konghq.com/support/s/)
## Do Not Sell My Personal Information
When you visit our website, we store cookies on your browser to collect information. The information collected might relate to you, your preferences or your device, and is mostly used to make the site work as you expect it to and to provide a more personalized web experience. However, you can choose not to allow certain types of cookies, which may impact your experience of the site and the services we are able to offer. Click on the different category headings to find out more and change our default settings according to your preference. You cannot opt-out of our First Party Strictly Necessary Cookies as they are deployed in order to ensure the proper functioning of our website (such as prompting the cookie banner and remembering your settings, to log into your account, to redirect you when you log out, etc.). For more information about the First and Third Party Cookies used please follow this link.
Allow All
###  Manage Consent Preferences
#### Strictly Necessary Cookies
Always Active
These cookies are necessary for the website to function and cannot be switched off in our systems. They are usually only set in response to actions made by you which amount to a request for services, such as setting your privacy preferences, logging in or filling in forms. You can set your browser to block or alert you about these cookies, but some parts of the site will not then work. These cookies do not store any personally identifiable information.
#### Sale of Personal Data
Sale of Personal Data
Under the California Consumer Privacy Act, you have the right to opt-out of the sale of your personal information to third parties. These cookies collect information for analytics and to personalize your experience with targeted ads. You may exercise your right to opt out of the sale of personal information by using this toggle switch. If you opt out we will not be able to offer you personalised ads and will not hand over your personal information to any third parties. Additionally, you may contact our legal department for further clarification about your rights as a California consumer by using this Exercise My Rights link.If you have enabled privacy controls on your browser (such as a plugin), we have to take that as a valid request to opt-out. Therefore we would not be able to track your activity through the web. This may affect our ability to personalize ads according to your preferences.
  * ##### Performance Cookies
Switch Label label
These cookies allow us to count visits and traffic sources so we can measure and improve the performance of our site. They help us to know which pages are the most and least popular and see how visitors move around the site. All information these cookies collect is aggregated and therefore anonymous. If you do not allow these cookies we will not know when you have visited our site, and will not be able to monitor its performance.


  * ##### Targeting Cookies
Switch Label label
These cookies may be set through our site by our advertising partners. They may be used by those companies to build a profile of your interests and show you relevant adverts on other sites. They do not store directly personal information, but are based on uniquely identifying your browser and internet device. If you do not allow these cookies, you will experience less targeted advertising.


Back Button
### Cookie List
Search Icon
Filter Icon
Clear
checkbox label label
Apply Cancel
Consent Leg.Interest
checkbox label label
checkbox label label
checkbox label label
Confirm My Choices

