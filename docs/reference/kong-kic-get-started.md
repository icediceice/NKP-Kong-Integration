[ ](https://developer.konghq.com/)
SearchCommand or control keyK key
Ask AI
[ ](https://developer.konghq.com/)
  * Platform
Explore the platform
[ Konnect  ](https://developer.konghq.com/konnect/)
Build APIs
[ Kong Insomnia  ](https://developer.konghq.com/insomnia/) [ API Design  ](https://developer.konghq.com/insomnia/design/) [ API Testing and Debugging  ](https://developer.konghq.com/insomnia/test/)
Run APIs
[ API Gateway  ](https://developer.konghq.com/gateway/) [ AI Gateway  ](https://developer.konghq.com/ai-gateway/) [ Event Gateway  ](https://developer.konghq.com/event-gateway/) [ Service Mesh  ](https://developer.konghq.com/mesh/) [ Kong Ingress Controller  ](https://developer.konghq.com/kubernetes-ingress-controller/) [ Kubernetes Operator  ](https://developer.konghq.com/operator/)
Govern APIs
[ Observability  ](https://developer.konghq.com/observability/) [ Metering & Billing  ](https://developer.konghq.com/metering-and-billing/) [ Scorecards  ](https://developer.konghq.com/catalog/scorecards/) [ API Security & Access Control  ](https://developer.konghq.com/gateway/security/)
Discover APIs
[ Developer Portal  ](https://developer.konghq.com/dev-portal/) [ Catalog  ](https://developer.konghq.com/catalog/)
Tools
    * [ decK ](https://developer.konghq.com/deck/)
    * [ kongctl ](https://developer.konghq.com/kongctl/)
    * [ Inso CLI ](https://developer.konghq.com/inso-cli/)
    * [ Terraform ](https://developer.konghq.com/terraform/)
    * [ Ingress controller ](https://developer.konghq.com/kubernetes-ingress-controller/)
    * [ View all → ](https://developer.konghq.com/tools/)
[ Why Kong? ](https://konghq.com/company/why-kong)
Kong's SaaS API management platform designed to simplify managing and securing APIs. 
[Learn more →](https://developer.konghq.com/konnect/)
  * Guides
    * [ API Gateway → ](https://developer.konghq.com/how-to/?products=gateway)
    * [ AI Gateway → ](https://developer.konghq.com/how-to/?products=ai-gateway)
    * [ Event Gateway → ](https://developer.konghq.com/how-to/?products=event-gateway)
    * [ Insomnia → ](https://developer.konghq.com/how-to/?products=insomnia)
    * [ Kong Ingress Controller → ](https://developer.konghq.com/how-to/?products=kic)
    * [ Kubernetes Operator → ](https://developer.konghq.com/how-to/?products=operator)
    * [ Kong Mesh → ](https://developer.konghq.com/how-to/?products=mesh)
    * [ Dev Portal → ](https://developer.konghq.com/how-to/?products=dev-portal)
    * [ Catalog → ](https://developer.konghq.com/how-to/?products=catalog)
    * [View all →](https://developer.konghq.com/how-to/)
  * Plugins
    * [ AI ](https://developer.konghq.com/plugins/?category=ai)
    * [ Authentication ](https://developer.konghq.com/plugins/?category=authentication)
    * [ Security ](https://developer.konghq.com/plugins/?category=security)
    * [ Traffic Control ](https://developer.konghq.com/plugins/?category=traffic-control)
    * [ Serverless ](https://developer.konghq.com/plugins/?category=serverless)
    * [ Analytics & Monitoring ](https://developer.konghq.com/plugins/?category=analytics-monitoring)
    * [ Transformations ](https://developer.konghq.com/plugins/?category=transformations)
    * [ Logging ](https://developer.konghq.com/plugins/?category=logging)
    * [View all →](https://developer.konghq.com/plugins)
  * [ APIs ](https://developer.konghq.com/api/)
  * Support
    * [ Community ](https://konghq.com/community)
    * [ Github ](https://github.com/Kong/kong)
    * [ Community Forum ](https://discuss.konghq.com/)
    * [ Kong Pricing ](https://konghq.com/pricing)
    * [ Demos ](https://konghq.com/resources/demos)
    * [ User Calls ](https://konghq.com/events/user-calls)
    * [ Workshops ](https://konghq.com/events/workshops)
    * [ Help & Support ](https://support.konghq.com/s/)


Theme
[Get a Demo](https://konghq.com/contact-sales?utm_medium=referral&utm_source=docs&utm_content=top-nav) [Start Free Trial](https://konghq.com/products/kong-konnect/register?utm_medium=referral&utm_source=docs&utm_content=top-nav)
[Home](https://developer.konghq.com/) / [Kong Ingress Controller](https://developer.konghq.com/kubernetes-ingress-controller/)
[ Edit this Page Edit ](https://github.com/Kong/developer.konghq.com/edit/main/app/_how-tos/kubernetes-ingress-controller/kic-install.md) [ Report an Issue Report ](https://github.com/Kong/developer.konghq.com/issues/)
# Install Kong Ingress Controller
Uses:  [Kong Ingress Controller](https://developer.konghq.com/kubernetes-ingress-controller/)
Deployment Platform
konnect
on-prem
Related Documentation
[ ](https://developer.konghq.com/index/kubernetes-ingress-controller/)
In This Series
  1. [Install Kong Ingress Controller](https://developer.konghq.com/kubernetes-ingress-controller/install/)
  2. [Services and Routes](https://developer.konghq.com/kubernetes-ingress-controller/get-started/services-and-routes/)
  3. [Rate Limiting](https://developer.konghq.com/kubernetes-ingress-controller/get-started/rate-limiting/)
  4. [Proxy Caching](https://developer.konghq.com/kubernetes-ingress-controller/get-started/proxy-caching/)
  5. [Key Authentication](https://developer.konghq.com/kubernetes-ingress-controller/get-started/key-authentication/)


Tags
[#install](https://developer.konghq.com/search/?tags=install) [#helm](https://developer.konghq.com/search/?tags=helm)
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
---
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: kong
  annotations:
    konghq.com/gatewayclass-unmanaged: 'true'
spec:
  controllerName: konghq.com/kic-gateway-controller
---
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
     -H "Authorization: Bearer $KONNECT_TOKEN" \
     --json '{
       "name": "My KIC CP",
       "cluster_type": "CLUSTER_TYPE_K8S_INGRESS_CONTROLLER"
     }'
)

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
     }'

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
    - konnect-client-tls' > values.yaml

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
## [FAQs ](https://developer.konghq.com/kubernetes-ingress-controller/install/#faqs "FAQs")
[ Why is my KIC instance read-only in Konnect? ](https://developer.konghq.com/kubernetes-ingress-controller/install/#why-is-my-kic-instance-read-only-in-konnect)
Because Kubernetes resources are the source of truth for configuring Kong Gateway in Kubernetes, the KIC instance configuration in Konnect is marked as read-only. This prevents configuration drift in Kong Gateway caused by changes made outside the Ingress or Kubernetes Gateway API.
For example, if a Route is created via the Kubernetes Gateway API and then modified in Kong Gateway, those changes wouldn’t be reflected in the CRD and would conflict with the desired state defined in the CRD.
[ I’m using AWS CDK, can I manage Kong resources with CDK instead of Kong Ingress Controller? ](https://developer.konghq.com/kubernetes-ingress-controller/install/#i-m-using-aws-cdk-can-i-manage-kong-resources-with-cdk-instead-of-kong-ingress-controller)
Currently, you can’t manage Kong resources via AWS CDK. We recommend managing Kong configurations by [deploying decK](https://developer.konghq.com/deck/) or custom automation (for example, Lambda functions) through CDK that interact with the [Admin API](https://developer.konghq.com/admin-api/).
[ Next → 2. Services and Routes ](https://developer.konghq.com/kubernetes-ingress-controller/get-started/services-and-routes/)
Deployment Platform
konnect
on-prem
Related Documentation
[ ](https://developer.konghq.com/index/kubernetes-ingress-controller/)
In This Series
  1. [Install Kong Ingress Controller](https://developer.konghq.com/kubernetes-ingress-controller/install/)
  2. [Services and Routes](https://developer.konghq.com/kubernetes-ingress-controller/get-started/services-and-routes/)
  3. [Rate Limiting](https://developer.konghq.com/kubernetes-ingress-controller/get-started/rate-limiting/)
  4. [Proxy Caching](https://developer.konghq.com/kubernetes-ingress-controller/get-started/proxy-caching/)
  5. [Key Authentication](https://developer.konghq.com/kubernetes-ingress-controller/get-started/key-authentication/)


Tags
[#install](https://developer.konghq.com/search/?tags=install) [#helm](https://developer.konghq.com/search/?tags=helm)
Related Resources
[All KIC documentation](https://developer.konghq.com/index/kubernetes-ingress-controller/)
  * [Install Kong Ingress Controller](https://developer.konghq.com/kubernetes-ingress-controller/install/#install-site-kic-product-name)
  * [Prerequisites](https://developer.konghq.com/kubernetes-ingress-controller/install/#prerequisites)
  * [Konnect setup](https://developer.konghq.com/kubernetes-ingress-controller/install/#konnect-setup)
  * [Install Kong](https://developer.konghq.com/kubernetes-ingress-controller/install/#install-kong)
  * [Test connectivity to Kong](https://developer.konghq.com/kubernetes-ingress-controller/install/#test-connectivity-to-kong)
  * [FAQs](https://developer.konghq.com/kubernetes-ingress-controller/install/#faqs)


### Did this doc help?
YesNo
Something wrong?
[Report an Issue](https://github.com/Kong/developer.konghq.com/issues/) | [Edit this Page](https://github.com/Kong/developer.konghq.com/edit/main/app/_how-tos/kubernetes-ingress-controller/kic-install.md)
### Help us make these docs great!
Kong Developer docs are open source. If you find these useful and want to make them better, contribute today!
[Contribute](https://github.com/Kong/developer.konghq.com)
### Still need help
[ Ask in our Forum ](https://discuss.konghq.com/) [ Contact Support ](https://support.konghq.com/support/s/)
![Kong Logo](https://developer.konghq.com/assets/logos/brand/KongPrimary.svg) ![Kong Logo](https://developer.konghq.com/assets/logos/brand/Kong-Logotype.svg)
##### Powering the API world
Increase developer productivity, security, and performance at scale with the unified platform for API management, service mesh, and ingress controller.
Ready to get started with Kong?
[Start free trial](https://konghq.com/products/kong-konnect/register?utm_medium=referral&utm_source=docs&utm_content=footer) [Get a Demo](https://konghq.com/contact-sales?utm_medium=referral&utm_source=docs&utm_content=footer)
Platform
[API Platform](https://konghq.com/products/kong-konnect) [API Gateway](https://konghq.com/products/kong-gateway) [AI Gateway](https://konghq.com/products/kong-ai-gateway) [Service Mesh](https://konghq.com/products/kong-mesh) [API Builder](https://konghq.com/products/kong-insomnia) [Pricing](https://konghq.com/pricing)
Platorm Docs
[Kong Gateway](https://developer.konghq.com/gateway/) [Kong AI Gateway](https://developer.konghq.com/ai-gateway/) [Kong Mesh](https://developer.konghq.com/mesh/) [Insomnia](https://developer.konghq.com/insomnia/) [OpenAPI Specs](https://developer.konghq.com/api/) [Ingress Controller](https://developer.konghq.com/kubernetes-ingress-controller/)
Plugins
[AI Plugins](https://developer.konghq.com/plugins/?category=ai) [Analytics Plugins](https://developer.konghq.com/plugins/?category=analytics-monitoring) [Authentication Plugins](https://developer.konghq.com/plugins/?category=authentication) [Security Plugins](https://developer.konghq.com/plugins/?category=security) [Traffic Control Plugins](https://developer.konghq.com/plugins/?category=traffic-control) [View all →](https://developer.konghq.com/plugins/)
How-to Guides
[Kong Gateway](https://developer.konghq.com/how-to/?products=gateway) [Insomnia](https://developer.konghq.com/how-to/?products=insomnia) [Kong Mesh](https://developer.konghq.com/how-to/?products=mesh) [Terraform](https://developer.konghq.com/how-to/?tools=deck) [View all →](https://developer.konghq.com/how-to/)
Support
[Community](https://konghq.com/community) [Community Forum](https://discuss.konghq.com/) [GitHub](https://github.com/Kong/kong) [Demos](https://konghq.com/resources/demos) [User Calls](https://konghq.com/events/user-calls) [Workshops](https://konghq.com/events/workshops) [Help & Support](https://support.konghq.com/s/) [Contact Us](https://konghq.com/company/contact-us)
[ ](https://github.com/kong/kong) [ ](https://www.meetup.com/topics/kong/all) [ ](https://www.linkedin.com/company/konghq) [ ](https://x.com/kong) [ ](https://www.youtube.com/@KongInc)
[Terms](https://konghq.com/legal/terms-of-use) | [Privacy](https://konghq.com/legal/privacy-policy) | [Trust and Compliance](https://konghq.com/compliance)
© Kong Inc. 2026 
