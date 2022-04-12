#!/bin/sh
BUILD="../TestFloat-3e/build/Linux-x86_64-GCC"
OUTPUT="./vectors"
echo "Editing f16_mulAdd test vectors"
sed -i 's/ /_/g' $OUTPUT/f16_mulAdd_rne.tv
sed -i 's/ /_/g' $OUTPUT/f16_mulAdd_rz.tv
sed -i 's/ /_/g' $OUTPUT/f16_mulAdd_ru.tv
sed -i 's/ /_/g' $OUTPUT/f16_mulAdd_rd.tv
sed -i 's/ /_/g' $OUTPUT/f16_mulAdd_rnm.tv
