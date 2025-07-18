#!/bin/bash

TARGET_SIZE=65536
BYTE=0xFF

if [ -f build/final_file.bin ]; then
  rm build/final_file.bin
fi

dd if=/dev/zero bs=1 count=$TARGET_SIZE | tr '\000' '\377' > build/temp_ff_file.bin

cat build/cartridge.out build/temp_ff_file.bin > build/padded_file.bin

dd if=padded_file.bin bs=1 count=$TARGET_SIZE > build/final_file.bin

rm build/temp_ff_file.bin build/padded_file.bin