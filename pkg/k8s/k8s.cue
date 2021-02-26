package k8s

// Contains constraints and defaults on top of raw Kubernetes resources.

import (
	apps_v1 "k8s.io/api/apps/v1"
	autoscaling_v1 "k8s.io/api/autoscaling/v1"
	batch_v1 "k8s.io/api/batch/v1"
	batch_v1beta1 "k8s.io/api/batch/v1beta1"
	core_v1 "k8s.io/api/core/v1"
	policy_v1beta1 "k8s.io/api/policy/v1beta1"
)

#ConfigMap: core_v1.#ConfigMap & {
	apiVersion: "v1"
	kind:       "ConfigMap"
}

#CronJob: batch_v1beta1.#CronJob & {
	apiVersion: "batch/v1beta1"
	kind:       "CronJob"

	spec: {
		jobTemplate: spec: #JobSpec
	}
}

#Deployment: apps_v1.#Deployment & {
	apiVersion: "apps/v1"
	kind:       "Deployment"

	spec: {
		revisionHistoryLimit: int | *5
		strategy: {
			type: string | *"RollingUpdate"
			if type == "RollingUpdate" {
				rollingUpdate: {
					maxSurge:       int | string | *"50%"
					maxUnavailable: int | string | *"0%"
				}
			}
		}
		template: spec: #PodSpec
	}
}

#Container: core_v1.#Container & {
	readinessProbe: {
		failureThreshold: int | *3
		httpGet: {
			path:   string | *"/healthz/readiness"
			port:   string | *"healthz"
			scheme: string | *"HTTP"
		}
		initialDelaySeconds: int | *5
		periodSeconds:       int | *10
		successThreshold:    int | *1
		timeoutSeconds:      int | *1
	}

	livenessProbe: {
		failureThreshold: int | *3
		httpGet: {
			path:   string | *"/healthz/liveness"
			port:   string | *"healthz"
			scheme: string | *"HTTP"
		}
		initialDelaySeconds: int | *5
		periodSeconds:       int | *10
		successThreshold:    int | *1
		timeoutSeconds:      int | *1
	}

	securityContext: {
		privileged:             false
		readOnlyRootFilesystem: true
	}
}

#PodSpec: core_v1.#PodSpec & {
	containers: [...core_v1.#Container]

	dnsConfig: options: [{
		name:  "ndots"
		value: "2"
	}, {
		name: "single-request-reopen"
	}, ...]

	imagePullSecrets: [{
		name: "gcr-image-puller-service-account"
	}]

	securityContext: {
		runAsNonRoot: true
		runAsUser:    10001
		runAsGroup:   10001
		supplementalGroups: []
	}
}

#HorizontalPodAutoscaler: autoscaling_v1.#HorizontalPodAutoscaler & {
	apiVersion: "autoscaling/v1"
	kind:       "HorizontalPodAutoscaler"

	spec: {
		maxReplicas:                    int | *3
		minReplicas:                    int | *2
		targetCPUUtilizationPercentage: int | *80
	}
}

#Job: batch_v1.#Job & {
	apiVersion: "batch/v1"
	kind:       "Job"

	spec: #JobSpec
}

#JobSpec: batch_v1.#JobSpec & {
	template: spec: #PodSpec
	ttlSecondsAfterFinished: >=0 | *86400
}

#PodDisruptionBudget: policy_v1beta1.#PodDisruptionBudget & {
	apiVersion: "policy/v1beta1"
	kind:       "PodDisruptionBudget"

	spec: {
		maxUnavailable: int | string | *"50%"
		minAvailable:   null
	} | {
		maxUnavailable: null
		minAvailable:   int | string | *"50%"
	}
}

#Service: core_v1.#Service & {
	apiVersion: "v1"
	kind:       "Service"
}
