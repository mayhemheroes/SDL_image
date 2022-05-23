# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git clang make libsdl2-dev python3 pip
RUN pip install cmake --upgrade

## Add source code to the build stage.
WORKDIR /
RUN mkdir SDL
WORKDIR /SDL
RUN git clone https://github.com/capuanob/SDL_image.git
WORKDIR SDL_image
RUN git checkout mayhem
WORKDIR /SDL

## Build
RUN mkdir build
WORKDIR build
RUN CC=clang CXX=clang++ cmake -DSDL2IMAGE_FUZZ=1 ../SDL_image/
RUN make -j$(nproc)

## Create symbolic links
RUN ln -s /SDL/build/fuzz-sdl-fuzz /sdl-fuzz
RUN ln -s /SDL/SDL_image/fuzz/corpus /corpus

## Set up fuzzing!
ENTRYPOINT []
CMD /sdl-fuzz /corpus -close_fd_mask=2
