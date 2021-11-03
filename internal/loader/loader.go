package loader

import (
	"io/fs"
	"os"
	"path/filepath"
	"strings"

	"cuelang.org/go/cue/build"
	"cuelang.org/go/cue/load"

	"github.com/slewiskelly/cuek8s"
)

type Loader struct {
	overlays map[string]load.Source
	rootDir  string
}

func New() (*Loader, error) {
	td, err := os.MkdirTemp("", "")
	if err != nil {
		return nil, err
	}

	l := &Loader{
		overlays: make(map[string]load.Source),
		rootDir:  td,
	}

	err = fs.WalkDir(cuek8s.FS, ".", func(p string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		if !d.Type().IsRegular() {
			return nil
		}

		b, err := fs.ReadFile(cuek8s.FS, p)
		if err != nil {
			return err
		}

		path := filepath.Join(l.rootDir, p)

		if strings.HasPrefix(p, "pkg") {
			path = filepath.Join(l.rootDir, "cue.mod", "pkg", cuek8s.Module, p)
		}

		l.overlays[path] = load.FromBytes(b)

		return nil
	})

	return l, err
}

func (l *Loader) Close() {
	os.RemoveAll(l.rootDir)
}

func (l *Loader) Load(args ...string) (*build.Instance, error) {
	inst := load.Instances(args, &load.Config{
		Overlay: l.overlays,
	})[0]

	return inst, inst.Err
}
