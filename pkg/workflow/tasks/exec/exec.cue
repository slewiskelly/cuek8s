// Package exec contains task definitions for executing commands.
package exec

import (
	"github.com/slewiskelly/cuek8s/pkg/workflow/tasks"
)

// Run specifies a task in which the a command is executed.
//
// Is is the equivalent of Go's [exec.Command.Run](https://pkg.go.dev/os/exec#Cmd.Run).
#Run: tasks.#Task & {
	$id: "exec.Run"

	// Arguments to the command being executed.
	arg: [...string] @input()

	// Environment variables available to the process.
	env: {
		[string]: string @input()
	}

	// Name of the command being executed.
	name: string @input()

	// Data sent to the executed command's standard error.
	//
	// If `string` data will be captured here, otherwise will be sent to the
	// process's standard error.
	stderr: *null | string @intput()

	// Data to be sent to the executed command's standard input.
	stdin: *null | string @input()

	// Data sent to the executed command's standard output.
	//
	// If `string` data will be captured here, otherwise will be sent to the
	// process's standard out.
	stdout: *null | string @input()

	// Exit code from the executed command.
	exitCode: int @output()
}
