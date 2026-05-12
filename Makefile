CXX=g++
ARCH ?= $(shell uname -m)
OPT_FLAGS ?= -O2 -flto -ffunction-sections -fdata-sections
LINK_OPT_FLAGS ?= -Wl,--gc-sections
ifeq ($(ARCH),armv7l)
  ARCH_FLAGS=-mtune=cortex-a53 -mfpu=neon-vfpv4 -mfloat-abi=hard
else ifeq ($(ARCH),aarch64)
  ARCH_FLAGS=-mtune=cortex-a53
else
  ARCH_FLAGS=
endif
# -std=gnu++17
VERSION?=OSPI
CXXFLAGS=-std=gnu++14 -D$(VERSION) -DSMTP_OPENSSL -Wall -include string.h -include cstdint -Iexternal/TinyWebsockets/tiny_websockets_lib/include -Iexternal/OpenThings-Framework-Firmware-Library/ $(OPT_FLAGS) $(ARCH_FLAGS)
LD=$(CXX)
LIBS=pthread mosquitto ssl crypto i2c lgpio
LDFLAGS=$(addprefix -l,$(LIBS))
BINARY=OpenSprinkler
SOURCES=main.cpp OpenSprinkler.cpp notifier.cpp program.cpp opensprinkler_server.cpp utils.cpp weather.cpp gpio.cpp mqtt.cpp smtp.c RCSwitch.cpp $(wildcard external/TinyWebsockets/tiny_websockets_lib/src/*.cpp) $(wildcard external/OpenThings-Framework-Firmware-Library/*.cpp)
HEADERS=$(wildcard *.h) $(wildcard *.hpp)
OBJECTS=$(addsuffix .o,$(basename $(SOURCES)))

.PHONY: all
all: $(BINARY)

%.o: %.cpp %.c $(HEADERS)
	$(CXX) -c -o "$@" $(CXXFLAGS) "$<"

$(BINARY): $(OBJECTS)
	$(CXX) -o $(BINARY) $(OBJECTS) $(OPT_FLAGS) $(ARCH_FLAGS) $(LINK_OPT_FLAGS) $(LDFLAGS)

.PHONY: clean
clean:
	rm -f $(OBJECTS) $(BINARY)

.PHONY: container
container:
	docker build .
