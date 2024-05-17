package shell

import (
	"fmt"
	"os"
	"os/exec"
)

func RunBashCode(code string, arg ...string) (output string, err error) {
	// TODO flameshot打不开
	tmpfile, err := os.CreateTemp("", "mobius_bash_script_*.sh")
	if err != nil {
		panic(err)
	}
	defer tmpfile.Close()

	if _, err = tmpfile.Write([]byte(code)); err != nil {
		panic(err)
	}

	args := []string{tmpfile.Name()}
	args = append(args, arg...)

	cmd := exec.Command("bash", args...)
	bs, err := cmd.CombinedOutput()
	if err != nil {
		err = fmt.Errorf("err: %w, output: %s", err, string(bs))
		return
	}

	output = string(bs)
	return
}
