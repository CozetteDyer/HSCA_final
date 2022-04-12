#include <stdio.h>
#include <stdint.h>
#include "softfloat.h"
#include "softfloat_types.h"

union sp {
  unsigned short x[2];
  float y;
} X, Y, Z, Result;

int main() {
  
    uint8_t rounding_mode = 0x3;
    uint8_t exceptions;

    uint32_t multiplier, multiplicand, addend, result;
    float32_t f_multiplier, f_multiplicand, f_addend, f_result;

    // Example 2
    multiplicand = 0x42400000;
    multiplier = 0x3ea00000;
    addend = 0x51000000;

    f_multiplier.v = multiplier;
    f_multiplicand.v = multiplicand;
    f_addend.v = addend;

    softfloat_roundingMode = rounding_mode;
    softfloat_exceptionFlags = 0;
    softfloat_detectTininess = softfloat_tininess_beforeRounding;
    f_result = f32_mulAdd(f_multiplier, f_multiplicand, f_addend);
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
	   f_multiplicand.v, f_multiplier.v, f_addend.v, f_result.v);

    // Print out SP number
    printf("\n");
    X.x[1] = (f_multiplicand.v >> 16);
    X.x[0] = (f_multiplicand.v & 0xFFFF);
    printf("X = %1.12f\n", X.y);
    Y.x[1] = (f_multiplier.v >> 16);
    Y.x[0] = (f_multiplier.v & 0xFFFF);    
    printf("Y = %1.12f\n", Y.y);
    Z.x[1] = (f_addend.v >> 16);
    Z.x[0] = (f_addend.v & 0xFFFF);        
    printf("Z = %1.12f\n", Z.y);
    Result.x[1] = (f_result.v >> 16);
    Result.x[0] = (f_result.v & 0xFFFF);            
    printf("Result = %1.12f, ", Result.y);
    printf("NV: %d OF: %d UF: %d NX: %d\n", 
        (softfloat_exceptionFlags >> 4) % 2,
        (softfloat_exceptionFlags >> 2) % 2,
        (softfloat_exceptionFlags >> 1) % 2,
        (softfloat_exceptionFlags) % 2);    
    
    return 0;
}
