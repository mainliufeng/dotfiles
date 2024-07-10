package shell

import (
	"mobius/internal/static"
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
	bs, _ := cmd.CombinedOutput()
	output = string(bs)
	return
}

func BrowserSearch(query string) (output string, err error) {
	return RunPythonCode(static.BrowserSearchPy, query)
}

func BrowserLoadUrls(urls []string) (output string, err error) {
	return RunPythonCode(static.BrowserLoadUrlsPy, urls...)
}

func WikipediaSearch(query, lang string) (output string, err error) {
	return RunPythonCode(static.WikipediaSearchPy, query, "--lang", lang)
}
