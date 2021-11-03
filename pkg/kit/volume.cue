package kit

import (
	core_v1 "k8s.io/api/core/v1"
)

// Volume specifies an application's volume mount.
#Volume: {
	// Name of the volume.
	name: string @input()

	// Path in which the volume is to be mounted.
	mountPath: string @input()

	// Subpath in which the volume is to be mounted.
	subPath: *null | string @input()

	// Whether the volume is read-only.
	// Defaults to true.
	readOnly: bool | *true @input()

	// Source of the volume mount.
	source: core_v1.#VolumeSource @input()
}
