package shell

import (
	"fmt"
	"os"
	"os/exec"
)

func RunPythonCode(code string, arg ...string) (output string, err error) {
	tmpfile, err := os.CreateTemp("", "mobius_python_script_*.py")
	if err != nil {
		panic(err)
	}
	defer tmpfile.Close()

	if _, err = tmpfile.Write([]byte(code)); err != nil {
		panic(err)
	}

	args := []string{tmpfile.Name()}
	args = append(args, arg...)

	cmd := exec.Command("python", args...)
	bs, err := cmd.CombinedOutput()
	if err != nil {
		err = fmt.Errorf("err: %w, output: %s", err, string(bs))
		return
	}

	output = string(bs)
	return
}
