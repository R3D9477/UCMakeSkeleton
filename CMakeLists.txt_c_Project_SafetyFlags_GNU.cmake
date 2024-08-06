# Safety flags for GCC.
# Based on:
#  https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html
#  https://gcc.gnu.org/onlinedocs/gcc/Instrumentation-Options.html
#  https://developers.redhat.com/blog/2018/03/21/compiler-and-linker-flags-gcc

list(APPEND SAFETY_FLAGS
  -Wall
  -Wextra
  -Wshadow
  -Winit-self
  -Wuninitialized
  -Wundef
  -Wswitch-enum
  -Wdouble-promotion
  -Wformat=2
  -Wformat-security
  -Wconversion
  -Wsign-conversion
  -Wold-style-cast
  -Wunreachable-code
  -Werror
  -Wpedantic
  -Wno-unused-value
  -Wno-unused-result
  -Wno-unused-function
  -Wno-unused-parameter
)

if(QT_FOUND)
  list(APPEND SAFETY_FLAGS
    -Wno-padded
  )
endif()

list(APPEND SAFETY_FLAGS
  -Wformat-overflow
  -Wformat-truncation
  -Wl,-z,defs
  -Wl,-z,now
  -Wl,-z,relro
)

if(NOT WIN32)
  list(APPEND SAFETY_FLAGS
    -fstack-clash-protection
    -fstack-protector-all
    -fstack-protector-strong
    -fno-short-enums
    -fno-fast-math
    -fno-common
    -fno-lto
    -fexceptions
    -fverbose-asm
    -fasynchronous-unwind-tables
  )
endif()

list(APPEND SAFETY_FLAGS
  -pipe
  -march=native
  -D_FORTIFY_SOURCE=2
)

list(APPEND SAFETY_FLAGS
  -Wno-float-conversion
)
