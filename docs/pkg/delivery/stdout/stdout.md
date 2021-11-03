# github.com/slewiskelly/cuek8s/pkg/delivery/stdout

```cue
import "github.com/slewiskelly/cuek8s/pkg/delivery/stdout"
```

Package stdout provides a delivery method which displays resources to the
terminal's standard output.

## #Delivery

Delivery is a method of delivery which displays resources to the
terminal's standard output.

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`apply`|`list`|<pre>[{<br/>	$id: *"tool/cli.Print" \| "print"<br/>	resources: []<br/>	text: string & yaml.MarshalStream(X.resources) & _<br/>}]<pre/>|Set of tasks which will actually deliver the resources.<br/><br/>Tasks are executed in the same order as they are defined.|
|`plan`|`list`|<pre>[{<br/>	$id: *"tool/cli.Print" \| "print"<br/>	resources: []<br/>	text: string & yaml.MarshalStream(X.resources) & _<br/>}]<pre/>|Set of tasks which will plan how the resources will be delivered,<br/>without actually delivering them.<br/><br/>Tasks are executed in the same order as they are defined.|
|`resources`|`list`|`[]`|Resources to be delivered.|


## #Print

Print is a task which displays resources to the terminal's standard output.

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`resources`|`list`|`[]`|Resources to be displayed.|


