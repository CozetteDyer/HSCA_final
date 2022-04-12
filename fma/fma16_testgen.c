#include <stdio.h>
#include <stdint.h>
#include "softfloat.h"
#include "softfloat_types.h"

typedef union sp {
  float32_t v;
  float f;
} sp;

// lists of tests, terminated with 0x8000
uint16_t easyExponents[] = {15, 0x8000};
uint16_t medExponents[] = {1, 14, 15, 16, 20, 30, 0x8000};
uint16_t allExponents[] = {1, 15, 16, 30, 31, 0x8000};
uint16_t easyFracts[] = {0, 0x200, 0x8000}; // 1.0 and 1.1
uint16_t medFracts[] = {0, 0x200, 0x001, 0x3FF, 0x8000}; 
uint16_t zeros[] = {0x0000, 0x8000};
uint16_t infs[] = {0x7C00, 0xFC00};
uint16_t nans[] = {0x7D00, 0x7D01};

void softfloatInit (void) {
    softfloat_roundingMode = softfloat_round_minMag; 
    softfloat_exceptionFlags = 0;
    softfloat_detectTininess = softfloat_tininess_beforeRounding;
}

float convFloat (float16_t f16) {
    float32_t f32;
    float res;
    sp r;

    f32 = f16_to_f32(f16);
    r.v = f32;
    res = r.f;
    return res;
}

void genCase (FILE *fptr, float16_t x, float16_t y, float16_t z,
	      int mul, int add, int negp, int negz,
	      int roundingMode, int zeroAllowed,
	      int infAllowed, int nanAllowed) {
  
    float16_t result;
    int op, flagVals;
    char calc[80], flags[80];
    float32_t x32, y32, z32, r32;
    float xf, yf, zf, rf;
    float16_t smallest;

    if (!mul) y.v = 0x3C00; // force y to 1 to avoid multiply
    if (!add) z.v = 0x0000; // force z to 0 to avoid add
    if (negp) x.v ^= 0x8000; // flip sign of x to negate p
    if (negz) z.v ^= 0x8000; // flip sign of z to negate z
    op = roundingMode << 4 | mul<<3 | add<<2 | negp<<1 | negz;
//    printf("op = %02x rm %d mul %d add %d negp %d negz %d\n", op, roundingMode, mul, add, negp, negz);
    softfloat_exceptionFlags = 0; // clear exceptions
    result = f16_mulAdd(x, y, z);

    sprintf(flags, "NV: %d OF: %d UF: %d NX: %d", 
        (softfloat_exceptionFlags >> 4) % 2,
        (softfloat_exceptionFlags >> 2) % 2,
        (softfloat_exceptionFlags >> 1) % 2,
        (softfloat_exceptionFlags) % 2);
    // pack these four flags into one nibble, discarding DZ flag
    flagVals = softfloat_exceptionFlags & 0x7 | ((softfloat_exceptionFlags >> 1) & 0x8);

    // convert to floats for printing
    xf = convFloat(x);
    yf = convFloat(y);
    zf = convFloat(z);
    rf = convFloat(result);
    if (mul)
        if (add) sprintf(calc, "%f * %f + %f = %f", xf, yf, zf, rf);
        else     sprintf(calc, "%f * %f = %f", xf, yf, rf);
    else         sprintf(calc, "%f + %f = %f", xf, zf, rf);

    // omit denorms, which aren't required for this project
    smallest.v = 0x0400;
    float16_t resultmag = result;
    resultmag.v &= 0x7FFF; // take absolute value
    if (f16_lt(resultmag, smallest) && (resultmag.v != 0x0000)) fprintf (fptr, "// skip denorm: ");
    if (resultmag.v == 0x0000 && !zeroAllowed) fprintf(fptr, "// skip zero: ");
    if ((resultmag.v == 0x7C00 || resultmag.v == 0x7BFF) && !infAllowed)  fprintf(fptr, "// Skip inf: ");
    if (resultmag.v >  0x7C00 && !nanAllowed)  fprintf(fptr, "// Skip NaN: ");
    fprintf(fptr, "%04x_%04x_%04x_%02x_%04x_%01x // %s %s\n", x.v, y.v, z.v, op, result.v, flagVals, calc, flags);
    
}

