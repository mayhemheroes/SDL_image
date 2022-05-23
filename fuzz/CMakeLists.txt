cmake_minimum_required(VERSION 3.14)

add_executable(sdl-fuzz fuzz.c)

## Uncomment these lines after converting fuzzme.c into a libFuzzer target
if (NOT CMAKE_C_COMPILER_ID STREQUAL "Clang")
    message(FATAL_ERROR "Clang is required for libFuzzer!")
endif()
target_compile_options(sdl-fuzz PUBLIC -fsanitize=fuzzer -I/usr/include/SDL)
target_link_options(sdl-fuzz PUBLIC -fsanitize=fuzzer -lSDL2main -lSDL2)

target_link_libraries(sdl-fuzz PRIVATE SDL2_image::${sdl2_image_export_name})

