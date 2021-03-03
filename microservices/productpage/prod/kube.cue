package kube

base: {
	service:     "productpage"
	environment: "prod"
}

application: productpage: {
	expose: http: port: 9080

	network: istio: true

	volume: tmp: {
		mountPath: "/tmp"
		source: emptyDir: {}
		readOnly: false
	}
}
