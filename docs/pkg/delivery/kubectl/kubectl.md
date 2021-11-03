# github.com/slewiskelly/cuek8s/pkg/delivery/kubectl

```cue
import "github.com/slewiskelly/cuek8s/pkg/delivery/kubectl"
```

Package kubectl provides delivery methods and tasks to deploy Kubernetes
resources via kubectl.

## #Apply

Apply is task which executes `kubectl apply`.

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`context`|`(null\|string)`|`null`|Use the provided context when deploying resources.<br/><br/>If unset the current context of the environment is used.|
|`dryRun`|`bool`|`true`|Perform a client-side dry-run.|
|`prune`|`bool`|`false`|Prune resources.<br/><br/>Resources will only be pruned if they have the following label(s):<br/>- `app.acme.in/managed-by=kubectl`|
|`resources`|`list`|`[]`|Kubernetes resources that are to be deployed.|


## #Delivery

Delivery is a delivery method that deploys Kubernetes resources via kubectl.

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`context`|`(null\|string)`|`null`|Use the provided context when deploying resources.<br/><br/>If unset the current context of the environment is used.|
|`prune`|`bool`|`false`|Prune resources.<br/><br/>Resources will only be pruned if they have the following label(s):<br/>- `app.acme.in/managed-by=kubectl`|
|`apply`|`list`|<pre>[{<br/>	$id: *"tool/exec.Run" \| "exec"<br/>	cmd: ["echo", "No resources to apply!"]<br/>	env: {}<br/>	stdout:  *null \| string \| bytes<br/>	stderr:  *null \| string \| bytes<br/>	context: *null \| !=""<br/>	dryRun:  false<br/>	prune:   *false \| bool<br/>	stdin:   ""<br/>	success: bool<br/>	resources: []<br/>}]<pre/>|Set of tasks which will actually deliver the resources.<br/><br/>Tasks are executed in the same order as they are defined.|
|`plan`|`list`|<pre>[{<br/>	$id: *"tool/exec.Run" \| "exec"<br/>	cmd: ["echo", "No resources to apply!"]<br/>	env: {}<br/>	stdout:  *null \| string \| bytes<br/>	stderr:  *null \| string \| bytes<br/>	context: *null \| !=""<br/>	dryRun:  true<br/>	prune:   *false \| bool<br/>	stdin:   ""<br/>	success: bool<br/>	resources: []<br/>}]<pre/>|Set of tasks which will plan how the resources will be delivered,<br/>without actually delivering them.<br/><br/>Tasks are executed in the same order as they are defined.|
|`resources`|`list`|`[]`|Resources to be delivered.|


