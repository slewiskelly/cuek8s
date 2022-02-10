// Package tasks contains definitions related to workflow tasks.
package tasks

// Task specifies a single workflow task.
#Task: {
	// Tasks in which this task is dependent on.
	$after: #Task | [...#Task]

	// ID of the operation undertaken by the task.
	$id: string

	...
}
