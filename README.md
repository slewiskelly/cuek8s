# cuek8s

This directory contains an early PoC of a Kubernetes manifest abstraction using
CUE.

It has been heavily inspired by the [CUE Kubernetes Tutorial](https://cue.googlesource.com/cue/+/HEAD/doc/tutorial/kubernetes/README.md).

## Commands

### Dump

The `dump` command will display a list of Kubernetes resources in YAML format.

```shell
# Dumps all resources for a service, within all clusters in the dev environment.
cue dump ./microservices/$SERVICE/dev/...

# Dumps all resources for a service, that are managed by Spinnaker, within the
# production environment.
cue -t objects=managed dump ./microservices/$SERVICE/prod/...

# Dumps all resources for a service, the are applied directly via `kubectl`,
# within the production environment, in the Tokyo cluster.
cue -t objects=unmanaged dump ./microservices/$SERVICE/prod/tokyo/...
```

### List

The `list` command will display a table of resources (namespace, name, kind).

```shell
# Lists all resources for a service, across all environments and clusters.
cue list ./microservices/$SERVICE/...
```

