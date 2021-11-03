package cuek8s

import (
	"embed"
)

const Module = "github.com/slewiskelly/cuek8s"

//go:embed cue.mod/gen/* pkg/*
var FS embed.FS
