package kit

// Resources specifies an application's resource configuration.
#Resources: {
	// Minimum amount of resources required by an instance of an application.
	//
	// CPU is specified as the number of vCPUs, fractions of a CPU are allowed.
	// RAM is specified in bytes.
	requests: {
		cpu:    number | *0.5 @input()
		memory: int | *128M   @input()
	} @input()

	// Maximum amount of resources that can be used by an instance of an
	// application.
	//
	// CPU is specified as the number of vCPUs, fractions of a CPU are allowed.
	// RAM is specified in bytes.
	limits: {
		cpu:    number | *0.5 @input()
		memory: int | *128M   @input()
	} @input()
}
