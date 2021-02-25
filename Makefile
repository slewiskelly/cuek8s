.PHONY: trim
trim:
	cue trim -s ./...

.PHONY: fmt
fmt:
	cue fmt -s ./...
