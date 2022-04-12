#!/bin/sh
BUILD="../TestFloat-3e/build/Linux-x86_64-GCC"
OUTPUT="./vectors"
echo "Creating f16_mulAdd vectors"
$BUILD/testfloat_gen -rnear_even f16_mulAdd > $OUTPUT/f16_mulAdd_rne.tv
$BUILD/testfloat_gen -rminMag f16_mulAdd > $OUTPUT/f16_mulAdd_rz.tv
$BUILD/testfloat_gen -rmax f16_mulAdd > $OUTPUT/f16_mulAdd_ru.tv
$BUILD/testfloat_gen -rmin f16_mulAdd > $OUTPUT/f16_mulAdd_rd.tv
$BUILD/testfloat_gen -rnear_maxMag f16_mulAdd > $OUTPUT/f16_mulAdd_rnm.tv
