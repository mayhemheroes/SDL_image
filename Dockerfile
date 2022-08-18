# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git clang make libsdl1.2-dev libsdl2-dev python3 pip
RUN pip install cmake --upgrade

## Add source code to the build stage.
WORKDIR /
RUN mkdir SDL
WORKDIR /SDL
ADD . SDL_image
WORKDIR SDL_image
WORKDIR /SDL

## Install extensions
WORKDIR /SDL
RUN ./SDL_image/external/download.sh

## Build
WORKDIR /SDL
RUN mkdir build
WORKDIR build
RUN CC=clang CXX=clang++ cmake -DSDL2IMAGE_FUZZ=1 -DSDL2IMAGE_JXL=1 -DSDL2IMAGE_TIF=1 \
    -DSDL2IMAGE_WEBP=1 -DSDL2IMAGE_VENDORED=1 ../SDL_image/
RUN make -j$(nproc)

## Package Stage
FROM --platform=linux/amd64 ubuntu:20.04 as packager
COPY --from=builder /SDL/build/fuzz/sdl-fuzz /sdl-fuzz
COPY --from=builder /SDL/build/libSDL2_image-2.0.so.0 /usr/lib

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y libsdl1.2debian libsdl2-2.0-0
RUN mkdir -p /corpus && echo seed > /corpus/seed

## Set up fuzzing!
ENTRYPOINT []
CMD /sdl-fuzz /corpus
