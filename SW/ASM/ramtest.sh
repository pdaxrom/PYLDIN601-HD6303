#!/bin/bash

writefile=/tmp/wr.bin
readfile=/tmp/rd.bin

ram_test() {
    dd if=/dev/urandom of=$writefile bs=1 count=32768 &>/dev/null
    ../ROM/bootloader /dev/ttyS28 load $writefile 1000

    ../ROM/bootloader /dev/ttyS28 save $readfile 1000 9000
    cmp -s $writefile $readfile && echo "RAM TEST OKAY" || echo "RAM TEST FAILED"
}

ram_test
ram_test
ram_test
ram_test

echo $writefile $readfile
