package shell

import (
	"mobius/internal/static"
	"os"
	"os/exec"
)

func RunBashCode(code string, arg ...string) (output string, err error) {
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
	bs, _ := cmd.CombinedOutput()
	output = string(bs)
	return
}

func ScreenshotToBase64() (base64 string, err error) {
	base64, err = RunBashCode(static.ScreenshotToBase64Sh)
	return
}
