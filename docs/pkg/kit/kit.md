# github.com/slewiskelly/cuek8s/pkg/kit

```cue
import "github.com/slewiskelly/cuek8s/pkg/kit"
```

Package kit contains useful abstractions on top of commonly used Kubernetes
resources.

The two main abstractions are:
- Application
- Batch

These abstractions allow developers to configure workloads without many of
the infrastructure concerns that are required when configuring via "raw"
Kubernetes YAML.

The abstractions will generate a set of resources which can be deployed to a
cluster by a chosen deployment method.

The abstractions provide sane and/or recommended defaults, but each
abstraction allows a patching mechanism to allow fine-tuning, if required.

Other abstractions included are:
- ConfigMap
- Service

These abstractions are very minor but provide small conviniences in terms of
metadata and defaults.

The same patching mechanism is available for these abstractions as well.

## #Application

Application is an abstraction of multiple Kubernetes resources.

Depending on the configuration of the application it may generate the
following resources:
 - Deployment
 - DestinationRule (if a service mesh is enabled)
 - HorizontalPodAutoscaler
 - PodDisruptionBudget
 - Service (if ports are exposed)
 - VirtualService (if a service mesh is enabled)

Example:
```cue
App: kit.#Application & {
    metadata: {
        serviceID: "acme-echo-jp"
        name:      "echo"
    }

    spec: image: "acme-echo-jp"
}
```

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`metadata`|`kit.#Metadata`||Metadata about the resource(s).|
|`metadata.annotations`|`struct`||Annotations associated with the resource.|
|`metadata.environment`|`acme.#Environment`||Environment in which the resource belongs.|
|`metadata.labels`|`struct`||Labels associated with the resource.<br/><br/>All resources are labeled with the following and cannot be changed:<br/>- app<br/>- app.acme.in/name<br/>- app.acme.in/part-of<br/>- topology.acme.in/environment<br/>- topology.acme.in/region|
|`metadata.name`|`string`||Name of the resource.|
|`metadata.region`|`acme.#Region`||Region in which the resource belongs.|
|`metadata.serviceID`|`acme.#Name`||ID of the service in which the resource belongs.|
|`spec`|`struct`||Specification used to configure the resource(s).|
|`spec.image`|`string`||Application's Docker image name, excluding the image registry prefix.<br/><br/>The image registry is assumed to be "gcr.io/$SERVICE-prod/".|
|`spec.minAvailable`|`string`|`"50%"`|Minimum number of replicas, as a percentage, that must be available.<br/><br/>Replicas cannot be rescheduled until at least the number of repliacs<br/>are available.|
|`spec.scaling`|`struct`||Scaling configuration.|
|`spec.updates`|`struct`||Update configuration.|
|`spec.additionalContainers`|`list`|`[]`|Containers to be run in addition to the primary container.|
|`spec.args`|`list`|`[]`|Arguments to the primary container's entrypoint.|
|`spec.command`|`list`|`[]`|Command that replaces the primary container's entrypoint.|
|`spec.envFrom`|`list`|`[]`|Environment variables that are sourced from ConfigMaps or Secrets.|
|`spec.expose`|`struct`||Ports exposed by the application.<br/><br/>Ports specified here will be exposed by a corresponding service.|
|`spec.envSpec`|`struct`||Environment variables required by the application.<br/><br/>These environment variables are more complex structures than key/value<br/>pairs, such as those that reference values from fields or secrets.Sets the simple key/value pair environment variables to the structure<br/>required by a Kubernetes manifest.|
|`spec.initContainers`|`list`|`[]`|Initialization containers to be run before the primary (and any<br/>additional containers that have been specified) will be started.<br/><br/>Initialization containers are run in the order they are specified.<br/><br/>All specified initialization containers will be ordered after critical<br/>initizaliation container(s) have been run. Critical initializarion<br/>containers will be added by the abstraction.|
|`spec.network`|`struct`||Network configuration.|
|`spec.network.serviceMesh`|`(null\|struct)`|`null`|Service mesh specific configuration.<br/><br/>By default, a service mesh is disabled.|
|`spec.port`|`struct`||Ports exposed by the application.<br/>Ports specified here will _not_ be exposed by a corresponding service.|
|`spec.resources`|`struct`||Resources requirements of the application.|
|`spec.resources.requests`|`struct`||Minimum amount of resources required by an instance of an application.|
|`spec.resources.requests.cpu`|`number`|`0.5`|CPU is specified as the number of vCPUs, fractions of a CPU are<br/>allowed.|
|`spec.resources.requests.memory`|`int`|`128M`|Memory is specified in bytes.|
|`spec.resources.limits`|`struct`||Maximum amount of resources that can be used by an instance of an<br/>application.|
|`spec.resources.limits.cpu`|`number`|`0.5`|CPU is specified as the number of vCPUs, fractions of a CPU are<br/>allowed.|
|`spec.resources.limits.memory`|`int`|`128M`|Memory is specified in bytes.|
|`spec.tolerations`|`struct`||Tolerations used by scheduler.|
|`spec.tolerations.preemptible`|`bool`|`false`|Whether an application uses preemptible nodes.|
|`spec.volume`|`struct`||Volumes to be mounted by the application.|


