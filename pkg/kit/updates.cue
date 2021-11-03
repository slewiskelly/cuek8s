package kit

// UpdateType
#UpdateType: #Recreate | *#Rolling

// Recreate specifies a recreate update strategy.
#Recreate: {
	_type: "recreate"

	recreate: {} @input()
}

// Rolling specifies a rolling update strategy.
#Rolling: {
	_type: "rolling"

	rolling: {
		// Percentage of additional replicas that may be created during a
		// rollout.
		// Defaults to "50%".
		maxSurge: string & =~"^(0|[1-9]%$|^[1-9][0-9]|100)%$" | *"50%" @input()

		// Percentage of replicas that may be unavailable during a rollout.
		// Defaults to "0%".
		maxUnavailable: string & =~"^(0|[1-9]%$|^[1-9][0-9]|100)%$" | *"0%" @input()
	} @input()
}
