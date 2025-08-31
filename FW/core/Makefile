# We only allow compilation on linux!
ifneq ($(shell uname), Linux)
$(error OS must be Linux!)
endif

build:
	mkdir -p ./build
	sjasmplus ./src/main.asm --syntax=F --inc

clean:
	rm -rf build

flash:
	PCProg.exe COM18 core.bin

.PHONY: all build clean