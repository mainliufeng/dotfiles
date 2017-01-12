function video2gif() {
    ffmpeg -i $1 -pix_fmt rgb24 -r 10 -f gif - | gifsicle --optimize=3 --delay=10 > $2
}
