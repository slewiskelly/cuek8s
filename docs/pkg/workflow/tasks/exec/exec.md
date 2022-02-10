# github.com/slewiskelly/cuek8s/pkg/workflow/tasks/exec

```cue
import "github.com/slewiskelly/cuek8s/pkg/workflow/tasks/exec"
```

Package exec contains task definitions for executing commands.

## #Run

Run specifies a task in which the a command is executed.

Is is the equivalent of Go's [exec.Command.Run](https://pkg.go.dev/os/exec#Cmd.Run).

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`arg`|`list`|`[]`|Arguments to the command being executed.|
|`name`|`string`||Name of the command being executed.|
|`stdin`|`(null\|string)`|`null`|Data to be sent to the executed command's standard input.|
|`stdout`|`(null\|string)`|`null`|Data sent to the executed command's standard output.<br/><br/>If `string` data will be captured here, otherwise will be sent to the<br/>process's standard out.|


