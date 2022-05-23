#include "SDL_image.h" //fuzzer target
#include "SDL_rwops.h" // necessary SDL_rwop data structure
#include <string.h> //memcpy

int LLVMFuzzerTestOneInput(const uint8_t* data, size_t size) {
    // Create a new buffer of non-const fuzzer data
    uint8_t fuzz_data[size];
    memcpy(fuzz_data, data, size);

    // Convert fuzzer data to an instance of SDL_RWops
    SDL_RWops* src = SDL_RWFromMem(fuzz_data, size);

    // Call target to convert our fuzzer input into an SDL surface
    IMG_Load_RW(src, 1);

    return 0;
}