## #Base

Base specifies base configuration for all kit resources (with a minor
exception being made to the Pipeline resource and its variants).

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`metadata`|`kit.#Metadata`||Metadata about the resource(s).|
|`metadata.annotations`|`struct`||Annotations associated with the resource.|
|`metadata.environment`|`acme.#Environment`||Environment in which the resource belongs.|
|`metadata.labels`|`struct`||Labels associated with the resource.<br/><br/>All resources are labeled with the following and cannot be changed:<br/>- app<br/>- app.acme.in/name<br/>- app.acme.in/part-of<br/>- topology.acme.in/environment<br/>- topology.acme.in/region|
|`metadata.name`|`string`||Name of the resource.|
|`metadata.region`|`acme.#Region`||Region in which the resource belongs.|
|`metadata.serviceID`|`acme.#Name`||ID of the service in which the resource belongs.|
|`spec`|`struct`||Specification used to configure the resource(s).|


## #Batch

Batch is an abstraction of multiple Kubernetes resources.

Depending on the configuration of the application it may generate the
following resources:
 - CronJob or Job

Example:
```cue
Batch: kit.#Batch & {
    metadata: {
        name: "loadtester"
        serviceID: "acme-echo-jp"
    }

    spec: image: "loadtester"
}
```

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`metadata`|`kit.#Metadata`||Metadata about the resource(s).|
|`metadata.annotations`|`struct`||Annotations associated with the resource.|
|`metadata.environment`|`acme.#Environment`||Environment in which the resource belongs.|
|`metadata.labels`|`struct`||Labels associated with the resource.<br/><br/>All resources are labeled with the following and cannot be changed:<br/>- app<br/>- app.acme.in/name<br/>- app.acme.in/part-of<br/>- topology.acme.in/environment<br/>- topology.acme.in/region|
|`metadata.name`|`string`||Name of the resource.|
|`metadata.region`|`acme.#Region`||Region in which the resource belongs.|
|`metadata.serviceID`|`acme.#Name`||ID of the service in which the resource belongs.|
|`spec`|`struct`||Specification used to configure the resource(s).|
|`spec.additionalContainers`|`list`|`[]`|Containers to be run in addition to the primary container.|
|`spec.args`|`list`|`[]`|Arguments to the primary container's entrypoint.|
|`spec.command`|`list`|`[]`|Command that replaces the primary container's entrypoint.|
|`spec.envFrom`|`list`|`[]`|Environment variables that are sourced from ConfigMaps or Secrets.|
|`spec.image`|`string`||Application's Docker image name, excluding the image registry prefix.<br/><br/>The image registry is assumed to be "gcr.io/$SERVICE-prod/".|
|`spec.envSpec`|`struct`||Environment variables required by the application.<br/><br/>These environment variables are more complex structures than key/value<br/>pairs, such as those that reference values from fields or secrets.Sets the simple key/value pair environment variables to the structure<br/>required by a Kubernetes manifest.|
|`spec.expose`|`struct`||Ports exposed by the application.<br/><br/>Ports specified here will be exposed by a corresponding service.|
|`spec.initContainers`|`list`|`[]`|Initialization containers to be run before the primary (and any<br/>additional containers that have been specified) will be started.<br/><br/>Initialization containers are run in the order they are specified.<br/><br/>All specified initialization containers will be ordered after critical<br/>initizaliation container(s) have been run. Critical initializarion<br/>containers will be added by the abstraction.|
|`spec.network`|`struct`||Network configuration.|
|`spec.network.serviceMesh`|`(null\|struct)`|`null`|Service mesh specific configuration.<br/><br/>By default, a service mesh is disabled.|
|`spec.port`|`struct`||Ports exposed by the application.<br/>Ports specified here will _not_ be exposed by a corresponding service.|
|`spec.resources`|`struct`||Resources requirements of the application.|
|`spec.resources.requests`|`struct`||Minimum amount of resources required by an instance of an application.|
|`spec.resources.requests.cpu`|`number`|`0.5`|CPU is specified as the number of vCPUs, fractions of a CPU are<br/>allowed.|
|`spec.resources.requests.memory`|`int`|`128M`|Memory is specified in bytes.|
|`spec.resources.limits`|`struct`||Maximum amount of resources that can be used by an instance of an<br/>application.|
|`spec.resources.limits.cpu`|`number`|`0.5`|CPU is specified as the number of vCPUs, fractions of a CPU are<br/>allowed.|
|`spec.resources.limits.memory`|`int`|`128M`|Memory is specified in bytes.|
|`spec.tolerations`|`struct`||Tolerations used by scheduler.|
|`spec.tolerations.preemptible`|`bool`|`false`|Whether an application uses preemptible nodes.|
|`spec.volume`|`struct`||Volumes to be mounted by the application.|


