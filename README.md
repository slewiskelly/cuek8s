# CUEK8s

CUEK8s is an experimental environment for a CUE based approach to Kubernetes
manifest management.

It assumes a somewhat homogeneous environment so that abstractions can be
provided to service owners, while still provide high levels of customization
and flexibility.

The operating environment is assumed to be:
- Multi-tenant (e.g. details, productpage, ratings, reviews)
- Multi-environment (e.g. dev, prod)
- Multi-region (e.g. london, tokyo)
- Multi-cluster (e.g. dev-tokyo-01, dev-tokyo-02)

It is largely incomplete, with some specific offerings being ommitted (either
because they are far from complete or too specific to internal use cases.
However, it is sufficient as an example and environment to experiment for the
purposes of future development.

## Packages

Various packages are provided which provide abstraction as well as constrained
definitions of Kubernetes resources.

See [here](./docs/index.md) for reference documentation.

Kubernetes definitions have also beeen imported which can be used directly if
neither the constrained definitions nor the abstractions are appropriate. These
definitions are stored under `cue.mod/gen/`.

## Delivery

Resources are grouped together as a unit known as a deliverable.

The reason for this is so that these groups of resources can be deployed as a
single unit. It also allows resources to be deployed via different (or even
multiple) methods.

## Command Line Tool

A command line tool (`cuek8s`) is provided to interact with configurations.

The eventual goal of this tool is to replace all functionality (and add more) to
what is already provided via the commands in `cuek8s_tool.cue` (see below).

The following commands are currently supported:
- `doc`
  - Displays or generates reference documentation
- `dump`
  - Displays generated Kubernetes manifest configuration
- `list`
  - Lists Kubernetes resources along with other metadata

To build the tool:

```shell
make build
```

and to see available commands and their usage:

```shell
./bin/cuek8s help
```

## CUE Scripts

The following commands are currently supported:
- `apply`
  - Deploys Kubernetes resources
- `deliverables`
  - Lists deliverables (a group of resources deployed as a single unit)
- `dump`
  - Displays generated Kubernetes manifest configuation
- `list`
  - Lists Kubernetes resources along with other metadata
- `plan`
  - Plans the deployment of Kubernetes resources

See `cue commands` for more information about custom CUE commands, and
`cue injection` for more information about injecting values.

### Local Environment

A CUE tool in the form of `tools/bootstrap_tool.cue` will spin up a local
environment using [k3s](https://github.com/k3s-io/k3s) and
[k3d](https://github.com/rancher/k3d/).

It can be setup via:

```shell
make up
```

and torn down via:

```shell
make down
```

This creates a minimal environment, with just the `dev-tokyo` cluster and the
following namespaces:
- `details-dev`
- `productpage-dev`
- `ratings-dev`
- `reviews-dev`

To create a custom environment, the tool can be run via the `cue` command,
and injecting values:

```shell
cue [-t environments=ENVIRONMENTS -t regions=REGIONS] up ./tool/...
```

Similarly, to teardown the custom environment:

```shell
cue [-t environments=ENVIRONMENTS -t regions=REGIONS] down ./tool/...
```

See `cue injection` for more information about injecting values.
