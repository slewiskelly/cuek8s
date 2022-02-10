# github.com/slewiskelly/cuek8s/pkg/delivery/kubectl

```cue
import "github.com/slewiskelly/cuek8s/pkg/delivery/kubectl"
```

Package kubectl provides delivery methods and tasks to deploy Kubernetes
resources via kubectl.

## #Apply

Apply is a task which executes `kubectl apply`.

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`context`|`(null\|string)`|`null`|Use the provided context when deploying resources.<br/><br/>If unset the current context of the environment is used.|
|`dryRun`|`bool`|`true`|Perform a client-side dry-run.|
|`prune`|`bool`|`false`|Prune resources that have the following label selector(s):<br/>- app.acme.in/managed-by=kubectl|
|`resources`|`list`|`[]`|Kubernetes resources that are to be deployed.|
|`arg`|`list`|`["No resources to apply!"]`|Arguments to the command being executed.|
|`name`|`string`||Name of the command being executed.|
|`stdin`|`_\|_`||Data to be sent to the executed command's standard input.|
|`stdout`|`(null\|string)`|`null`|Data sent to the executed command's standard output.<br/><br/>If `string` data will be captured here, otherwise will be sent to the<br/>process's standard out.|


## #Delivery

Delivery is a delivery method that deploys Kubernetes resources via
`kubectl`.

Resources delivered via this method will have the following label(s) applied:
- `app.acme.in/managed-by=kubectl`

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`context`|`(null\|string)`|`null`|Use the provided context when deploying resources.<br/><br/>If unset the current context of the environment is used.|
|`prune`|`bool`|`false`|Prune resources that have the folowing label(s) applied:<br/>- `app.acme.in/managed-by=kubectl`|
|`resources`|`list`|`[]`|Kubernetes resources to be delivered.|


