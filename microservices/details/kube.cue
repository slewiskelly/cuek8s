package kube

base: service: "details"

application: details: {
	expose: http: port: 9080
	network: istio:      true
	env: DO_NOT_ENCRYPT: "true"
}
