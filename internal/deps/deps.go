// Package deps declares a set of packages from which CUE definitions are
// generated.

//go:build deps
// +build deps

package deps

import (
	_ "github.com/mercari/spanner-autoscaler/pkg/api/v1alpha1"
	_ "k8s.io/api/apps/v1"
	_ "k8s.io/api/autoscaling/v1"
	_ "k8s.io/api/autoscaling/v2beta2"
	_ "k8s.io/api/batch/v1"
	_ "k8s.io/api/batch/v1beta1"
	_ "k8s.io/api/core/v1"
	_ "k8s.io/api/networking/v1"
	_ "k8s.io/api/policy/v1beta1"
	_ "k8s.io/api/rbac/v1"
	_ "k8s.io/autoscaler/vertical-pod-autoscaler/pkg/apis/autoscaling.k8s.io/v1"
	_ "k8s.io/ingress-gce/pkg/apis/backendconfig/v1"
	_ "k8s.io/ingress-gce/pkg/apis/frontendconfig/v1beta1"
)
