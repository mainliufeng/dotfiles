package main

import (
	"bytes"
	"image/png"
	"net/url"
	"os/exec"
	"strings"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/app"
	"fyne.io/fyne/v2/canvas"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/dialog"
	"fyne.io/fyne/v2/layout"
	"fyne.io/fyne/v2/storage"
	"fyne.io/fyne/v2/widget"
)

func main() {
	a := app.New()
	w := a.NewWindow("ChatGPT-like Chat")

	chat := container.NewVBox()

	userEntry := widget.NewMultiLineEntry()
	userEntry.SetPlaceHolder("Type your message here...")
	sendBtn := widget.NewButton("Send", func() {
		if userEntry.Text != "" {
			addMessage(chat, "user", userEntry.Text)
			userEntry.SetText("")
			// Simulate assistant response
			addMessage(chat, "assistant", "This is a response from the assistant.")
		}
	})

	selectFileBtn := widget.NewButton("Select Image", func() {
		openFileDialog(w, chat)
	})

	takeScreenshotBtn := widget.NewButton("Screenshot", func() {
		takeScreenshot(chat)
	})

	inputContainer := container.NewBorder(nil, nil, selectFileBtn, sendBtn, userEntry)
	chatScroll := container.NewVScroll(chat)
	chatScroll.SetMinSize(fyne.NewSize(400, 300))

	content := container.NewBorder(nil, inputContainer, nil, takeScreenshotBtn, chatScroll)

	w.SetContent(content)
	w.Resize(fyne.NewSize(400, 400))
	w.ShowAndRun()
}

func addMessage(chat *fyne.Container, sender, content string) {
	senderLabel := widget.NewLabelWithStyle(sender+":", fyne.TextAlignLeading, fyne.TextStyle{Bold: true})
	var messageContent fyne.CanvasObject

	if strings.HasPrefix(content, "http") {
		// Check if the content is a URL
		if u, err := url.Parse(content); err == nil && (u.Scheme == "http" || u.Scheme == "https") {
			// Convert *url.URL to fyne.URI
			fyneURI := storage.NewURI(content)
			img := canvas.NewImageFromURI(fyneURI)
			img.FillMode = canvas.ImageFillOriginal
			messageContent = img
		} else {
			messageContent = widget.NewLabel("Invalid URL")
		}
	} else {
		messageContent = widget.NewRichTextFromMarkdown(content)
	}

	messageBox := container.NewVBox(senderLabel, messageContent)
	messageBoxContainer := container.New(layout.NewHBoxLayout(), messageBox)
	if sender == "user" {
		messageBoxContainer.Objects = append(messageBoxContainer.Objects, layout.NewSpacer())
	} else {
		messageBoxContainer.Objects = append([]fyne.CanvasObject{layout.NewSpacer()}, messageBoxContainer.Objects...)
	}

	chat.Add(messageBoxContainer)
	chat.Refresh()
}

func openFileDialog(w fyne.Window, chat *fyne.Container) {
	dialog.NewFileOpen(func(reader fyne.URIReadCloser, err error) {
		if err != nil {
			dialog.ShowError(err, w)
			return
		}
		if reader == nil {
			return
		}

		img := canvas.NewImageFromURI(reader.URI())
		img.FillMode = canvas.ImageFillOriginal
		addImageMessage(chat, "user", img)
	}, w).Show()
}

func takeScreenshot(chat *fyne.Container) {
	cmd := exec.Command("flameshot", "gui", "--raw")

	// Run the command and capture the output
	out, err := cmd.Output()
	if err != nil {
		dialog.ShowError(err, nil)
		return
	}

	// Decode the output to an image
	img, err := png.Decode(bytes.NewReader(out))
	if err != nil {
		dialog.ShowError(err, nil)
		return
	}

	// Create a resource from the image
	buffer := &bytes.Buffer{}
	if err := png.Encode(buffer, img); err != nil {
		dialog.ShowError(err, nil)
		return
	}
	imgResource := fyne.NewStaticResource("screenshot.png", buffer.Bytes())

	// Create an image from the resource
	fyneImg := canvas.NewImageFromResource(imgResource)
	fyneImg.FillMode = canvas.ImageFillOriginal

	addImageMessage(chat, "user", fyneImg)
}

func addImageMessage(chat *fyne.Container, sender string, img *canvas.Image) {
	senderLabel := widget.NewLabelWithStyle(sender+":", fyne.TextAlignLeading, fyne.TextStyle{Bold: true})

	messageBox := container.NewVBox(senderLabel, img)
	messageBoxContainer := container.New(layout.NewHBoxLayout(), messageBox)
	if sender == "user" {
		messageBoxContainer.Objects = append(messageBoxContainer.Objects, layout.NewSpacer())
	} else {
		messageBoxContainer.Objects = append([]fyne.CanvasObject{layout.NewSpacer()}, messageBoxContainer.Objects...)
	}

	chat.Add(messageBoxContainer)
	chat.Refresh()
}
