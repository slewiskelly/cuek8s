# github.com/slewiskelly/cuek8s/pkg/k8s

```cue
import "github.com/slewiskelly/cuek8s/pkg/k8s"
```

Package k8s contains constraints and defaults on top of raw Kubernetes
resources.

## #BackendConfig

BackendConfig is a constrained definition of a
`cloud.google.com/v1.BackendConfig`.

See https://github.com/kubernetes/ingress-gce for more information.

**Type**: `struct`



## #ConfigMap

ConfigMap is a constrained definition of a `core/v1.ConfigMap`.

See http://go/k8s-api/config-and-storage-resources/config-map-v1 for more
information.

**Type**: `struct`



## #CronJob

CronJob is a constrained definition of a `batch/v1beta.CronJob`.

See http://go/k8s-api/workload-resources/cron-job-v1 for more information.

**Type**: `struct`



## #Deployment

Deployment is a constrained definition of a `apps/v1.Deployment`.

See http://go/k8s-api/workload-resources/deployment-v1 for more information.

**Type**: `struct`



## #DestinationRule

DestinationRule is a constrained definition of a
`networking.istio.io/v1alpha3.DestinationRule`.

See http://go/istio-api/networking/destination-rule for more information.

**Type**: `struct`



## #FrontendConfig

FrontendConfig is a constrained definition of a
`cloud.google.com/v1.FrontendConfig`.

See https://github.com/kubernetes/ingress-gce for more information.

**Type**: `struct`



## #HorizontalPodAutoscaler

HorizontalPodAutoscaler is a constrained definition of a
`autoscaling/v2beta2.HorizontalPodAutoscaler`.

See http://go/k8s-api/workload-resources/horizontal-pod-autoscaler-v2beta2
for more information.

**Type**: `struct`



## #Ingress

Ingress is a constrained definition of a `networking.k8s.io/v1.Ingress`.

See http://go/k8s-api/service-resources/ingress-v1 for more information.

**Type**: `struct`



## #InstallOrder

InstallOrder specifies a list of Kubernetes resources ordered in the order
in which they should be applied.

**Type**: `list`



## #Job

Job is a constrained definition of a `batch/v1.Job`.

See http://go/k8s-api/workload-resources/job-v1 for more information.

**Type**: `struct`



## #JobSpec

Job is a constrained definition of a `batch/v1.JobSpec`.

See http://go/k8s-api/workload-resources/job-v1/#JobSpec for more
information.

**Type**: `struct`



## #PodDisruptionBudget

PodDisruptionBudget is a constrained definition of a
`policy/v1.PodDisruptionBudget`.

See http://go/k8s-api/policy-resources/pod-disruption-budget-v1 for more
information.

**Type**: `struct`



## #PodSpec

PodSpec is a constrained definition of a `core/v1.PodSpec`.

See http://go/k8s-api/workload-resources/pod-v1/#PodSpec for more
information.

**Type**: `struct`



## #PrimaryContainer

PrimaryContainer is a constrained definition of a `core/v1.Container`.

The constraints here are useful only for a Pod's primary container.

See http://go/k8s-api/workload-resources/pod-v1/#Container for more
information.

**Type**: `struct`



## #Resource

Resource defines a Kubernetes resource.

**Type**: `struct`



## #ResourceRequirements

ResourceRequirements is a constrained definition of
`core/v1.ResourceRequirements`.

It constrains the units to the following:
- `cpu`: `number`
- `memory`: `int`

Kubernetes allows these resources to be expressed as strings also, but in
many cases these types are are simpler to work with, especially given that
integer literals in CUE may be expressed with SI or IEC multipliers.

**Type**: `struct`



## #Role

Role is a constrained definition of `rbac.authorization.k8s.io/v1.Role`.

See http://go/k8s-api/authorization-resources/role-v1 for more information.

**Type**: `struct`



## #RoleBinding

RoleBinding is a constrained definition of
`rbac.authorization.k8s.io/v1.RoleBinding`.

See http://go/k8s-api/authorization-resources/role-binding-v1 for more
information.

**Type**: `struct`



## #Service

Service is a constrained definition of `core/v1.Service`.

See http://go/k8s-api/service-resources/service-v1 for more information.

**Type**: `struct`



## #Sort

Sort sorts the given list of Kubernetes resources according to
`InstallOrder`.

Example:
```cue
sorted: (Sort & {l: resources}).sorted
```

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`r`|`list`|`[]`|Resources to be sorted.|
|`order`|`string`|`"install"`|Order in which to sort the resources.|


## #SortStrings

SortStrings sorts the given list of Kubernetes resource kinds according to
`InstallOrder`.

Example:
```cue
sorted: (Sort & {l: resources}).sorted
```

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`r`|`list`|`[]`|Resource kinds to be sorted.|
|`order`|`string`|`"install"`|Order in which to sort the resources.|


## #SpannerAutoscaler

SpannerAutoscaler is a constrained definition of
`spanner.mercari.com/v1alpha1.SpannerAutoscaler`.

See https://github.com/mercari/spanner-autoscaler for more information.

**Type**: `struct`



## #StatefulSet

StatefulSet is a constrained definition of `apps/v1.StatefulSet`.

See http://go/k8s-api/workload-resources/stateful-set-v1 for more
information.

**Type**: `struct`



## #VerticalPodAutoscaler

VerticalPodAutoscaler is a constrained definition of a
`autoscaling.k8s.io/v1.VerticalPodAutoscaler`.

See https://github.com/kubernetes/autoscaler for more information.

**Type**: `struct`



## #VirtualService

VirtualService is a constrained definition of a
`networking.istio.io/v1alpha3.VirtualService`.

See http://go/istio-api/networking/virtual-service for more information.

**Type**: `struct`



