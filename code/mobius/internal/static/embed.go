package static

import (
	_ "embed"
)

//go:embed wikipedia_search.py
var WikipediaSearchPy string

//go:embed browser_search.py
var BrowserSearchPy string

//go:embed browser_load_urls.py
var BrowserLoadUrlsPy string

//go:embed screenshot_to_base64.sh
var ScreenshotToBase64Sh string
