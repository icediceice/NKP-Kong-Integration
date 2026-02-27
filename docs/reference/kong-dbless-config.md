[Home](https://developer.konghq.com/) / [Kong Gateway](https://developer.konghq.com/gateway/)
[ Edit this Page Edit ](https://github.com/Kong/developer.konghq.com/edit/main/app/gateway/db-less-mode.md) [ Report an Issue Report ](https://github.com/Kong/developer.konghq.com/issues/)
# DB-less mode
Uses:  [Kong Gateway](https://developer.konghq.com/gateway/)
Related Documentation
Incompatible with
konnect
Tags
[#deployment-topologies](https://developer.konghq.com/search/?tags=deployment-topologies)
Related Resources
[Deployment topologies](https://developer.konghq.com/gateway/deployment-topologies/)
[Data Plane hosting options](https://developer.konghq.com/gateway/topology-hosting-options/)
[CLI reference: kong config](https://developer.konghq.com/gateway/cli/reference/#kong-config)
[Kong Gateway entity references](https://developer.konghq.com/gateway/entities/)
Kong Gateway can be run without a database using only in-memory storage for [entities](https://developer.konghq.com/gateway/entities/). We call this DB-less mode. When running Kong Gateway DB-less, the configuration of entities is done in a second configuration file, in YAML or JSON, using declarative configuration.
The combination of DB-less mode and declarative configuration has a number of benefits:
  * Reduced number of dependencies: No need to manage a database installation if the entire setup for your use-cases fits in memory.
  * Automation in CI/CD scenarios: Configuration for entities can be kept in a single source of truth managed via a Git repository.
  * Enables more deployment options for Kong Gateway.


> **Important** : [decK](https://developer.konghq.com/deck/) also manages configuration declaratively, but it requires a database to perform any of its sync, dump, or similar operations. Therefore, decK can’t be used in DB-less mode.
```
 
flowchart TD

A( Kong Gateway instance)
B( Kong Gateway instance)
C( Kong Gateway instance)

A2(fa:fa-file kong1.yml)
B2(fa:fa-file kong1.yml)
C2(fa:fa-file kong1.yml)

A2 --> A
B2 --> B
C2 --> C

  
```

## [How declarative configuration works in DB-less mode ](https://developer.konghq.com/gateway/db-less-mode/#how-declarative-configuration-works-in-db-less-mode "How declarative configuration works in DB-less mode")
The key idea in declarative configuration is the notion that it is _declarative_ , as opposed to an _imperative_ style of configuration. Imperative means that a configuration is given as a series of orders. Declarative means that the configuration is given all at once.
The [Admin API](https://developer.konghq.com/api/gateway/admin-ee/) is an example of an imperative configuration tool. The final state of the configuration is attained through a sequence of API calls: one call to create a Service, another call to create a Route, another call to add a plugin, and so on.
Incremental configuration like this has the undesirable side-effect that _intermediate states_ happen. In the above example, there is a window of time in between creating a Route and adding the plugin in which the Route didn’t have the plugin applied.
A declarative configuration file, on the other hand, contains the settings for all needed [entities](https://developer.konghq.com/gateway/entities/) in a single file. Once that file is loaded into Kong Gateway, it replaces the entire configuration. When incremental changes are needed, they are made to the declarative configuration file, which is then reloaded in its entirety. At all times, the configuration described in the file loaded into Kong Gateway is the configured state of the system.
## [Set up Kong Gateway in DB-less mode ](https://developer.konghq.com/gateway/db-less-mode/#set-up-kong-gateway-in-db-less-mode "Set up Kong Gateway in DB-less mode")
To use Kong Gateway in DB-less mode, set the [`database` directive of `kong.conf`](https://developer.konghq.com/gateway/configuration/#database) to `off`. You can do this by editing `kong.conf` and setting `database=off` or via environment variables (`export KONG_DATABASE=off`), and then [starting Kong Gateway](https://developer.konghq.com/gateway/cli/reference/#kong-start).
You can verify that Kong Gateway is deployed in DB-less mode by sending the following:
```
curl -i -X GET http://localhost:8001

```

Copied!
This will return the entire Kong Gateway configuration. Verify that `database` is set to `off` in the response body.
## [Generate a declarative configuration file ](https://developer.konghq.com/gateway/db-less-mode/#generate-a-declarative-configuration-file "Generate a declarative configuration file")
To get started using declarative configuration, you need a JSON or YAML file containing [Kong Gateway entity definitions](https://developer.konghq.com/gateway/entities/).
The following command generates a file named `kong.yml` in the current directory containing configuration examples:
```
kong config init

```

Copied!
## [Load the declarative configuration file ](https://developer.konghq.com/gateway/db-less-mode/#load-the-declarative-configuration-file "Load the declarative configuration file")
There are two ways to load a declarative configuration file into Kong Gateway:
  * At start-up, using `kong.conf`
  * At runtime, using the [`/config` Admin API endpoint](https://developer.konghq.com/api/gateway/admin-ee/#/operations/post-config)


You can use the following `kong.conf` parameters to load the declarative config file:
Parameter | Description  
---|---  
`declarative_config ` |  The path to the declarative configuration file which holds the specification of all entities (routes, services, consumers, etc.) to be used when the `database` is set to `off`. Entities are stored in Kong’s LMDB cache, so you must ensure that enough headroom is allocated to it via the `lmdb_map_size` property. If the hybrid mode `role` is set to `data_plane` and there’s no configuration cache file, this configuration is used before connecting to the control plane node as a user-controlled fallback.  
`declarative_config_string ` |  The declarative configuration as a string  
## [DB-less mode with Kubernetes ](https://developer.konghq.com/gateway/db-less-mode/#db-less-mode-with-kubernetes "DB-less mode with Kubernetes")
You can run DB-less mode with Kubernetes both with and without [Kong Ingress Controller](https://developer.konghq.com/kubernetes-ingress-controller/).
### [DB-less mode with Kong Ingress Controller ](https://developer.konghq.com/gateway/db-less-mode/#db-less-mode-with-kong-ingress-controller "DB-less mode with Kong Ingress Controller")
Kong Ingress Controller provides a Kubernetes native way to configure Kong Gateway using custom resource definitions (CRDs). In this deployment pattern, Kong Gateway is deployed in DB-less mode, where the Data Plane configuration is held in memory.
Operators configure Kong Gateway using standard CRDs such as `Ingress` and `HTTPRoute`, and Kong Ingress Controller translates those resources into Kong Gateway entities before sending a request to update the running Data Plane configurations.
In this topology, the Kubernetes API server is your source of truth. Kong Ingress Controller reads resources stored on the API server and translates them into a valid Kong Gateway configuration object. You can think of Kong Ingress Controller as the Control Plane for your DB-less Data Planes.
For more information about Kong Gateway and Kong Ingress Controller, see the Kong Ingress Controller [getting started guide](https://developer.konghq.com/kubernetes-ingress-controller/install/). This guide walks you through installing Kong Gateway, configuring a Service and Route, then adding a rate limiting and caching plugin to your deployment.
### [DB-less with Helm (Kong Ingress Controller disabled) ](https://developer.konghq.com/gateway/db-less-mode/#db-less-with-helm-kong-ingress-controller-disabled "DB-less with Helm \(Kong Ingress Controller disabled\)")
When deploying Kong Gateway on Kubernetes in DB-less mode (`env.database: "off"`) and without the Kong Ingress Controller (`ingressController.enabled: false`), you have to provide a declarative configuration for Kong Gateway to run. You can provide an existing ConfigMap (`dblessConfig.configMap`) or place the whole configuration into a `values.yaml` (`dblessConfig.config`) parameter. See the example configuration in the [default `values.yaml`](https://github.com/kong/charts/blob/main/charts/kong/values.yaml) for more detail.
Use `--set-file dblessConfig.config=/path/to/declarative-config.yaml` in Helm commands to substitute in a complete declarative config file.
Externally supplied ConfigMaps aren’t hashed or tracked in deployment annotations. Subsequent ConfigMap updates require user-initiated deployment rollouts to apply the new configuration. Run `kubectl rollout restart deploy` after updating externally supplied ConfigMap content.
## [DB-less mode limitations ](https://developer.konghq.com/gateway/db-less-mode/#db-less-mode-limitations "DB-less mode limitations")
There are a number of limitations you should be aware of when using Kong Gateway in DB-less mode.
### [Memory cache requirements ](https://developer.konghq.com/gateway/db-less-mode/#memory-cache-requirements "Memory cache requirements")
The entire configuration of entities must fit inside the Kong Gateway cache. Make sure that the in-memory cache is configured appropriately in [`kong.conf`](https://developer.konghq.com/gateway/manage-kong-conf/):
Parameter | Description  
---|---  
`mem_cache_size ` Default: `128m ` |  Size of each of the two shared memory caches for traditional mode database entities and runtime data, `kong_core_cache` and `kong_cache`. The accepted units are `k` and `m`, with a minimum recommended value of a few MBs. **Note** : As this option controls the size of two different cache zones, the total memory Kong uses to cache entities might be double this value. The created zones are shared by all worker processes and do not become larger when more workers are used.  
### [No central database coordination ](https://developer.konghq.com/gateway/db-less-mode/#no-central-database-coordination "No central database coordination")
Since there is no central database, Kong Gateway nodes have no central coordination point and no cluster propagation of data. Nodes are completely independent of each other.
This means that the declarative configuration should be loaded into each node independently. Using the [`/config` endpoint](https://developer.konghq.com/api/gateway/admin-ee/#/operations/get-config) doesn’t affect other Kong Gateway nodes, since they have no knowledge of each other.
### [Read-only Admin API ](https://developer.konghq.com/gateway/db-less-mode/#read-only-admin-api "Read-only Admin API")
Since the only way to configure entities is via declarative configuration, the endpoints for CRUD operations on entities are effectively read-only in the [Admin API](https://developer.konghq.com/api/gateway/admin-ee/) when running Kong Gateway in DB-less mode. `GET` operations for inspecting entities work as usual, but attempts to `POST`, `PATCH` `PUT` or `DELETE` in endpoints such as `/services` or `/plugins` will return `HTTP 405 Not Allowed`.
This restriction is limited to what would otherwise be database operations. In particular, using `POST` to set the health state of targets is still enabled, since this is a node-specific in-memory operation.
### [Kong Manager compatibility ](https://developer.konghq.com/gateway/db-less-mode/#kong-manager-compatibility "Kong Manager compatibility")
[Kong Manager](https://developer.konghq.com/gateway/kong-manager/) cannot guarantee compatibility with Kong Gateway operating in DB-less mode. You cannot create, update, or delete entities with Kong Manager when Kong Gateway is running in this mode. Entity counters in the **Summary** section on the global and workspace overview pages will not function correctly either.
### [Plugin compatibility ](https://developer.konghq.com/gateway/db-less-mode/#plugin-compatibility "Plugin compatibility")
Not all Kong Gateway plugins are compatible with DB-less mode. By design, some plugins require central database coordination or dynamic creation of entities.
For current plugin compatibility, see [Plugins](https://developer.konghq.com/gateway/entities/plugin/).
### Did this doc help?
YesNo
Something wrong?
[Report an Issue](https://github.com/Kong/developer.konghq.com/issues/) | [Edit this Page](https://github.com/Kong/developer.konghq.com/edit/main/app/gateway/db-less-mode.md)
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

