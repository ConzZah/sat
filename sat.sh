#!/usr/bin/env sh

### /// setup-alpine-termux // ConzZah /// ###

echo '== setup-alpine-termux // (c) ConzZah 2026 =='

## set path to alpine prootfs
alprootfs="$PREFIX/var/lib/proot-distro/containers/alpine/rootfs/"

## if $alprootfs exists already, stop here.
[ -d "$alprootfs" ] && printf '\n%s\n' "--> ALPINE-ROOTFS EXISTS ALREADY." && exit 0

## update termux packages before continuing
yes| pkg up || exit 1

## if proot-distro is not installed, do so now
! command -v proot-distro >/dev/null && \
apt update && apt install -y proot-distro

## if git is not installed, do so now
! command -v git >/dev/null && \
apt update && apt install -y git

## install alpine
proot-distro install alpine

## set $alp_alias
alp_alias='alias alp="proot-distro login alpine"'

## if $alp_alias couldn't be found in .profile, add it
touch "$HOME/.profile"
! grep -q "$alp_alias" "$HOME/.profile" && \
printf '%s\n' "$alp_alias" >> "$HOME/.profile"

## add .profile to $alprootfs to isolate termux binaries
[ ! -f  ${alprootfs}/root/.profile ] && \
printf '%s\n' '# exclude termux bins, so we dont use them when building
PATH="$(echo "$PATH"| sed "s#:/data/data/com.termux/files/usr/bin##g")"

## remove /usr/bin/git if it exists,
## and make symlink to termux git to avoid "function not implemented" when attempting to clone on some devices
[ -f "/usr/bin/git" ] && rm -f "/usr/bin/git"

[ -f "/data/data/com.termux/files/usr/bin/git" ] && \
ln -s "/data/data/com.termux/files/usr/bin/git" "/usr/bin/git"
' > ${alprootfs}/root/.profile

## change login shell to bash and install basic packages
proot-distro login alpine -- apk add build-base curl bash nano shadow fastfetch git
proot-distro login alpine -- chsh -s /bin/bash root >/dev/null

## login
proot-distro login alpine
