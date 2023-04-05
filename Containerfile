# despite the name, this is a multiarch container
FROM menci/archlinuxarm:latest AS build
RUN pacman -Syu --noconfirm base-devel git
# create an unprivileged user to run makepkg
RUN echo '%wheel ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN useradd -m builder
RUN usermod -aG wheel builder
# do not compress cog package
RUN sed -i -E 's/PKGEXT=(.*)$/PKGEXT=.pkg.tar/' /etc/makepkg.conf
USER builder
WORKDIR /home/builder
# build cog from AUR package
RUN git clone https://aur.archlinux.org/cog.git
WORKDIR /home/builder/cog
RUN gpg --recv-keys 91C559DBE4C9123B
RUN makepkg -s --noconfirm
RUN sh -c 'mv cog*.pkg.tar cog.pkg.tar'

FROM menci/archlinuxarm:latest
# install deps
# shared-mime-info = render local .html files as html
RUN pacman -Syu --noconfirm seatd cage xorg-xwayland sudo shared-mime-info
# install build cog package
COPY --from=build /home/builder/cog/cog.pkg.tar cog.pkg.tar
RUN pacman -U --noconfirm cog.pkg.tar
# clean up a little
RUN rm cog.pkg.tar
RUN rm -rf /var/cache
# create an unprivileged user to run cog
RUN useradd cog
RUN usermod -aG seat,video,render cog
WORKDIR /app
COPY entrypoint.sh .
COPY cogctl /usr/local/bin
VOLUME [ "/dev/dri" ]
VOLUME [ "/run/udev/data" ]
# create an xdg runtime directory
RUN mkdir -p /run/user/1000
RUN chown -R cog: /run/user/1000
ENV XDG_RUNTIME_DIR=/run/user/1000
# we keep input enabled which requires bind mounting /run/udev/data
# ENV WLR_LIBINPUT_NO_DEVICES=1
# seatd-launch will run seatd, wait until it is ready, then run the specified command
ENTRYPOINT [ "seatd-launch", "./entrypoint.sh", "--" ]
