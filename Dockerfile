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
RUN git clone https://github.com/capuanob/SDL_image.git
WORKDIR SDL_image
RUN git checkout mayhem
WORKDIR /SDL

## Install extensions
WORKDIR /SDL
RUN ./SDL_image/external/download.sh

## Install AVIF manually, as vendored support isn't yet available
WORKDIR /
RUN git clone https://github.com/AOMediaCodec/libavif.git
WORKDIR /libavif
RUN mkdir build
WORKDIR build
RUN cmake .. && make -j$(nproc) && make install && ldconfig

## Build
WORKDIR /SDL
RUN mkdir build
WORKDIR build
RUN CC=clang CXX=clang++ cmake -DSDL2IMAGE_FUZZ=1 -DSDL2IMAGE_JXL=1 -DSDL2IMAGE_TIF=1 \
    -DSDL2IMAGE_WEBP=1 -DSDL2IMAGE_VENDORED=1 ../SDL_image/
RUN make -j$(nproc)

## Create symbolic links
RUN ln -s /SDL/build/fuzz/sdl-fuzz /sdl-fuzz
RUN ln -s /SDL/SDL_image/fuzz/corpus /corpus

## Set up fuzzing!
ENTRYPOINT []
CMD /sdl-fuzz /corpus -close_fd_mask=2
