# github.com/slewiskelly/cuek8s/pkg/acme/resolve

```cue
import "github.com/slewiskelly/cuek8s/pkg/acme/resolve"
```

Package resolve provides helpers used to resolve various information.

## #FromCluster

FromCluster resolves information based on the given cluster name.

Example:
```
env: (#FromCluster & {cluster: "dev-tokyo-01"}).environment
```

**Type**: `struct`



## #FromNamespace

FromNamespace resolves information based on the given Kubernetes namespace.

Example:
```
serviceID: (#FromNamespace & {namespace: "acme-echo-jp-prod"}).service
```

**Type**: `struct`



## #GCPRegion

GCPRegion resolves a GCP region from the name of the city in which it is
physically present.

Example:
```
tokyo: #GCPRegion["tokyo"]
```

**Type**: `struct`



## #KubeContext

KubeContext resolves a Kubernetes configuration context name from the given
environment and region.

Example:
```
ctx: #KubeContext["development"]["tokyo"]
```

**Type**: `_|_`



