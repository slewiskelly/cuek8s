package kit

import (
	"strings"

	"github.com/slewiskelly/cuek8s/pkg/k8s"

	core_v1 "k8s.io/api/core/v1"
)

_#Primary: k8s.#PrimaryContainer & {
	name: _X.metadata.name

	image: "docker.io/slewiskelly/acme-\(_X.spec.image)"

	if len(_X.spec.args) > 0 {
		args: _X.spec.args
	}

	env: [
		{name:                             "ENV", value: _X.metadata.environment},
		for k, v in _X.spec.envSpec {name: k, v},
	]

	envFrom: [ for x in _X.spec.envFrom {x}]

	if _X.spec.network.serviceMesh != _|_ {
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
		if v.subPath != _|_ {subPath: v.subPath}
		readOnly: v.readOnly
	}]

	// TODO(slewiskelly): Causes issues with the following conjunction:
	// _#Primary & {_X: _X}
	_Y: {...}
	let _X = _Y
}
