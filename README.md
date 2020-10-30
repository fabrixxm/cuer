![logo](data/icons/net.kirgroup.Cuer.svg)

**Cuer** is a QRCode reader application for the GNOME desktop

![ScreenShot](screenshots/scan-desktop.png)

[more screenshots](screenshots/)

## Requirements:

- gstreamer >= 1.0
- [gst-plugin-qrcode](https://github.com/fabrixxm/gst-plugin-qrcode) >= 0.2.0 ([AUR](https://aur.archlinux.org/packages/gst-plugin-qrcode/))
- Gtk >= 3.10
- [libhandy](https://source.puri.sm/Librem5/libhandy) >= 1.0.0

to build:

- Vala
- Meson
- Ninja
- GNOME Builder

## Build

	$ meson _build
	$ ninja -C _build
	$ ./_build/src/net.kirgroup.Cuer

or use GNOME Builder.
