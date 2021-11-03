package main

import (
	"log"

	"github.com/spf13/cobra"

	"github.com/slewiskelly/cuek8s/cmd/cuek8s/commands/create"
	"github.com/slewiskelly/cuek8s/cmd/cuek8s/commands/doc"
	"github.com/slewiskelly/cuek8s/cmd/cuek8s/commands/dump"
	"github.com/slewiskelly/cuek8s/cmd/cuek8s/commands/list"
)

var cmd = &cobra.Command{
	Use:   "cuek8s",
	Short: "cuek8s is a command line utility for http://go/cuek8s",
	Long:  "cuek8s is a command line utility for http://go/cuek8s",

	SilenceUsage:  true,
	SilenceErrors: true,
}

func init() {
	cmd.AddCommand(create.New())
	cmd.AddCommand(doc.New())
	cmd.AddCommand(dump.New())
	cmd.AddCommand(list.New())
}

func main() {
	if err := cmd.Execute(); err != nil {
		log.Fatal(err)
	}
}
