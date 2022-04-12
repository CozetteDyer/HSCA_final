#include <stdio.h>
#include <stdint.h>
#include "softfloat.h"
#include "softfloat_types.h"

union sp {
  float32_t w;
  unsigned short x[2];
  float y;
} X, Y, Z, Result;

int main() {
  
    uint8_t rounding_mode = 0x0;
    uint8_t exceptions;

    uint16_t multiplier, multiplicand, addend, result;
    float16_t f_multiplier, f_multiplicand, f_addend, f_result;
    char flags[80];

    // 0400_0400_0600_0c_0600_1
    multiplicand = 0x0400;
    multiplier = 0x0400;
    addend = 0x0600;

    f_multiplier.v = multiplier;
    f_multiplicand.v = multiplicand;
    f_addend.v = addend;

    softfloat_roundingMode = rounding_mode;
    softfloat_exceptionFlags = 0;
    softfloat_detectTininess = softfloat_tininess_beforeRounding;
    f_result = f16_mulAdd(f_multiplicand, f_multiplier, f_addend);
    result = f_result.v;    
    exceptions = softfloat_exceptionFlags & 0x1f;

    // What rounding mode?
    if (softfloat_roundingMode == 0)
      printf("Rounding : Round to Nearest Even\n");
    else if (softfloat_roundingMode == 1)
      printf("Rounding : Round to minimum magnitude (toward zero)\n");
    else if (softfloat_roundingMode == 2)
      printf("Rounding : round to minimum (down)\n");
    else if (softfloat_roundingMode == 3)
      printf("Rounding : round to maximum (up)\n");
    else if (softfloat_roundingMode == 4)
      printf("Rounding : round to nearest, with ties to maximum magnitude (away from zero)\n");
    else if (softfloat_roundingMode == 6)
      printf("Rounding : round to odd (jamming), if supported by the SoftFloat port\n");
    else
      printf("Rounding : error (bad value)");        

    // Print out HP number in hexadecimal
    printf("%x * %x + %x = %x\n",
	   f_multiplier.v, f_multiplicand.v, f_addend.v, f_result.v);

    // Print out HP number by converting to SP
    printf("\n");
    X.w = f16_to_f32(f_multiplicand);
    printf("X = %f\n", X.y);
    Y.w = f16_to_f32(f_multiplier);
    printf("Y = %1.12f\n", Y.y);
    Z.w = f16_to_f32(f_addend);    
    printf("Z = %1.12f\n", Z.y);
    Result.w = f16_to_f32(f_result);    
    printf("Result = %1.12f, ", Result.y);
    printf("NV: %d OF: %d UF: %d NX: %d\n", 
        (softfloat_exceptionFlags >> 4) % 2,
        (softfloat_exceptionFlags >> 2) % 2,
        (softfloat_exceptionFlags >> 1) % 2,
        (softfloat_exceptionFlags) % 2);

    
    return 0;
}
