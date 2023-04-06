# cog-docker

This repository lets you build a container that runs (with access to the host's framebuffer) the [Cog](https://github.com/Igalia/cog) web browser.

## Usage

Build the container ([SYS_CHROOT is needed for pacman postinstall scripts](https://wiki.archlinux.org/title/Podman#Add_SYS_CHROOT_capabilities_(Optional))). This example builds it as root so that the image is accessible by root:

```sh
$ podman build . --cap-add SYS_CHROOT -t cog
```

Run it. You can use the `COG_URL` environment variable to control where it opens, and/or add command line flags to set the URL and other things. If you don't want user input enabled in the container you should set `WLR_LIBINPUT_NO_DEVICES=1`. `COG_URL` may of course be a local file by using `file:///`.

You can also set `COG_FLAGS` to provide additional command line flags to the browser.

```sh
$ # minimal example
$ sudo podman run --rm -d -v /dev/dri:/dev/dri --privileged=true -e COG_URL=example.com -e WLR_LIBINPUT_NO_DEVICES=1 --name cog cog
$ # cogctl is available in the container to control the browser
$ sudo podman exec cog cogctl open google.com
$ sudo podman exec cog cogctl reload
$ sudo podman stop -t0 cog
$ # enable input
$ sudo podman run --rm -d -v /dev/dri:/dev/dri -v /run/udev/data:/run/udev/data --privileged=true -e COG_URL=example.com --name cog cog
$ # pass more flags
$ sudo podman run --rm -d -v /dev/dri:/dev/dri --privileged=true -e COG_URL=example.com -e WLR_LIBINPUT_NO_DEVICES=1 --name cog cog --scale=2.0
```

Enabling input allows for mouse and keyboard. Right now this is not very useful because the cursor is invisible for some reason.

## Todo

Things I would like to do if I work on this more:

- [ ] Restrict permissions more
- [ ] Make the cursor show up
- [ ] Make the container smaller