## #ConfigMap

ConfigMap specifies a minor abstraction of a Kubernetes ConfigMap.

Example:
```cue
ConfigMap: kit.#ConfigMap & {
    metadata: {
        name: "config"
        serviceID: "acme-echo-jp"
    }

   data: FOO: "BAR"
}
```

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`metadata`|`kit.#Metadata`||Metadata about the resource(s).|
|`metadata.annotations`|`struct`||Annotations associated with the resource.|
|`metadata.environment`|`acme.#Environment`||Environment in which the resource belongs.|
|`metadata.labels`|`struct`||Labels associated with the resource.<br/><br/>All resources are labeled with the following and cannot be changed:<br/>- app<br/>- app.acme.in/name<br/>- app.acme.in/part-of<br/>- topology.acme.in/environment<br/>- topology.acme.in/region|
|`metadata.name`|`string`||Name of the resource.|
|`metadata.region`|`acme.#Region`||Region in which the resource belongs.|
|`metadata.serviceID`|`acme.#Name`||ID of the service in which the resource belongs.|
|`spec`|`struct`||Specification used to configure the resource(s).|


## #CronConcurrencyPolicy

CronConcurrencyPolicy specifies a CronJob's policy for concurrent execution.

 - allow: concurrent executions are allowed
 - forbid: concurreny executions are not allowed
 - replace: existing executions will be canceled, before starting a new one

**Type**: `string`



## #JobSpec

Attributes that are common to all resources which contain a JobSpec.

**Type**: `struct`



## #Metadata

Metadata specifies resource metadata.

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`annotations`|`struct`||Annotations associated with the resource.|
|`environment`|`acme.#Environment`||Environment in which the resource belongs.|
|`labels`|`struct`||Labels associated with the resource.<br/><br/>All resources are labeled with the following and cannot be changed:<br/>- app<br/>- app.acme.in/name<br/>- app.acme.in/part-of<br/>- topology.acme.in/environment<br/>- topology.acme.in/region|
|`name`|`string`||Name of the resource.|
|`region`|`acme.#Region`||Region in which the resource belongs.|
|`serviceID`|`acme.#Name`||ID of the service in which the resource belongs.|


## #Network

Network specifies application network configuration.

Example:
```cue
App: kit.#Application & {
    metadata: {
        serviceID: "acme-echo-jp"
        name:      "echo"
    }

    spec: {
        image: "acme-echo-jp"
        network: serviceMesh: {}
    }
}
```

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`serviceMesh`|`(null\|struct)`|`null`|Service mesh specific configuration.<br/><br/>By default, a service mesh is disabled.|


## #PodSpec

