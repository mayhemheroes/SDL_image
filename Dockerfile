# Build Stage
FROM --platform=linux/amd64 ubuntu:22.04 as builder

## Install build dependencies.
RUN for i in 1 2 3 4 5; do \
      apt-get update --fix-missing && \
      DEBIAN_FRONTEND=noninteractive apt-get install -y --fix-missing git clang make libsdl2-dev python3 python3-pip cmake && break || \
      { echo "Attempt $i failed, retrying..."; sleep 15; }; \
    done
RUN pip3 install cmake --upgrade

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
RUN CC=clang CXX=clang++ cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DSDL2IMAGE_FUZZ=1 -DSDL2IMAGE_JXL=1 -DSDL2IMAGE_TIF=1 \
    -DSDL2IMAGE_WEBP=1 -DSDL2IMAGE_VENDORED=1 ../SDL_image/
RUN make -j$(nproc)

## Package Stage
FROM --platform=linux/amd64 ubuntu:22.04 as packager
COPY --from=builder /SDL/build/fuzz/sdl-fuzz /sdl-fuzz
COPY --from=builder /SDL/build/libSDL2_image-2.0.so.0 /usr/lib

RUN for i in 1 2 3 4 5; do \
      apt-get update --fix-missing && \
      DEBIAN_FRONTEND=noninteractive apt-get install -y --fix-missing libsdl2-2.0-0 && break || \
      { echo "Attempt $i failed, retrying..."; sleep 15; }; \
    done
RUN mkdir -p /corpus && echo seed > /corpus/seed

## Set up fuzzing!
ENTRYPOINT []
CMD /sdl-fuzz /corpus