void prepTests (uint16_t *e, uint16_t *f,
		char *testName, char *desc, float16_t *cases, 
		FILE *fptr, int *numCases) {
  
    int i, j;

    fprintf(fptr, desc); fprintf(fptr, "\n");
    *numCases=0;
    for (i=0; e[i] != 0x8000; i++)
        for (j=0; f[j] != 0x8000; j++) {
            cases[*numCases].v = f[j] | e[i]<<10;
            *numCases = *numCases + 1;
        }
}

void genMulTests (uint16_t *e, uint16_t *f, int sgn,
		  char *testName, char *desc, int roundingMode,
		  int zeroAllowed, int infAllowed, int nanAllowed) {
  
    int i, j, k, numCases;
    float16_t x, y, z;
    float16_t cases[100000];
    FILE *fptr;
    char fn[80];
 
    sprintf(fn, "work/%s.tv", testName);
    fptr = fopen(fn, "w");
    prepTests(e, f, testName, desc, cases, fptr, &numCases);
    z.v = 0x0000;
    for (i=0; i < numCases; i++) { 
        x.v = cases[i].v;
        for (j=0; j<numCases; j++) {
            y.v = cases[j].v;
            for (k=0; k<=sgn; k++) {
                y.v ^= (k<<15);
                genCase(fptr, x, y, z, 1, 0, 0, 0,
			roundingMode, zeroAllowed, infAllowed, nanAllowed);
            }
        }
    }
    fclose(fptr);
}

void genAddTests (uint16_t *e, uint16_t *f,
		  int sgn, char *testName, char *desc,
		  int roundingMode, int zeroAllowed, int infAllowed,
		  int nanAllowed) {
  
    int i, j, k, numCases;
    float16_t x, y, z;
    float16_t cases[100000];
    FILE *fptr;
    char fn[80];
 
    sprintf(fn, "work/%s.tv", testName);
    fptr = fopen(fn, "w");
    prepTests(e, f, testName, desc, cases, fptr, &numCases);
    y.v = 0x0000;
    for (i=0; i < numCases; i++) {
        x.v = cases[i].v;
        for (j=0; j<numCases; j++) {
            z.v = cases[j].v;
            for (k=0; k<=sgn; k++) {
                z.v ^= (k<<15);
                genCase(fptr, x, y, z, 0, 1, 0, 0,
			roundingMode, zeroAllowed, infAllowed, nanAllowed);
            }
        }
    }
    fclose(fptr);
}

void genFMATests (uint16_t *e, uint16_t *f,
		  int sgn, char *testName,
		  char *desc, int roundingMode,
		  int zeroAllowed, int infAllowed, int nanAllowed) {
  
    int i, j, k, l, numCases;
    float16_t x, y, z;
    float16_t cases[100000];
    FILE *fptr;
    char fn[80];
 
    sprintf(fn, "work/%s.tv", testName);
    fptr = fopen(fn, "w");
    prepTests(e, f, testName, desc, cases, fptr, &numCases);
    for (i=0; i < numCases; i++) {
        x.v = cases[i].v;
        for (j=0; j<numCases; j++) {
            y.v = cases[j].v;
            for (k=0; k<numCases; k++) {
                z.v = cases[k].v;
                for (l=0; l<=sgn; l++) {
                    z.v ^= (l<<15);
                    genCase(fptr, x, y, z, 1, 1, 0, 0, roundingMode, zeroAllowed, infAllowed, nanAllowed);
                }
            }
        }
    }
    fclose(fptr);
}