Attributes that are common to all resources which contain a PodSpec.

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`additionalContainers`|`list`|`[]`|Containers to be run in addition to the primary container.|
|`args`|`list`|`[]`|Arguments to the primary container's entrypoint.|
|`command`|`list`|`[]`|Command that replaces the primary container's entrypoint.|
|`envFrom`|`list`|`[]`|Environment variables that are sourced from ConfigMaps or Secrets.|
|`envSpec`|`struct`||Environment variables required by the application.<br/><br/>These environment variables are more complex structures than key/value<br/>pairs, such as those that reference values from fields or secrets.Sets the simple key/value pair environment variables to the structure<br/>required by a Kubernetes manifest.|
|`expose`|`struct`||Ports exposed by the application.<br/><br/>Ports specified here will be exposed by a corresponding service.|
|`initContainers`|`list`|`[]`|Initialization containers to be run before the primary (and any<br/>additional containers that have been specified) will be started.<br/><br/>Initialization containers are run in the order they are specified.<br/><br/>All specified initialization containers will be ordered after critical<br/>initizaliation container(s) have been run. Critical initializarion<br/>containers will be added by the abstraction.|
|`network`|`kit.#Network`||Network configuration.|
|`network.serviceMesh`|`(null\|struct)`|`null`|Service mesh specific configuration.<br/><br/>By default, a service mesh is disabled.|
|`port`|`struct`||Ports exposed by the application.<br/>Ports specified here will _not_ be exposed by a corresponding service.|
|`resources`|`kit.#Resources`||Resources requirements of the application.|
|`resources.requests`|`struct`||Minimum amount of resources required by an instance of an application.|
|`resources.requests.cpu`|`number`|`0.5`|CPU is specified as the number of vCPUs, fractions of a CPU are<br/>allowed.|
|`resources.requests.memory`|`int`|`128M`|Memory is specified in bytes.|
|`resources.limits`|`struct`||Maximum amount of resources that can be used by an instance of an<br/>application.|
|`resources.limits.cpu`|`number`|`0.5`|CPU is specified as the number of vCPUs, fractions of a CPU are<br/>allowed.|
|`resources.limits.memory`|`int`|`128M`|Memory is specified in bytes.|
|`tolerations`|`struct`||Tolerations used by scheduler.|
|`tolerations.preemptible`|`bool`|`false`|Whether an application uses preemptible nodes.|
|`volume`|`struct`||Volumes to be mounted by the application.|


## #Port

Port specifies an application's network port configuration.

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`name`|`string`||Name of the port.|
|`port`|`int`||Port number in which requests are served.|
|`protocol`|`kit.#Protocol`|`"tcp"`|Network transport protocol.|
|`targetPort`|`int`||Port number in which the container is listening on.|


## #Protocol

Network transport protocol.

**Type**: `string`



## #Recreate

Recreate specifies a recreate update strategy.

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`recreate`|`struct`|||


## #Resources

Resources specifies an application's resource configuration.

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`requests`|`struct`||Minimum amount of resources required by an instance of an application.|
|`requests.cpu`|`number`|`0.5`|CPU is specified as the number of vCPUs, fractions of a CPU are<br/>allowed.|
|`requests.memory`|`int`|`128M`|Memory is specified in bytes.|
|`limits`|`struct`||Maximum amount of resources that can be used by an instance of an<br/>application.|
|`limits.cpu`|`number`|`0.5`|CPU is specified as the number of vCPUs, fractions of a CPU are<br/>allowed.|
|`limits.memory`|`int`|`128M`|Memory is specified in bytes.|


## #Rolling

Rolling specifies a rolling update strategy.

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`rolling`|`struct`|||
|`rolling.maxSurge`|`string`|`"50%"`|Percentage of additional replicas that may be created during a<br/>rollout.<br/>Defaults to "50%".|
|`rolling.maxUnavailable`|`string`|`"0%"`|Percentage of replicas that may be unavailable during a rollout.<br/>Defaults to "0%".|


## #ScalingHorizontal

ScalingHorizontal specifies that an application should scale horizontally,
and the number of repliacs should increase based on CPU utilization.

Example:
```cue
App: kit.#Application & {
    metadata: {
        serviceID: "acme-echo-jp"
        name:      "echo"
    }

    spec: {
        scaling: horizontal: {
            maxReplicas: 4
            metrics: [{
                resource: name: "cpu"
                utilization: 70
            }]
        }
    }
}
```

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`horizontal`|`struct`|||
|`horizontal.minReplicas`|`int`|`2`|Minimum number of replicas of the application.<br/><br/>This must always be greater than one, and less than or equal to, the<br/>maximum number of replicas.|
|`horizontal.maxReplicas`|`int`|`3`|Maximum number of replicas of the application.<br/><br/>This must always be greater than, or equal to, the minimum number of<br/>replicas.|
|`horizontal.metrics`|`list`|<pre>[{<br/>	resource:    "cpu"<br/>	utilization: 80<br/>}]<pre/>|Metrics containing the specifications for which to use to calculate<br/>the desired replica count.<br/><br/>Defaults to scale when replicas are above 80% CPU utilization.|


