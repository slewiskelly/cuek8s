package kube

base: service: "reviews"

application: reviewsv2: {
	expose: http: port: 9080

	env: LOG_DIR: "/tmp/logs"

	volume: tmp: {
		mountPath: "/tmp"
		source: emptyDir: {}
		readOnly: false
	}

	volume: "wlp-output": {
		mountPath: "/opt/ibm/wlp/output"
		source: emptyDir: {}
		readOnly: false
	}
}
