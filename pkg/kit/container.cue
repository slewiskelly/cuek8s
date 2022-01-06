package kit

import (
	"path"
	"strings"

	"github.com/slewiskelly/cuek8s/pkg/k8s"

	core_v1 "k8s.io/api/core/v1"
)

_Primary: k8s.#PrimaryContainer & {
	name: _X.metadata.name

	image: [
		if _X.spec.image.tag == null {
			path.Join(["\(_X.spec.image.registry)", "\(_X.spec.image.name)"])
		},
		if _X.spec.image.tag != null {
			path.Join(["\(_X.spec.image.registry)", "\(_X.spec.image.name)"]) + ":\(_X.spec.image.tag)"
		},
	][0]

	if len(_X.spec.command) > 0 {
		command: _X.spec.command
	}

	if len(_X.spec.args) > 0 {
		args: _X.spec.args
	}

	env: [
		for k, v in _X.spec.env {name:     k, value: v},
		for k, v in _X.spec.envSpec {name: k, v},
	]

	envFrom: [ for x in _X.spec.envFrom {x}]

	if _X.spec.network.serviceMesh != null {
		lifecycle: preStop: exec: command: [
			"/bin/sh", "-c",
			"sleep 30; wget -qO- --post-data '' localhost:15000/healthcheck/fail; sleep 45; wget -qO- --post-data '' localhost:15000/healthcheck/ok;",
		]
	}

	ports: [...core_v1.#ContainerPort] | *[ for k, p in _X.spec.expose & _X.spec.port {
		containerPort: p.targetPort
		name:          k
		protocol:      strings.ToUpper(p.protocol)
	}]

	resources: {
		requests: {
			cpu:    _X.spec.resources.requests.cpu
			memory: _X.spec.resources.requests.memory
		}
		limits: {
			cpu:    _X.spec.resources.limits.cpu
			memory: _X.spec.resources.limits.memory
		}
	}

	volumeMounts: [ for _, v in _X.spec.volume {
		name:      v.name
		mountPath: v.mountPath
		if v.subPath != null {subPath: v.subPath}
		readOnly: v.readOnly
	}]

	// TODO(slewiskelly): Causes issues with the following conjunction:
	// _Primary & {_X: _X}
	_Y: _
	let _X = _Y
}
