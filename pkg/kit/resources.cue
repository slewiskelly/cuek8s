package kit

// Resources specifies an application's resource configuration.
#Resources: {
	// Minimum amount of resources required by an instance of an application.
	requests: {
		// CPU is specified as the number of vCPUs, fractions of a CPU are
		// allowed.
		cpu: number | *0.5 @input()

		// Memory is specified in bytes.
		memory: int | *128M @input()
	} @input()

	// Maximum amount of resources that can be used by an instance of an
	// application.
	limits: {
		// CPU is specified as the number of vCPUs, fractions of a CPU are
		// allowed.
		cpu: number | *0.5 @input()

		// Memory is specified in bytes.
		memory: int | *128M @input()
	} @input()
}
