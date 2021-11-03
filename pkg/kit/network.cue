package kit

// Network specifies application network configuration.
//
// Example:
// ```cue
// App: kit.#Application & {
//     metadata: {
//         serviceID: "acme-echo-jp"
//         name:      "echo"
//     }
//
//     spec: {
//         image: "acme-echo-jp"
//         network: serviceMesh: {}
//     }
// }
// ```
#Network: {
	// Service mesh specific configuration.
	//
	// By default, a service mesh is disabled.
	serviceMesh: *null | {} @input()
}

// Port specifies an application's network port configuration.
#Port: {
	// Name of the port.
	name: string @input()

	// Port number in which requests are served.
	port: int @input()

	// Network transport protocol.
	protocol: #Protocol @input()

	// Port number in which the container is listening on.
	targetPort: int | *port @input()
}

// Network transport protocol.
#Protocol: *"tcp" | "udp"
