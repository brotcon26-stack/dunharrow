#!/bin/bash
TARGET=${1:-'stable'}

if [ "$TARGET" = "rawhide" ]; then
    podman build -t registry.lab/dunharrow:rawhide \
        -f Containerfile \
        --build-arg BASE_IMAGE=quay.io/fedora/fedora-bootc:rawhide \
        && podman push registry.lab/dunharrow:rawhide

else
    podman build -t registry.lab/dunharrow:stable \
        -f Containerfile \
        && podman push registry.lab/dunharrow:stable

fi

