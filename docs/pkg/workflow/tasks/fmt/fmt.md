# github.com/slewiskelly/cuek8s/pkg/workflow/tasks/fmt

```cue
import "github.com/slewiskelly/cuek8s/pkg/workflow/tasks/fmt"
```

Package fmt contains task definitions for performing formatted I/O
operations.

## #Println

Println specifies a task which writes to standard output.

It is the equivalent of Go's [fmt.Println](https://pkg.go.dev/fmt#Println).

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`text`|`string`||Text to be written.|


