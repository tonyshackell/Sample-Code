/*
A solution to the LeetCode problem "Reverse Integer", which, given an integer,
returns it reversed.

Author: Anthony Shackell, Jan 18, 2017
*/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int reverse(int x) {
  // max int value has 10 digits
  int* reversed_array = malloc(sizeof(int) * 10);
  int ret = 0;
  int number_of_digits = 0;
  int neg_bit = 0;

  if (x < 0){
    neg_bit = 1;
    x = x * -1;
  }

  // use modulus to extract individual digits into array
  while (x > 0) {
    int this_dig = x % 10;
    x = x / 10;
    reversed_array[number_of_digits++] = this_dig;
  }

  #ifdef DEBUG
    int j;
    for (j=0; j < number_of_digits; j++){
      printf("%i\n", reversed_array[j]);
    }
    printf("%s: %d\n", "Number of digits", number_of_digits);
  #endif

  //only used for powers of ten now, need to be smaller.
  number_of_digits--;

  // cycle through array and create new number with multiplication
  int i = 0;
  while (number_of_digits >= 0) {
    #ifdef DEBUG
      printf("%s: %d\n", "Number of digits", number_of_digits);
      printf("%s: %d\n", "Array Entry", reversed_array[i]);
      printf("%s: %f\n", "Adding Value", (pow(10,(number_of_digits))) * reversed_array[i]);
    #endif

    ret += pow(10, number_of_digits--) * reversed_array[i++];
  }
  if (neg_bit) return ret * -1;
  return ret;
}

int main() {
  // simple test case
  printf("%i\n", reverse(-21349));
}
