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

    spec: image: name: "acme-echo-jp"
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
|`spec.image`|`struct`||Workload image configuration.|
|`spec.minAvailable`|`string`|`"50%"`|Minimum number of replicas, as a percentage, that must be available.<br/><br/>Replicas cannot be rescheduled until at least the number of repliacs<br/>are available.|
|`spec.scaling`|`kit.#ScalingType`|<pre>{<br/>	horizontal: {<br/>		minReplicas: *2 \| int<br/>		maxReplicas: *3 \| int<br/>		metrics:     *[{<br/>			resource:    "cpu"<br/>			utilization: 80<br/>		}] \| []<br/>	}<br/>}<pre/>|Scaling configuration.|
|`spec.updates`|`kit.#UpdateType`|<pre>{<br/>	rolling: {<br/>		maxSurge:       *"50%" \| =~"^(0\|[1-9]%$\|^[1-9][0-9]\|100)%$"<br/>		maxUnavailable: *"0%" \| =~"^(0\|[1-9]%$\|^[1-9][0-9]\|100)%$"<br/>	}<br/>}<pre/>|Update configuration.|
|`spec.additionalContainers`|`list`|`[]`|Containers to be run in addition to the primary container.|
|`spec.args`|`list`|`[]`|Arguments to the primary container's entrypoint.|
|`spec.command`|`list`|`[]`|Command that replaces the primary container's entrypoint.|
|`spec.envFrom`|`list`|`[]`|Environment variables that are sourced from ConfigMaps or Secrets.|
|`spec.initContainers`|`list`|`[]`|Initialization containers to be run before the primary (and any<br/>additional containers that have been specified) will be started.<br/><br/>Initialization containers are run in the order they are specified.<br/><br/>All specified initialization containers will be ordered after critical<br/>initizaliation container(s) have been run. Critical initializarion<br/>containers will be added by the abstraction.|
|`spec.network`|`kit.#Network`||Network configuration.|
|`spec.network.serviceMesh`|`(null\|struct)`|`null`|Service mesh specific configuration.<br/><br/>By default, a service mesh is disabled.|
|`spec.resources`|`kit.#Resources`||Resources requirements of the application.|
|`spec.resources.requests`|`struct`||Minimum amount of resources required by an instance of an application.<br/><br/>CPU is specified as the number of vCPUs, fractions of a CPU are allowed.<br/>RAM is specified in bytes.|
|`spec.resources.requests.cpu`|`number`|`0.5`||
|`spec.resources.requests.memory`|`int`|`128M`||
|`spec.resources.limits`|`struct`||Maximum amount of resources that can be used by an instance of an<br/>application.<br/><br/>CPU is specified as the number of vCPUs, fractions of a CPU are allowed.<br/>RAM is specified in bytes.|
|`spec.resources.limits.cpu`|`number`|`0.5`||
|`spec.resources.limits.memory`|`int`|`128M`||
|`spec.tolerations`|`struct`||Tolerations used by scheduler.|
|`spec.tolerations.preemptible`|`bool`|`false`|Whether an application uses preemptible nodes.|


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
|`spec`|`_`||Specification used to configure the resource(s).|


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

    spec: image: name: "loadtester"
}
```

**Type**: `_|_`



## #BatchSpec

Attributes that are common to all resources which contain a JobSpec.

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`completions`|`(null\|int)`|`null`|Number of completions of the job before signaling overall success.<br/><br/>A null completion signals success after a single completion, and allows<br/>any number of instances to run in parallel.|
|`cron`|`(null\|struct)`|`null`|By default a Job resource is generated, but specifying a schedule<br/>will generate a CronJob resource instead.|
|`parallelism`|`int`|`1`|Maximum number of instances of the job that can be executed in parallel.<br/><br/>Number of executing instances may be lower if:<br/>(completions - successes) < parallelism<br/><br/>Setting parallelism to zero blocks any instances from executing until<br/>it is increased.|
|`ttl`|`(null\|int)`|`null`|Number of seconds before the job is automatically deleted, after is has<br/>completed. A null TTL signals that the job should not be automatically<br/>deleted.|


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
|`data`|`struct`||Data to be stored.|
|`metadata`|`kit.#Metadata`||Metadata about the resource(s).|
|`metadata.annotations`|`struct`||Annotations associated with the resource.|
|`metadata.environment`|`acme.#Environment`||Environment in which the resource belongs.|
|`metadata.labels`|`struct`||Labels associated with the resource.<br/><br/>All resources are labeled with the following and cannot be changed:<br/>- app<br/>- app.acme.in/name<br/>- app.acme.in/part-of<br/>- topology.acme.in/environment<br/>- topology.acme.in/region|
|`metadata.name`|`string`||Name of the resource.|
|`metadata.region`|`acme.#Region`||Region in which the resource belongs.|
|`metadata.serviceID`|`acme.#Name`||ID of the service in which the resource belongs.|
|`spec`|`_`||Specification used to configure the resource(s).|