## #ScalingHorizontalMetric

ScalingHorizontalMetric specifies that what metrics an application use for
horizontal scaling.

**Type**: `struct`



## #ScalingHorizontalMetricSource

ScalingHorizontalMetricSource specifies what metric source an application
use for horizontal scaling.

**Type**: `struct`



## #ScalingHorizontalMetricSourceExternal

ScalingHorizontalMetricSourceExternal specifies that an application use an
external metric as a source for horizontal scaling.

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`external`|`struct`|||
|`external.metric`|`string`||Metric of the external source.|


## #ScalingHorizontalMetricSourceResource

ScalingHorizontalMetricSourceResource specifies that an application use a
resource metric as a source for horizontal scaling.

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`resource`|`string`||Type of resource.|


## #ScalingHorizontalMetricTarget

ScalingHorizontalMetricTarget specifies what metric target an application
use for horizontal scaling.

**Type**: `struct`



## #ScalingHorizontalMetricTargetAverageValue

ScalingHorizontalMetricTargetAverageValue specifies that an application use
an average value as a target of horizontal scaling.

**Type**: `struct`



## #ScalingHorizontalMetricTargetUtilization

ScalingHorizontalMetricTargetUtilization specifies that an application use
a utilization as a target of horizontal scaling.

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`utilization`|`int`|`80`|Target percentage utilization before additional replicas are created.<br/>Defaults to 80.|


## #ScalingHorizontalMetricTargetValue

ScalingHorizontalMetricTargetValue specifies that an application use a value
as a target of horizontal scaling.

**Type**: `struct`



## #ScalingStatic

ScalingStatic specifies that an application should not scale, and the number
of replicas is static.

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`static`|`struct`|||
|`static.replicas`|`int`|`2`|Number of replicas of the application.<br/>Defaults to 2.|


## #ScalingType

ScalingType specifies how an application should scale.

**Type**: `struct`



## #Service

Service specifies a minor abstraction of a Kubernetes Service.

Example:
```cue
Service: kit.#Service & {
    metadata: Metadata & {
        serviceID: "acme-echo-jp"
        name:      "http"
    }

    spec: {
        expose: http: {port: 80, targetPort: 8080}
        selector: App.metadata.labels
        type: "NodePort"
    }
}
```

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`metadata`|`kit.#Metadata`||Metadata about the resource(s).|
|`metadata.annotations`|`struct`||Annotations associated with the resource.|
|`metadata.environment`|`acme.#Environment`||Environment in which the resource belongs.|
|`metadata.labels`|`struct`||Labels associated with the resource.<br/><br/>All resources are labeled with the following and cannot be changed:<br/>- app<br/>- app.acme.in/name<br/>- app.acme.in/part-of<br/>- topology.acme.in/environment<br/>- topology.acme.in/region|
|`metadata.name`|`string`||Name of the resource.|
|`metadata.region`|`acme.#Region`||Region in which the resource belongs.|
|`metadata.serviceID`|`acme.#Name`||ID of the service in which the resource belongs.|
|`spec`|`struct`||Specification used to configure the resource(s).|
|`spec.expose`|`struct`||Ports exposed by the service.|
|`spec.selector`|`struct`||Label selector used to route traffic to the relevant Pod.|
|`spec.type`|`_\|_`||Type of the service.|


## #ServiceType

ServiceType specifies how the service is exposed.

See https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-servi    ce-types
for more information on service types.

**Type**: `string`



## #UpdateType

UpdateType

**Type**: `struct`



## #Volume

Volume specifies an application's volume mount.

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`name`|`string`||Name of the volume.|
|`mountPath`|`string`||Path in which the volume is to be mounted.|
|`subPath`|`(null\|string)`|`null`|Subpath in which the volume is to be mounted.|
|`readOnly`|`bool`|`true`|Whether the volume is read-only.<br/>Defaults to true.|


