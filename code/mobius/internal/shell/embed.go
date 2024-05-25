package shell

import (
	_ "embed"
)

//go:embed wikipedia_search.py
var WikipediaSearchPy string

//go:embed google_search.py
var GoogleSearchPy string

//go:embed screenshot_to_base64.sh
var ScreenshotToBase64Sh string
