/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew install ImageMagick

convert -size 4000x4000  radial-gradient:white-orange -gravity center -crop 1500x1500+0+0  rgradient.png
convert rgradient.png icon.png   -gravity center -composite result.png

ICON_PATH="icon-color.png"

convert $ICON_PATH -resize 167x167 "167x167.png"
convert $ICON_PATH -resize 152x152 "152x152.png"
convert $ICON_PATH -resize 76x76 "76x76.png"
convert $ICON_PATH -resize 40x40 "40x40.png"
convert $ICON_PATH -resize 80x80 "80x80.png"
convert $ICON_PATH -resize 29x29 "29x29.png"
convert $ICON_PATH -resize 58x58 "58x58.png"
convert $ICON_PATH -resize 20x20 "20x20.png"
convert $ICON_PATH -resize 120x120 "120x120.png"
convert $ICON_PATH -resize 180x180 "180x180.png"
convert $ICON_PATH -resize 87x87 "87x87.png"
convert $ICON_PATH -resize 60x60 "60x60.png"
