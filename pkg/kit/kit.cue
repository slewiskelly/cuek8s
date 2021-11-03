// Package kit contains useful abstractions on top of commonly used Kubernetes
// resources.
//
// The two main abstractions are:
// - Application
// - Batch
//
// These abstractions allow developers to configure workloads without many of
// the infrastructure concerns that are required when configuring via "raw"
// Kubernetes YAML.
//
// The abstractions will generate a set of resources which can be deployed to a
// cluster by a chosen deployment method.
//
// The abstractions provide sane and/or recommended defaults, but each
// abstraction allows a patching mechanism to allow fine-tuning, if required.
//
// Other abstractions included are:
// - ConfigMap
// - Service
//
// These abstractions are very minor but provide small conviniences in terms of
// metadata and defaults.
//
// The same patching mechanism is available for these abstractions as well.
package kit
