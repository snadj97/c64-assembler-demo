#!/bin/bash

TARGET_SIZE=65536
BYTE=0xFF

if [ -f final_file.bin ]; then
  rm final_file.bin
fi

dd if=/dev/zero bs=1 count=$TARGET_SIZE | tr '\000' '\377' > temp_ff_file.bin

cat build/test.out temp_ff_file.bin > padded_file.bin

dd if=padded_file.bin bs=1 count=$TARGET_SIZE > build/final_file.bin

rm temp_ff_file.bin padded_file.bin