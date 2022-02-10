// Package cmp contains task definitions for performing comparisons.
package cmp

import (
	"github.com/slewiskelly/cuek8s/pkg/workflow/tasks"
)

// Diff specifies a task which compares a diff of two strings.
#Diff: tasks.#Task & {
	$id: "cmp.Diff"

	// A string to compare.
	x: string @input()

	// A string to compare.
	y: string @input()

	// The resulting difff between `x` and `y`.
	diff: string @output()
}
