# github.com/slewiskelly/cuek8s/pkg/workflow/tasks/os

```cue
import "github.com/slewiskelly/cuek8s/pkg/workflow/tasks/os"
```

Package os contains task definitions for performing operations via the
operating system.

## #Mkdir

Mkdir specifies a task which creates a directory in the filesystem.

It is the equivalent of Go's [os.MkdirAll](https://pkg.go.dev/os#MkdirAll).

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`path`|`string`||Directory path to be created. All parent paths will be created if they<br/>do not yet exist.|


## #ReadFile

ReadFile specifies a task which reads a file from the filesystem.

Is is the equivalent of Go's [os.ReadFile](https://pkg.go.dev/os#ReadFile).

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`name`|`string`||Name of the file to create.|


## #WriteFile

WriteFile specifies a task which writes a file to the filesystem.

Is is the equivalent of Go's [os.WriteFile](https://pkg.go.dev/os#WriteFile).

**Type**: `struct`

|Name|Type|Default|Description|
|----|----|-------|-----------|
|`name`|`string`||Name of the file to create.|
|`data`|`string`||Data to be written to the file.|
|`perm`|`int`|`0o666`|Permission bits of the file.|


