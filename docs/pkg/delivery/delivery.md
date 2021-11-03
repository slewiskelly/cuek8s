# github.com/slewiskelly/cuek8s/pkg/delivery

```cue
import "github.com/slewiskelly/cuek8s/pkg/delivery"
```

Package delivery contains definitions related to the delivery of Kubernetes
resources.

## #Method

Method is a method of delivery.

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`apply`|`list`|`[]`|Set of tasks which will actually deliver the resources.<br/><br/>Tasks are executed in the same order as they are defined.|
|`plan`|`list`|`[]`|Set of tasks which will plan how the resources will be delivered,<br/>without actually delivering them.<br/><br/>Tasks are executed in the same order as they are defined.|
|`resources`|`list`|`[]`|Resources to be delivered.|


## #Task

Task is a single step which composes an entire delivery method.

**Type**: `struct`



