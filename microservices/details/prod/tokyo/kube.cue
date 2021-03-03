package kube

base: region: "tokyo"

application: details: {
	delivery: {
		type: "canary"
	}

	scaling: {
		minReplicas: 5
		maxReplicas: 10
	}
}
