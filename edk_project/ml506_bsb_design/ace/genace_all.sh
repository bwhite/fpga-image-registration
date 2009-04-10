#!/bin/bash 

xbash -q -c "cd ../; /usr/bin/make -f ml506_bsb_system.make program; exit;"

xmd -tcl ../data/genace.tcl -hw ../implementation/download.bit -elf ../TestApp_Memory/executable.elf -ace ml506_bsb_testapp_mem.ace -board ml506 -target mdm
xmd -tcl ../data/genace.tcl -hw ../implementation/download.bit -elf ../TestApp_Peripheral/executable.elf -ace ml506_bsb_testapp_periph.ace -board ml506 -target mdm
xmd -tcl ../data/genace.tcl -hw ../implementation/download.bit -ace ml506_bsb_bootloop.ace -board ml506 -target mdm


rm -rf ML50X
mkdir ML50X
cd ML50X
mkdir cfg0 cfg1 cfg2 cfg3 cfg4 cfg5 cfg6 cfg7
cd ..

cp -p ml506_bsb_testapp_mem.ace ML50X/cfg0
cp -p ml506_bsb_testapp_periph.ace ML50X/cfg1
cp -p ml506_bsb_bootloop.ace ML50X/cfg2

cp -p ../implementation/download.bit ../implementation/ml506_bsb_bootloop.bit
cp -p ../TestApp_Memory/executable.elf ../TestApp_Memory/ml506_bsb_testapp_mem.elf
cp -p ../TestApp_Peripheral/executable.elf ../TestApp_Peripheral/ml506_bsb_testapp_periph.elf

