// Package loader provides a convinient way of loading CUE configuration.
//
// Configuration loaded is given access to all CUE package stored within the
// module `github.com/slewiskelly/cuek8s`.
//
// Example:
//
// ```go
// l, err := loader.New()
// if err != nil {
// 	return err
// }
// defer l.Close()
//
// inst, err := l.Load(args...)
// if err != nil {
// 	return err
// }
//
// if err := inst.Complete(); err != nil {
// 	return err
// }
//
// ctx := cuecontext.New()
//
// v := ctx.BuildInstance(inst)
// if err := inst.Err; err != nil {
// 	return err
// }
//
// if err := v.Validate(); err != nil {
// 	return err
// }
// ```
package loader

import (
	"errors"
	"io/fs"
	"os"
	"path/filepath"
	"strings"

	"cuelang.org/go/cue/build"
	"cuelang.org/go/cue/load"
	"github.com/slewiskelly/cuek8s"
)

// Loader implements a loader of CUE configuration.
type Loader struct {
	overlays map[string]load.Source
}

// New returns an initialized loader.
func New() (*Loader, error) {
	rd, err := moduleRoot("")
	if err != nil {
		return nil, err
	}

	l := &Loader{make(map[string]load.Source)}

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

		path := filepath.Join(rd, p)

		if strings.HasPrefix(p, "pkg") {
			path = filepath.Join(rd, "cue.mod", "pkg", cuek8s.Module, p)
		}

		l.overlays[path] = load.FromBytes(b)

		return nil
	})

	return l, err
}

// Load loads the configuration according to the given inputs and returns the
// resulting build instance.
//
// The inputs may  may specify CUE packages, CUE files, non-CUE files, or some
// combinations of those. See `cue inputs` for more information.
//
// An error is returned if one was encountered when loading the configuration.
func (l *Loader) Load(inputs ...string) (*build.Instance, error) {
	inst := load.Instances(inputs, &load.Config{
		Overlay: l.overlays,
	})[0] // TODO(slewiskelly): If instances > 1.

	return inst, inst.Err
}

func moduleRoot(dir string) (string, error) {
	var err error

	if dir == "" {
		dir, err = os.Getwd()
		if err != nil {
			return "", err
		}
	}

	dir = filepath.Clean(dir)

	for {
		if fi, err := os.Stat(filepath.Join(dir, "cue.mod")); err == nil && fi.IsDir() {
			return dir, nil
		}

		if d := filepath.Dir(dir); d != dir {
			dir = d
			continue
		}

		break
	}

	return "", errors.New("module root not found")
}
