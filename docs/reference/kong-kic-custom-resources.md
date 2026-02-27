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
[ Edit this Page Edit ](https://github.com/Kong/developer.konghq.com/edit/main/app/kubernetes-ingress-controller/reference/custom-resources.md) [ Report an Issue Report ](https://github.com/Kong/developer.konghq.com/issues/)
# Custom Resource (CRD) API Reference
Uses:  [Kong Ingress Controller](https://developer.konghq.com/kubernetes-ingress-controller/)
Related Documentation
[ ](https://developer.konghq.com/index/kubernetes-ingress-controller/)
Tags
[#crd](https://developer.konghq.com/search/?tags=crd)
Related Resources
[Gateway API](https://developer.konghq.com/kubernetes-ingress-controller/gateway-api/)
## [Packages ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#packages "Packages")
  * [configuration.konghq.com/v1](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#configurationkonghqcomv1)
  * [configuration.konghq.com/v1alpha1](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#configurationkonghqcomv1alpha1)
  * [configuration.konghq.com/v1beta1](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#configurationkonghqcomv1beta1)


## [configuration.konghq.com/v1 ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#configuration-konghq-com-v1 "configuration.konghq.com/v1")
Package v1 contains API Schema definitions for the konghq.com v1 API group.
  * [KongClusterPlugin](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongclusterplugin)
  * [KongConsumer](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongconsumer)
  * [KongIngress](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongingress)
  * [KongPlugin](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongplugin)
### [KongClusterPlugin ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongclusterplugin "KongClusterPlugin")


KongClusterPlugin is the Schema for the kongclusterplugins API.
The only differences between KongPlugin and KongClusterPlugin are that KongClusterPlugin is a Kubernetes cluster-level resource instead of a namespaced resource, and it can be applied as a global plugin using the `global` label.
Field | Description  
---|---  
`apiVersion` _string_ | `configuration.konghq.com/v1`  
`kind` _string_ | `KongClusterPlugin`  
`metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`.  
`consumerRef` _string_ | ConsumerRef is a reference to a particular consumer.  
`disabled` _boolean_ | Disabled set if the plugin is disabled or not.  
`config` _[JSON](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#json-v1-apiextensions-k8s-io)_ | Config contains the plugin configuration. It’s a list of keys and values required to configure the plugin. Please read the documentation of the plugin being configured to set values in here. For any plugin in Kong, anything that goes in the `config` JSON key in the Admin API request, goes into this property. Only one of `config` or `configFrom` may be used in a KongClusterPlugin, not both at once.  
`configFrom` _[NamespacedConfigSource](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#namespacedconfigsource)_ | ConfigFrom references a secret containing the plugin configuration. This should be used when the plugin configuration contains sensitive information, such as AWS credentials in the Lambda plugin or the client secret in the OIDC plugin. Only one of `config` or `configFrom` may be used in a KongClusterPlugin, not both at once.  
`configPatches` _[NamespacedConfigPatch](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#namespacedconfigpatch) array_ | ConfigPatches represents JSON patches to the configuration of the plugin. Each item means a JSON patch to add something in the configuration, where path is specified in `path` and value is in `valueFrom` referencing a key in a secret. When Config is specified, patches will be applied to the configuration in Config. Otherwise, patches will be applied to an empty object.  
`plugin` _string_ | PluginName is the name of the plugin to which to apply the config.  
`run_on` _string_ | RunOn configures the plugin to run on the first or the second or both nodes in case of a service mesh deployment.  
`protocols` _[KongProtocol](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongprotocol) array_ | Protocols configures plugin to run on requests received on specific protocols.  
`ordering` _[PluginOrdering](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#pluginordering)_ | Ordering overrides the normal plugin execution order. It’s only available on Kong Enterprise. `<phase>` is a request processing phase (for example, `access` or `body_filter`) and `<plugin>` is the name of the plugin that will run before or after the KongPlugin. For example, a KongPlugin with `plugin: rate-limiting` and `before.access: ["key-auth"]` will create a rate limiting plugin that limits requests _before_ they are authenticated.  
`instance_name` _string_ | InstanceName is an optional custom name to identify an instance of the plugin. This is useful when running the same plugin in multiple contexts, for example, on multiple services.  
### [KongConsumer ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongconsumer "KongConsumer")
KongConsumer is the Schema for the kongconsumers API.
When this resource is created, a corresponding Consumer entity will be created in Kong Gateway. While KongConsumer exists in a specific Kubernetes namespace, KongConsumers from all namespaces are combined into a single Kong Gateway configuration, and no KongConsumers with the same `kubernetes.io/ingress.class` may share the same Username or CustomID value.
Field | Description  
---|---  
`apiVersion` _string_ | `configuration.konghq.com/v1`  
`kind` _string_ | `KongConsumer`  
`metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`.  
`username` _string_ | Username is a Kong cluster-unique username of the consumer.  
`custom_id` _string_ | CustomID is a Kong cluster-unique existing ID for the consumer - useful for mapping Kong with users in your existing database.  
`credentials` _string array_ | Credentials are references to secrets containing a credential to be provisioned in Kong.  
`consumerGroups` _string array_ | ConsumerGroups are references to consumer groups (that consumer wants to be part of) provisioned in Kong.  
`spec` _[KongConsumerSpec](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongconsumerspec)_ |   
### [KongIngress ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongingress "KongIngress")
KongIngress is the Schema for the kongingresses API. Deprecated: Use annotations and KongUpstreamPolicy instead. See https://developer.konghq.com/kubernetes-ingress-controller/migrate/kongingress/
It serves as an “extension” to Ingress resource. It is not meant as a replacement to the Ingress resource in Kubernetes. The Ingress resource spec in Kubernetes can define routing policies based on HTTP Host header and paths. While this is sufficient in most cases, sometimes, users may want more control over routing at the Ingress level. Once a `KongIngress` resource is created, it needs to be associated with an Ingress or Service resource using the `konghq.com/override` annotation.
> KongIngress is not supported on Gateway APIs resources, such as HTTPRoute and TCPRoute. These resources must use annotations.
> As of version 2.8, KongIngress sections other than `upstream` are [deprecated](https://github.com/Kong/kubernetes-ingress-controller/issues/3018). All settings in the `proxy` and `route` sections are now available with dedicated annotations, and these annotations will become the only means of configuring those settings in a future release. For example, if you had set `proxy.connect_timeout: 30000` in a KongIngress and applied an `konghq.com/override` annotation for that KongIngress to a Service, you will need to instead apply a `konghq.com/connect-timeout: 30000` annotation to the Service.
> Plans are to replace the `upstream` section of KongIngress with [a new resource](https://github.com/Kong/kubernetes-ingress-controller/issues/3174), but this is still in development and `upstream` is not yet officially deprecated.
Field | Description  
---|---  
`apiVersion` _string_ | `configuration.konghq.com/v1`  
`kind` _string_ | `KongIngress`  
`metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`.  
`upstream` _[KongIngressUpstream](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongingressupstream)_ | Upstream represents a virtual hostname and can be used to loadbalance incoming requests over multiple targets (e.g. Kubernetes `Services` can be a target, OR `Endpoints` can be targets).  
`proxy` _[KongIngressService](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongingressservice)_ | Proxy defines additional connection options for the routes to be configured in the Kong Gateway, e.g. `connection_timeout`, `retries`, etc.  
`route` _[KongIngressRoute](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongingressroute)_ | Route define rules to match client requests. Each Route is associated with a Service, and a Service may have multiple Routes associated to it.  
### [KongPlugin ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongplugin "KongPlugin")
KongPlugin is the Schema for the kongplugins API.
Plugins can be associated with the `Ingress`, `Service`, `HTTPRoute`, `KongConsumer` or `KongConsumerGroup` object in Kubernetes using `konghq.com/plugins` annotation.
Field | Description  
---|---  
`apiVersion` _string_ | `configuration.konghq.com/v1`  
`kind` _string_ | `KongPlugin`  
`metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`.  
`consumerRef` _string_ | ConsumerRef is a reference to a particular consumer.  
`disabled` _boolean_ | Disabled set if the plugin is disabled or not.  
`config` _[JSON](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#json-v1-apiextensions-k8s-io)_ | Config contains the plugin configuration. It’s a list of keys and values required to configure the plugin. Please read the documentation of the plugin being configured to set values in here. For any plugin in Kong, anything that goes in the `config` JSON key in the Admin API request, goes into this property. Only one of `config` or `configFrom` may be used in a KongPlugin, not both at once.  
`configFrom` _[ConfigSource](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#configsource)_ | ConfigFrom references a secret containing the plugin configuration. This should be used when the plugin configuration contains sensitive information, such as AWS credentials in the Lambda plugin or the client secret in the OIDC plugin. Only one of `config` or `configFrom` may be used in a KongPlugin, not both at once.  
`configPatches` _[ConfigPatch](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#configpatch) array_ | ConfigPatches represents JSON patches to the configuration of the plugin. Each item means a JSON patch to add something in the configuration, where path is specified in `path` and value is in `valueFrom` referencing a key in a secret. When Config is specified, patches will be applied to the configuration in Config. Otherwise, patches will be applied to an empty object.  
`plugin` _string_ | PluginName is the name of the plugin to which to apply the config.  
`run_on` _string_ | RunOn configures the plugin to run on the first or the second or both nodes in case of a service mesh deployment.  
`protocols` _[KongProtocol](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongprotocol) array_ | Protocols configures plugin to run on requests received on specific protocols.  
`ordering` _[PluginOrdering](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#pluginordering)_ | Ordering overrides the normal plugin execution order. It’s only available on Kong Enterprise. `<phase>` is a request processing phase (for example, `access` or `body_filter`) and `<plugin>` is the name of the plugin that will run before or after the KongPlugin. For example, a KongPlugin with `plugin: rate-limiting` and `before.access: ["key-auth"]` will create a rate limiting plugin that limits requests _before_ they are authenticated.  
`instance_name` _string_ | InstanceName is an optional custom name to identify an instance of the plugin. This is useful when running the same plugin in multiple contexts, for example, on multiple services.  
### [Types ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#types "Types")
In this section you will find types that the CRDs rely on.
#### [ConfigPatch ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#configpatch "ConfigPatch")
ConfigPatch is a JSON patch (RFC6902) to add values from Secret to the generated configuration. It is an equivalent of the following patch: `{"op": "add", "path": {.Path}, "value": {.ComputedValueFrom}}`.
Field | Description  
---|---  
`path` _string_ | Path is the JSON-Pointer value (RFC6901) that references a location within the target configuration.  
`valueFrom` _[ConfigSource](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#configsource)_ | ValueFrom is the reference to a key of a secret where the patched value comes from.  
_Appears in:_
  * [KongPlugin](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongplugin)


#### [ConfigSource ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#configsource "ConfigSource")
ConfigSource is a wrapper around SecretValueFromSource.
Field | Description  
---|---  
`secretKeyRef` _[SecretValueFromSource](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#secretvaluefromsource)_ | Specifies a name and a key of a secret to refer to. The namespace is implicitly set to the one of referring object.  
_Appears in:_
  * [ConfigPatch](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#configpatch)
  * [KongPlugin](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongplugin)


#### [KongConsumerSpec ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongconsumerspec "KongConsumerSpec")
KongConsumerSpec defines the specification of the KongConsumer.
Field | Description  
---|---  
`controlPlaneRef` _[ControlPlaneRef](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#controlplaneref)_ | ControlPlaneRef is a reference to a ControlPlane this Consumer is associated with.  
`tags` _[Tags](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#tags)_ | Tags is an optional set of tags applied to the consumer.  
_Appears in:_
  * [KongConsumer](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongconsumer)


#### [KongIngressRoute ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongingressroute "KongIngressRoute")
KongIngressRoute contains KongIngress route configuration. It contains the subset of `go-kong.kong.Route` fields supported by `kongstate.Route.overrideByKongIngress`. Deprecated: use Ingress’ annotations instead.
Field | Description  
---|---  
`methods` _string array_ | Methods is a list of HTTP methods that match this Route. Deprecated: use Ingress’ “konghq.com/methods” annotation instead.  
`headers` _object (keys:string, values:string array)_ | Headers contains one or more lists of values indexed by header name that will cause this Route to match if present in the request. The Host header cannot be used with this attribute. Deprecated: use Ingress’ “konghq.com/headers” annotation instead.  
`protocols` _[KongProtocol](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongprotocol) array_ | Protocols is an array of the protocols this Route should allow. Deprecated: use Ingress’ “konghq.com/protocols” annotation instead.  
`regex_priority` _integer_ | RegexPriority is a number used to choose which route resolves a given request when several routes match it using regexes simultaneously. Deprecated: use Ingress’ “konghq.com/regex-priority” annotation instead.  
`strip_path` _boolean_ | StripPath sets When matching a Route via one of the paths strip the matching prefix from the upstream request URL. Deprecated: use Ingress’ “konghq.com/strip-path” annotation instead.  
`preserve_host` _boolean_ | PreserveHost sets When matching a Route via one of the hosts domain names, use the request Host header in the upstream request headers. If set to false, the upstream Host header will be that of the Service’s host. Deprecated: use Ingress’ “konghq.com/preserve-host” annotation instead.  
`https_redirect_status_code` _integer_ | HTTPSRedirectStatusCode is the status code Kong responds with when all properties of a Route match except the protocol. Deprecated: use Ingress’ “ingress.kubernetes.io/force-ssl-redirect” or “konghq.com/https-redirect-status-code” annotations instead.  
`path_handling` _string_ | PathHandling controls how the Service path, Route path and requested path are combined when sending a request to the upstream. Deprecated: use Ingress’ “konghq.com/path-handling” annotation instead.  
`snis` _string array_ | SNIs is a list of SNIs that match this Route when using stream routing. Deprecated: use Ingress’ “konghq.com/snis” annotation instead.  
`request_buffering` _boolean_ | RequestBuffering sets whether to enable request body buffering or not. Deprecated: use Ingress’ “konghq.com/request-buffering” annotation instead.  
`response_buffering` _boolean_ | ResponseBuffering sets whether to enable response body buffering or not. Deprecated: use Ingress’ “konghq.com/response-buffering” annotation instead.  
_Appears in:_
  * [KongIngress](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongingress)


#### [KongIngressService ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongingressservice "KongIngressService")
KongIngressService contains KongIngress service configuration. It contains the subset of go-kong.kong.Service fields supported by kongstate.Service.overrideByKongIngress. Deprecated: use Service’s annotations instead.
Field | Description  
---|---  
`protocol` _string_ | The protocol used to communicate with the upstream. Deprecated: use Service’s “konghq.com/protocol” annotation instead.  
`path` _string_ | (optional) The path to be used in requests to the upstream server. Deprecated: use Service’s “konghq.com/path” annotation instead.  
`retries` _integer_ | The number of retries to execute upon failure to proxy. Deprecated: use Service’s “konghq.com/retries” annotation instead.  
`connect_timeout` _integer_ | The timeout in milliseconds for establishing a connection to the upstream server. Deprecated: use Service’s “konghq.com/connect-timeout” annotation instead.  
`read_timeout` _integer_ | The timeout in milliseconds between two successive read operations for transmitting a request to the upstream server. Deprecated: use Service’s “konghq.com/read-timeout” annotation instead.  
`write_timeout` _integer_ | The timeout in milliseconds between two successive write operations for transmitting a request to the upstream server. Deprecated: use Service’s “konghq.com/write-timeout” annotation instead.  
_Appears in:_
  * [KongIngress](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongingress)


#### [KongIngressUpstream ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongingressupstream "KongIngressUpstream")
KongIngressUpstream contains KongIngress upstream configuration. It contains the subset of `go-kong.kong.Upstream` fields supported by `kongstate.Upstream.overrideByKongIngress`.
Field | Description  
---|---  
`host_header` _string_ | HostHeader is The hostname to be used as Host header when proxying requests through Kong.  
`algorithm` _string_ | Algorithm is the load balancing algorithm to use. Accepted values are: “round-robin”, “consistent-hashing”, “least-connections”, “latency”.  
`slots` _integer_ | Slots is the number of slots in the load balancer algorithm.  
`healthchecks` _[Healthcheck](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#healthcheck)_ | Healthchecks defines the health check configurations in Kong.  
`hash_on` _string_ | HashOn defines what to use as hashing input. Accepted values are: “none”, “consumer”, “ip”, “header”, “cookie”, “path”, “query_arg”, “uri_capture”.  
`hash_fallback` _string_ | HashFallback defines What to use as hashing input if the primary hash_on does not return a hash. Accepted values are: “none”, “consumer”, “ip”, “header”, “cookie”.  
`hash_on_header` _string_ | HashOnHeader defines the header name to take the value from as hash input. Only required when “hash_on” is set to “header”.  
`hash_fallback_header` _string_ | HashFallbackHeader is the header name to take the value from as hash input. Only required when “hash_fallback” is set to “header”.  
`hash_on_cookie` _string_ | The cookie name to take the value from as hash input. Only required when “hash_on” or “hash_fallback” is set to “cookie”.  
`hash_on_cookie_path` _string_ | The cookie path to set in the response headers. Only required when “hash_on” or “hash_fallback” is set to “cookie”.  
`hash_on_query_arg` _string_ | HashOnQueryArg is the query string parameter whose value is the hash input when “hash_on” is set to “query_arg”.  
`hash_fallback_query_arg` _string_ | HashFallbackQueryArg is the “hash_fallback” version of HashOnQueryArg.  
`hash_on_uri_capture` _string_ | HashOnURICapture is the name of the capture group whose value is the hash input when “hash_on” is set to “uri_capture”.  
`hash_fallback_uri_capture` _string_ | HashFallbackURICapture is the “hash_fallback” version of HashOnURICapture.  
_Appears in:_
  * [KongIngress](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongingress)


#### [KongProtocol ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongprotocol "KongProtocol")
_Underlying type:_ `string`
KongProtocol is a valid Kong protocol. This alias is necessary to deal with https://github.com/kubernetes-sigs/controller-tools/issues/342
_Appears in:_
  * [KongClusterPlugin](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongclusterplugin)
  * [KongIngressRoute](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongingressroute)
  * [KongPlugin](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongplugin)


#### [NamespacedConfigPatch ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#namespacedconfigpatch "NamespacedConfigPatch")
NamespacedConfigPatch is a JSON patch to add values from secrets to KongClusterPlugin to the generated configuration of plugin in Kong.
Field | Description  
---|---  
`path` _string_ | Path is the JSON path to add the patch.  
`valueFrom` _[NamespacedConfigSource](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#namespacedconfigsource)_ | ValueFrom is the reference to a key of a secret where the patched value comes from.  
_Appears in:_
  * [KongClusterPlugin](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongclusterplugin)


#### [NamespacedConfigSource ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#namespacedconfigsource "NamespacedConfigSource")
NamespacedConfigSource is a wrapper around NamespacedSecretValueFromSource.
Field | Description  
---|---  
`secretKeyRef` _[NamespacedSecretValueFromSource](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#namespacedsecretvaluefromsource)_ | Specifies a name, a namespace, and a key of a secret to refer to.  
_Appears in:_
  * [KongClusterPlugin](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongclusterplugin)
  * [NamespacedConfigPatch](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#namespacedconfigpatch)


#### [NamespacedSecretValueFromSource ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#namespacedsecretvaluefromsource "NamespacedSecretValueFromSource")
NamespacedSecretValueFromSource represents the source of a secret value specifying the secret namespace.
Field | Description  
---|---  
`namespace` _string_ | The namespace containing the secret.  
`name` _string_ | The secret containing the key.  
`key` _string_ | The key containing the value.  
_Appears in:_
  * [NamespacedConfigSource](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#namespacedconfigsource)


#### [SecretValueFromSource ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#secretvaluefromsource "SecretValueFromSource")
SecretValueFromSource represents the source of a secret value.
Field | Description  
---|---  
`name` _string_ | The secret containing the key.  
`key` _string_ | The key containing the value.  
_Appears in:_
  * [ConfigSource](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#configsource)


## [configuration.konghq.com/v1alpha1 ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#configuration-konghq-com-v1alpha1 "configuration.konghq.com/v1alpha1")
Package v1alpha1 contains API Schema definitions for the configuration.konghq.com v1alpha1 API group.
  * [IngressClassParameters](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#ingressclassparameters)
  * [KongCustomEntity](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongcustomentity)
  * [KongLicense](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#konglicense)
  * [KongVault](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongvault)
### [IngressClassParameters ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#ingressclassparameters "IngressClassParameters")


IngressClassParameters is the Schema for the IngressClassParameters API.
Field | Description  
---|---  
`apiVersion` _string_ | `configuration.konghq.com/v1alpha1`  
`kind` _string_ | `IngressClassParameters`  
`metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`.  
`spec` _[IngressClassParametersSpec](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#ingressclassparametersspec)_ | Spec is the IngressClassParameters specification.  
### [KongCustomEntity ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongcustomentity "KongCustomEntity")
KongCustomEntity defines a “custom” Kong entity that KIC cannot support the entity type directly.
Field | Description  
---|---  
`apiVersion` _string_ | `configuration.konghq.com/v1alpha1`  
`kind` _string_ | `KongCustomEntity`  
`metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`.  
`spec` _[KongCustomEntitySpec](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongcustomentityspec)_ |   
### [KongLicense ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#konglicense "KongLicense")
KongLicense stores a Kong enterprise license to apply to managed Kong gateway instances.
Field | Description  
---|---  
`apiVersion` _string_ | `configuration.konghq.com/v1alpha1`  
`kind` _string_ | `KongLicense`  
`metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`.  
`rawLicenseString` _string_ | RawLicenseString is a string with the raw content of the license.  
`enabled` _boolean_ | Enabled is set to true to let controllers (like KIC or KGO) to reconcile it. Default value is true to apply the license by default.  
### [KongVault ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongvault "KongVault")
KongVault is the schema for kongvaults API which defines a custom Kong vault. A Kong vault is a storage to store sensitive data, where the values can be referenced in configuration of plugins. See: https://docs.konghq.com/gateway/latest/kong-enterprise/secrets-management/
Field | Description  
---|---  
`apiVersion` _string_ | `configuration.konghq.com/v1alpha1`  
`kind` _string_ | `KongVault`  
`metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`.  
`spec` _[KongVaultSpec](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongvaultspec)_ |   
### [Types ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#types "Types")
In this section you will find types that the CRDs rely on.
#### [ControllerReference ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#controllerreference "ControllerReference")
ControllerReference is a reference to a controller that reconciles the KongLicense.
Field | Description  
---|---  
`group` _[Group](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#group)_ | Group is the group of referent. It should be empty if the referent is in “core” group (like pod).  
`kind` _[Kind](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kind)_ | Kind is the kind of the referent. By default the nil kind means kind Pod.  
`namespace` _[Namespace](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#namespace)_ | Namespace is the namespace of the referent. It should be empty if the referent is cluster scoped.  
`name` _[ObjectName](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#objectname)_ | Name is the name of the referent.  
_Appears in:_
  * [KongLicenseControllerStatus](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#konglicensecontrollerstatus)


#### [IngressClassParametersSpec ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#ingressclassparametersspec "IngressClassParametersSpec")
IngressClassParametersSpec defines the desired state of IngressClassParameters.
Field | Description  
---|---  
`serviceUpstream` _boolean_ | Offload load-balancing to kube-proxy or sidecar.  
`enableLegacyRegexDetection` _boolean_ | EnableLegacyRegexDetection automatically detects if ImplementationSpecific Ingress paths are regular expression paths using the legacy 2.x heuristic. The controller adds the “~” prefix to those paths if the Kong version is 3.0 or higher.  
_Appears in:_
  * [IngressClassParameters](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#ingressclassparameters)


#### [KongCustomEntitySpec ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongcustomentityspec "KongCustomEntitySpec")
KongCustomEntitySpec defines the specification of the KongCustomEntity.
Field | Description  
---|---  
`type` _string_ | EntityType is the type of the Kong entity. The type is used in generating declarative configuration.  
`fields` _[JSON](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#json-v1-apiextensions-k8s-io)_ | Fields defines the fields of the Kong entity itself.  
`controllerName` _string_ | ControllerName specifies the controller that should reconcile it, like ingress class.  
`parentRef` _[ObjectReference](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#objectreference)_ | ParentRef references the kubernetes resource it attached to when its scope is “attached”. Currently only KongPlugin/KongClusterPlugin allowed. This will make the custom entity to be attached to the entity(service/route/consumer) where the plugin is attached.  
_Appears in:_
  * [KongCustomEntity](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongcustomentity)


#### [KongVaultSpec ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongvaultspec "KongVaultSpec")
KongVaultSpec defines specification of a custom Kong vault.
Field | Description  
---|---  
`backend` _string_ | Backend is the type of the backend storing the secrets in the vault. The supported backends of Kong is listed here: https://docs.konghq.com/gateway/latest/kong-enterprise/secrets-management/backends/  
`prefix` _string_ | Prefix is the prefix of vault URI for referencing values in the vault. It is immutable after created.  
`description` _string_ | Description is the additional information about the vault.  
`config` _[JSON](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#json-v1-apiextensions-k8s-io)_ | Config is the configuration of the vault. Varies for different backends.  
`tags` _[Tags](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#tags)_ | Tags are the tags associated to the vault for grouping and filtering.  
`controlPlaneRef` _[ControlPlaneRef](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#controlplaneref)_ | ControlPlaneRef is a reference to a Konnect ControlPlane this KongVault is associated with.  
_Appears in:_
  * [KongVault](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongvault)


#### [ObjectName ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#objectname "ObjectName")
_Underlying type:_ `string`
ObjectName refers to the name of a Kubernetes object. Object names can have a variety of forms, including RFC1123 subdomains, RFC 1123 labels, or RFC 1035 labels.
_Appears in:_
  * [ControllerReference](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#controllerreference)


#### [ObjectReference ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#objectreference "ObjectReference")
ObjectReference defines reference of a kubernetes object.
Field | Description  
---|---  
`group` _string_ | Group defines the API group of the referred object.  
`kind` _string_ | Kind defines the kind of the referred object.  
`namespace` _string_ | Empty namespace means the same namespace of the owning object.  
`name` _string_ | Name defines the name of the referred object.  
_Appears in:_
  * [KongCustomEntitySpec](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongcustomentityspec)


## [configuration.konghq.com/v1beta1 ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#configuration-konghq-com-v1beta1 "configuration.konghq.com/v1beta1")
Package v1beta1 contains API Schema definitions for the configuration.konghq.com v1beta1 API group.
  * [KongConsumerGroup](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongconsumergroup)
  * [KongUpstreamPolicy](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreampolicy)
  * [TCPIngress](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#tcpingress)
  * [UDPIngress](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#udpingress)
### [KongConsumerGroup ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongconsumergroup "KongConsumerGroup")


KongConsumerGroup is the Schema for the kongconsumergroups API.
KongConsumerGroup resources create [Consumer Group](https://developer.konghq.com/gateway/entities/consumer-group/) resources.
Field | Description  
---|---  
`apiVersion` _string_ | `configuration.konghq.com/v1beta1`  
`kind` _string_ | `KongConsumerGroup`  
`metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`.  
`spec` _[KongConsumerGroupSpec](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongconsumergroupspec)_ |   
### [KongUpstreamPolicy ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreampolicy "KongUpstreamPolicy")
KongUpstreamPolicy allows configuring algorithm that should be used for load balancing traffic between Kong Upstream’s Targets. It also allows configuring health checks for Kong Upstream’s Targets.  
  
Its configuration is similar to Kong Upstream object (https://docs.konghq.com/gateway/latest/admin-api/#upstream-object), and it is applied to Kong Upstream objects created by the controller.  
  
It can be attached to Services. To attach it to a Service, it has to be annotated with `konghq.com/upstream-policy: <name>`, where `<name>` is the name of the KongUpstreamPolicy object in the same namespace as the Service.  
  
When attached to a Service, it will affect all Kong Upstreams created for the Service.  
  
When attached to a Service used in a Gateway API _Route rule with multiple BackendRefs, all of its Services MUST be configured with the same KongUpstreamPolicy. Otherwise, the controller will *ignore_ the KongUpstreamPolicy.  
  
Note: KongUpstreamPolicy doesn’t implement Gateway API’s GEP-713 strictly. In particular, it doesn’t use the TargetRef for attaching to Services and Gateway API *Routes - annotations are used instead. This is to allow reusing the same KongUpstreamPolicy for multiple Services and Gateway API *Routes.
See [customizing load balancing](https://developer.konghq.com/kubernetes-ingress-controller/load-balancing/).
Field | Description  
---|---  
`apiVersion` _string_ | `configuration.konghq.com/v1beta1`  
`kind` _string_ | `KongUpstreamPolicy`  
`metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`.  
`spec` _[KongUpstreamPolicySpec](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreampolicyspec)_ | Spec contains the configuration of the Kong upstream.  
### [TCPIngress ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#tcpingress "TCPIngress")
TCPIngress is the Schema for the tcpingresses API. Deprecated: Use Gateway API instead. See https://developer.konghq.com/kubernetes-ingress-controller/migrate/ingress-to-gateway/
The Ingress resource in Kubernetes is HTTP-only. This custom resource is modeled similar to the Ingress resource, but for TCP and TLS SNI based routing purposes.
Field | Description  
---|---  
`apiVersion` _string_ | `configuration.konghq.com/v1beta1`  
`kind` _string_ | `TCPIngress`  
`metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`.  
`spec` _[TCPIngressSpec](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#tcpingressspec)_ | Spec is the TCPIngress specification.  
### [UDPIngress ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#udpingress "UDPIngress")
UDPIngress is the Schema for the udpingresses API. Deprecated: Use Gateway API instead. See https://developer.konghq.com/kubernetes-ingress-controller/migrate/ingress-to-gateway/
It makes it possible to route traffic to your UDP services using Kong Gateway (for example, DNS or game servers). For each rule provided in the spec, the Kong Gateway proxy environment must be updated to listen to UDP on that port as well.
Field | Description  
---|---  
`apiVersion` _string_ | `configuration.konghq.com/v1beta1`  
`kind` _string_ | `UDPIngress`  
`metadata` _[ObjectMeta](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#objectmeta-v1-meta)_ | Refer to Kubernetes API documentation for fields of `metadata`.  
`spec` _[UDPIngressSpec](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#udpingressspec)_ | Spec is the UDPIngress specification.  
### [Types ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#types "Types")
In this section you will find types that the CRDs rely on.
#### [HTTPStatus ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#httpstatus "HTTPStatus")
_Underlying type:_ `integer`
HTTPStatus is an HTTP status code.
_Appears in:_
  * [KongUpstreamHealthcheckHealthy](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreamhealthcheckhealthy)
  * [KongUpstreamHealthcheckUnhealthy](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreamhealthcheckunhealthy)


#### [HashInput ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#hashinput "HashInput")
_Underlying type:_ `string`
HashInput is the input for consistent-hashing load balancing algorithm. It is required use “none” to disable hashing when “algorithm” is set to sticky sessions.
_Appears in:_
  * [KongUpstreamHash](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreamhash)


#### [IngressBackend ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#ingressbackend "IngressBackend")
IngressBackend describes all endpoints for a given service and port.
Field | Description  
---|---  
`serviceName` _string_ | Specifies the name of the referenced service.  
`servicePort` _integer_ | Specifies the port of the referenced service.  
_Appears in:_
  * [IngressRule](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#ingressrule)
  * [UDPIngressRule](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#udpingressrule)


#### [IngressRule ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#ingressrule "IngressRule")
IngressRule represents a rule to apply against incoming requests. Matching is performed based on an (optional) SNI and port.
Field | Description  
---|---  
`host` _string_ | Host is the fully qualified domain name of a network host, as defined by RFC 3986. If a Host is not specified, then port-based TCP routing is performed. Kong doesn’t care about the content of the TCP stream in this case. If a Host is specified, the protocol must be TLS over TCP. A plain-text TCP request cannot be routed based on Host. It can only be routed based on Port.  
`port` _integer_ | Port is the port on which to accept TCP or TLS over TCP sessions and route. It is a required field. If a Host is not specified, the requested are routed based only on Port.  
`backend` _[IngressBackend](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#ingressbackend)_ | Backend defines the referenced service endpoint to which the traffic will be forwarded to.  
_Appears in:_
  * [TCPIngressSpec](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#tcpingressspec)


#### [IngressTLS ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#ingresstls "IngressTLS")
IngressTLS describes the transport layer security.
Field | Description  
---|---  
`hosts` _string array_ | Hosts are a list of hosts included in the TLS certificate. The values in this list must match the name/s used in the tlsSecret. Defaults to the wildcard host setting for the loadbalancer controller fulfilling this Ingress, if left unspecified.  
`secretName` _string_ | SecretName is the name of the secret used to terminate SSL traffic.  
_Appears in:_
  * [TCPIngressSpec](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#tcpingressspec)


#### [KongConsumerGroupSpec ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongconsumergroupspec "KongConsumerGroupSpec")
KongConsumerGroupSpec defines the desired state of KongConsumerGroup.
Field | Description  
---|---  
`name` _string_ | Name is the name of the ConsumerGroup in Kong.  
`controlPlaneRef` _[ControlPlaneRef](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#controlplaneref)_ | ControlPlaneRef is a reference to a ControlPlane this ConsumerGroup is associated with.  
`tags` _[Tags](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#tags)_ | Tags is an optional set of tags applied to the ConsumerGroup.  
_Appears in:_
  * [KongConsumerGroup](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongconsumergroup)


#### [KongUpstreamActiveHealthcheck ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreamactivehealthcheck "KongUpstreamActiveHealthcheck")
KongUpstreamActiveHealthcheck configures active health check probing.
Field | Description  
---|---  
`type` _string_ | Type determines whether to perform active health checks using HTTP or HTTPS, or just attempt a TCP connection. Accepted values are “http”, “https”, “tcp”, “grpc”, “grpcs”.  
`concurrency` _integer_ | Concurrency is the number of targets to check concurrently.  
`healthy` _[KongUpstreamHealthcheckHealthy](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreamhealthcheckhealthy)_ | Healthy configures thresholds and HTTP status codes to mark targets healthy for an upstream.  
`unhealthy` _[KongUpstreamHealthcheckUnhealthy](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreamhealthcheckunhealthy)_ | Unhealthy configures thresholds and HTTP status codes to mark targets unhealthy for an upstream.  
`httpPath` _string_ | HTTPPath is the path to use in GET HTTP request to run as a probe.  
`httpsSni` _string_ | HTTPSSNI is the SNI to use in GET HTTPS request to run as a probe.  
`httpsVerifyCertificate` _boolean_ | HTTPSVerifyCertificate is a boolean value that indicates if the certificate should be verified.  
`timeout` _integer_ | Timeout is the probe timeout in seconds.  
`headers` _object (keys:string, values:string array)_ | Headers is a list of HTTP headers to add to the probe request.  
_Appears in:_
  * [KongUpstreamHealthcheck](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreamhealthcheck)


#### [KongUpstreamHash ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreamhash "KongUpstreamHash")
KongUpstreamHash defines how to calculate hash for consistent-hashing load balancing algorithm. Only one of the fields must be set.
Field | Description  
---|---  
`input` _[HashInput](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#hashinput)_ | Input allows using one of the predefined inputs (ip, consumer, path, none). Set this to `none` if you want to use sticky sessions. For other parameterized inputs, use one of the fields below.  
`header` _string_ | Header is the name of the header to use as hash input.  
`cookie` _string_ | Cookie is the name of the cookie to use as hash input.  
`cookiePath` _string_ | CookiePath is cookie path to set in the response headers.  
`queryArg` _string_ | QueryArg is the name of the query argument to use as hash input.  
`uriCapture` _string_ | URICapture is the name of the URI capture group to use as hash input.  
_Appears in:_
  * [KongUpstreamPolicySpec](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreampolicyspec)


#### [KongUpstreamHealthcheck ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreamhealthcheck "KongUpstreamHealthcheck")
KongUpstreamHealthcheck represents a health-check config of an Upstream in Kong.
Field | Description  
---|---  
`active` _[KongUpstreamActiveHealthcheck](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreamactivehealthcheck)_ | Active configures active health check probing.  
`passive` _[KongUpstreamPassiveHealthcheck](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreampassivehealthcheck)_ | Passive configures passive health check probing.  
`threshold` _integer_ | Threshold is the minimum percentage of the upstream’s targets’ weight that must be available for the whole upstream to be considered healthy.  
_Appears in:_
  * [KongUpstreamPolicySpec](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreampolicyspec)


#### [KongUpstreamHealthcheckHealthy ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreamhealthcheckhealthy "KongUpstreamHealthcheckHealthy")
KongUpstreamHealthcheckHealthy configures thresholds and HTTP status codes to mark targets healthy for an upstream.
Field | Description  
---|---  
`httpStatuses` _[HTTPStatus](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#httpstatus) array_ | HTTPStatuses is a list of HTTP status codes that Kong considers a success.  
`interval` _integer_ | Interval is the interval between active health checks for an upstream in seconds when in a healthy state.  
`successes` _integer_ | Successes is the number of successes to consider a target healthy.  
_Appears in:_
  * [KongUpstreamActiveHealthcheck](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreamactivehealthcheck)
  * [KongUpstreamPassiveHealthcheck](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreampassivehealthcheck)


#### [KongUpstreamHealthcheckUnhealthy ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreamhealthcheckunhealthy "KongUpstreamHealthcheckUnhealthy")
KongUpstreamHealthcheckUnhealthy configures thresholds and HTTP status codes to mark targets unhealthy.
Field | Description  
---|---  
`httpFailures` _integer_ | HTTPFailures is the number of failures to consider a target unhealthy.  
`httpStatuses` _[HTTPStatus](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#httpstatus) array_ | HTTPStatuses is a list of HTTP status codes that Kong considers a failure.  
`tcpFailures` _integer_ | TCPFailures is the number of TCP failures in a row to consider a target unhealthy.  
`timeouts` _integer_ | Timeouts is the number of timeouts in a row to consider a target unhealthy.  
`interval` _integer_ | Interval is the interval between active health checks for an upstream in seconds when in an unhealthy state.  
_Appears in:_
  * [KongUpstreamActiveHealthcheck](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreamactivehealthcheck)
  * [KongUpstreamPassiveHealthcheck](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreampassivehealthcheck)


#### [KongUpstreamPassiveHealthcheck ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreampassivehealthcheck "KongUpstreamPassiveHealthcheck")
KongUpstreamPassiveHealthcheck configures passive checks around passive health checks.
Field | Description  
---|---  
`type` _string_ | Type determines whether to perform passive health checks interpreting HTTP/HTTPS statuses, or just check for TCP connection success. Accepted values are “http”, “https”, “tcp”, “grpc”, “grpcs”.  
`healthy` _[KongUpstreamHealthcheckHealthy](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreamhealthcheckhealthy)_ | Healthy configures thresholds and HTTP status codes to mark targets healthy for an upstream.  
`unhealthy` _[KongUpstreamHealthcheckUnhealthy](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreamhealthcheckunhealthy)_ | Unhealthy configures thresholds and HTTP status codes to mark targets unhealthy.  
_Appears in:_
  * [KongUpstreamHealthcheck](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreamhealthcheck)


#### [KongUpstreamPolicySpec ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreampolicyspec "KongUpstreamPolicySpec")
KongUpstreamPolicySpec contains the specification for KongUpstreamPolicy.
Field | Description  
---|---  
`algorithm` _string_ | Algorithm is the load balancing algorithm to use. Accepted values are: “round-robin”, “consistent-hashing”, “least-connections”, “latency”, “sticky-sessions”  
`slots` _integer_ | Slots is the number of slots in the load balancer algorithm. If not set, the default value in Kong for the algorithm is used.  
`hashOn` _[KongUpstreamHash](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreamhash)_ | HashOn defines how to calculate hash for consistent-hashing or sticky-sessions load balancing algorithm. Algorithm must be set to “consistent-hashing” or “sticky-sessions” for this field to have effect.  
`hashOnFallback` _[KongUpstreamHash](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreamhash)_ | HashOnFallback defines how to calculate hash for consistent-hashing load balancing algorithm if the primary hash function fails. Algorithm must be set to “consistent-hashing” for this field to have effect.  
`healthchecks` _[KongUpstreamHealthcheck](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreamhealthcheck)_ | Healthchecks defines the health check configurations in Kong.  
`stickySessions` _[KongUpstreamStickySessions](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreamstickysessions)_ | StickySessions defines the sticky session configuration for the upstream. When enabled, clients will be routed to the same backend target based on a cookie. This requires Kong Enterprise Gateway and setting `hash_on` to `none`.  
_Appears in:_
  * [KongUpstreamPolicy](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreampolicy)


#### [KongUpstreamStickySessions ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreamstickysessions "KongUpstreamStickySessions")
KongUpstreamStickySessions defines the sticky session configuration for Kong upstream. Sticky sessions ensure that requests from the same client are routed to the same backend target. This is achieved using cookies and requires Kong Enterprise Gateway.
Field | Description  
---|---  
`cookie` _string_ | Cookie is the name of the cookie to use for sticky sessions. Kong will generate this cookie if it doesn’t exist in the request.  
`cookiePath` _string_ | CookiePath is the path to set in the cookie.  
_Appears in:_
  * [KongUpstreamPolicySpec](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreampolicyspec)


#### [TCPIngressSpec ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#tcpingressspec "TCPIngressSpec")
TCPIngressSpec defines the desired state of TCPIngress.
Field | Description  
---|---  
`rules` _[IngressRule](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#ingressrule) array_ | A list of rules used to configure the Ingress.  
`tls` _[IngressTLS](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#ingresstls) array_ | TLS configuration. This is similar to the `tls` section in the Ingress resource in networking.v1beta1 group. The mapping of SNIs to TLS cert-key pair defined here will be used for HTTP Ingress rules as well. Once can define the mapping in this resource or the original Ingress resource, both have the same effect.  
_Appears in:_
  * [TCPIngress](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#tcpingress)


#### [UDPIngressRule ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#udpingressrule "UDPIngressRule")
UDPIngressRule represents a rule to apply against incoming requests wherein no Host matching is available for request routing, only the port is used to match requests.
Field | Description  
---|---  
`port` _integer_ | Port indicates the port for the Kong proxy to accept incoming traffic on, which will then be routed to the service Backend.  
`backend` _[IngressBackend](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#ingressbackend)_ | Backend defines the Kubernetes service which accepts traffic from the listening Port defined above.  
_Appears in:_
  * [UDPIngressSpec](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#udpingressspec)


#### [UDPIngressSpec ](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#udpingressspec "UDPIngressSpec")
UDPIngressSpec defines the desired state of UDPIngress.
Field | Description  
---|---  
`rules` _[UDPIngressRule](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#udpingressrule) array_ | A list of rules used to configure the Ingress.  
_Appears in:_
  * [UDPIngress](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#udpingress)


Related Documentation
[ ](https://developer.konghq.com/index/kubernetes-ingress-controller/)
Tags
[#crd](https://developer.konghq.com/search/?tags=crd)
Related Resources
[Gateway API](https://developer.konghq.com/kubernetes-ingress-controller/gateway-api/)
  * [Custom Resource (CRD) API Reference](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#custom-resource-crd-api-reference)
  * [Packages](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#packages)
  * [configuration.konghq.com/v1](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#configuration-konghq-com-v1)
    * [KongClusterPlugin](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongclusterplugin)
    * [KongConsumer](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongconsumer)
    * [KongIngress](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongingress)
    * [KongPlugin](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongplugin)
    * [Types](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#types)
  * [configuration.konghq.com/v1alpha1](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#configuration-konghq-com-v1alpha1)
    * [IngressClassParameters](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#ingressclassparameters)
    * [KongCustomEntity](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongcustomentity)
    * [KongLicense](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#konglicense)
    * [KongVault](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongvault)
    * [Types](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#types)
  * [configuration.konghq.com/v1beta1](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#configuration-konghq-com-v1beta1)
    * [KongConsumerGroup](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongconsumergroup)
    * [KongUpstreamPolicy](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#kongupstreampolicy)
    * [TCPIngress](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#tcpingress)
    * [UDPIngress](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#udpingress)
    * [Types](https://developer.konghq.com/kubernetes-ingress-controller/reference/custom-resources/#types)


### Did this doc help?
YesNo
Something wrong?
[Report an Issue](https://github.com/Kong/developer.konghq.com/issues/) | [Edit this Page](https://github.com/Kong/developer.konghq.com/edit/main/app/kubernetes-ingress-controller/reference/custom-resources.md)
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
