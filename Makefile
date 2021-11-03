.PHONY: build
build:
	@go build -o ./bin/cuek8s ./cmd/cuek8s

.PHONY: clean
clean:
	@rm -rf bin dist

.PHONY: down
down:
	@cue down ./tools/...

.PHONY: fmt
fmt:
	@cue fmt -s ./...

.PHONY: test
test:
	@go test -v ./...

.PHONY: tidy
tidy:
	@go mod tidy

.PHONY: trim
trim:
	@cue trim -s ./...

.PHONY: up
up:
	@cue up ./tools/...