## #CronConcurrencyPolicy

CronConcurrencyPolicy specifies a CronJob's policy for concurrent execution:
 - allow: concurrent executions are allowed
 - forbid: concurreny executions are not allowed
 - replace: existing executions will be canceled, before starting a new one

**Type**: `string`



## #ImageSpec

ImageSpec is the full Docker image name with tag that is used in an Application

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
|`initContainers`|`list`|`[]`|Initialization containers to be run before the primary (and any<br/>additional containers that have been specified) will be started.<br/><br/>Initialization containers are run in the order they are specified.<br/><br/>All specified initialization containers will be ordered after critical<br/>initizaliation container(s) have been run. Critical initializarion<br/>containers will be added by the abstraction.|
|`network`|`kit.#Network`||Network configuration.|
|`network.serviceMesh`|`(null\|struct)`|`null`|Service mesh specific configuration.<br/><br/>By default, a service mesh is disabled.|
|`resources`|`kit.#Resources`||Resources requirements of the application.|
|`resources.requests`|`struct`||Minimum amount of resources required by an instance of an application.<br/><br/>CPU is specified as the number of vCPUs, fractions of a CPU are allowed.<br/>RAM is specified in bytes.|
|`resources.requests.cpu`|`number`|`0.5`||
|`resources.requests.memory`|`int`|`128M`||
|`resources.limits`|`struct`||Maximum amount of resources that can be used by an instance of an<br/>application.<br/><br/>CPU is specified as the number of vCPUs, fractions of a CPU are allowed.<br/>RAM is specified in bytes.|
|`resources.limits.cpu`|`number`|`0.5`||
|`resources.limits.memory`|`int`|`128M`||
|`tolerations`|`struct`||Tolerations used by scheduler.|
|`tolerations.preemptible`|`bool`|`false`|Whether an application uses preemptible nodes.|


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
|`requests`|`struct`||Minimum amount of resources required by an instance of an application.<br/><br/>CPU is specified as the number of vCPUs, fractions of a CPU are allowed.<br/>RAM is specified in bytes.|
|`requests.cpu`|`number`|`0.5`||
|`requests.memory`|`int`|`128M`||
|`limits`|`struct`||Maximum amount of resources that can be used by an instance of an<br/>application.<br/><br/>CPU is specified as the number of vCPUs, fractions of a CPU are allowed.<br/>RAM is specified in bytes.|
|`limits.cpu`|`number`|`0.5`||
|`limits.memory`|`int`|`128M`||


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



## #ScalingVertical

ScalingVertical specifies that an application should scale vertically,
and the amount of CPU and/or memory should increase based on utilization.

Example:
```cue
App: kit.#Application & {
    metadata: {
        serviceID: "acme-echo-jp"
        name:      "echo"
    }

    spec: scaling: vertical: replicas: 4
}
```

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`vertical`|`struct`|||
|`vertical.cpu`|`(null\|struct)`|`null`|If specified, CPU will be scaled to no less than min, and no more<br/>than max.<br/><br/>CPU will be scaled at the specified request:limit ratio.<br/><br/>By default, CPU is not scaled.|
|`vertical.memory`|`(null\|struct)`|`null`|If specified, memory will be scaled to no less than min, and no more<br/>than max.<br/><br/>Memory will be scaled at the specified request:limit ratio.<br/><br/>By default, memory is not scaled.|
|`vertical.mode`|`kit.#ScalingVerticalMode`|`"auto"`|Mode of operation of the application's autoscaler.|
|`vertical.replicas`|`int`|`2`|Number of replicas of the application.|


## #ScalingVerticalMode

ScalingVerticalMode specifies the mode of operation of an application's
autoscaler:
- auto: assigns resources on creation and during the remaining lifetime of the Pod
- initial: only assigns resources on creation, no updates are made during the remaining lifetime of the Pod
- off: never assigns resources, only provides recommendations

**Type**: `string`



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
|`spec.type`|`kit.#ServiceType`|`"ClusterIP"`|Type of the service.|


## #ServiceType

ServiceType specifies how the service is exposed.

See https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types
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