void genSpecialTests (uint16_t *e, uint16_t *f,
		      int sgn, char *testName,
		      char *desc, int roundingMode,
		      int zeroAllowed, int infAllowed, int nanAllowed) {
  
    int i, j, k, sx, sy, sz, numCases;
    float16_t x, y, z;
    float16_t cases[100000];
    FILE *fptr;
    char fn[80];
 
    sprintf(fn, "work/%s.tv", testName);
    fptr = fopen(fn, "w");
    prepTests(e, f, testName, desc, cases, fptr, &numCases);
    cases[numCases].v = 0x0000; // add +0 case
    cases[numCases+1].v = 0x8000; // add -0 case
    numCases += 2; 
    for (i=0; i < numCases; i++) {
        x.v = cases[i].v;
        for (j=0; j<numCases; j++) {
            y.v = cases[j].v;
            for (k=0; k<numCases; k++) {
                z.v = cases[k].v;
                for (sx=0; sx<=sgn; sx++) {
                    x.v ^= (sx<<15);
                    for (sy=0; sy<=sgn; sy++) {
                        y.v ^= (sy<<15);
                        for (sz=0; sz<=sgn; sz++) {
                            z.v ^= (sz<<15);
                            genCase(fptr, x, y, z, 1, 1, 0, 0, roundingMode, zeroAllowed, infAllowed, nanAllowed);
                        }
                    }
                }
            }
        }
    }
    fclose(fptr);
}

int main() {
  
    softfloatInit(); // configure softfloat modes
 
    // Test cases: multiplication
    genMulTests(easyExponents, easyFracts, 0, "fmul_0", "// Multiply with exponent of 0, significand of 1.0 and 1.1, RZ", 0, 0, 0, 0);
    genMulTests(medExponents, medFracts, 0, "fmul_1", "// Multiply with various exponents and unsigned fractions, RZ", 0, 0, 0, 0);
    genMulTests(medExponents, medFracts, 1, "fmul_2", "// Multiply with various exponents and signed fractions, RZ", 0, 0, 0, 0);

    // Test cases: addition
    genAddTests(easyExponents, easyFracts, 0, "fadd_0", "// Add with exponent of 0, significand of 1.0 and 1.1, RZ", 0, 0, 0, 0);
    genAddTests(medExponents, medFracts, 0, "fadd_1", "// Add with various exponents and unsigned fractions, RZ", 0, 0, 0, 0);
    genAddTests(medExponents, medFracts, 1, "fadd_2", "// Add with various exponents and signed fractions, RZ", 0, 0, 0, 0);

    // Test cases: FMA
    genFMATests(easyExponents, easyFracts, 0, "fma_0", "// FMA with exponent of 0, significand of 1.0 and 1.1, RZ", 0, 0, 0, 0);
    genFMATests(medExponents, medFracts, 0, "fma_1", "// FMA with various exponents and unsigned fractions, RZ", 0, 0, 0, 0);
    genFMATests(medExponents, medFracts, 1, "fma_2", "// FMA with various exponents and signed fractions, RZ", 0, 0, 0, 0);

    // Test cases: Zero, Infinity, NaN
    genSpecialTests(allExponents, medFracts, 1, "fma_special_rz", "// FMA with special cases, RZ", 0, 1, 1, 1);
 
    // Full test cases with other rounding modes
    softfloat_roundingMode = softfloat_round_near_even; 
    genSpecialTests(allExponents, medFracts, 1, "fma_special_rne", "// FMA with special cases, RNE", 1, 1, 1, 1);
    softfloat_roundingMode = softfloat_round_min; 
    genSpecialTests(allExponents, medFracts, 1, "fma_special_rm", "// FMA with special cases, RM", 2, 1, 1, 1);
    softfloat_roundingMode = softfloat_round_max; 
    genSpecialTests(allExponents, medFracts, 1, "fma_special_rp", "// FMA with special cases, RP", 3, 1, 1, 1);
  
    return 0;
}
