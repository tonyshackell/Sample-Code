/*
A solution to the LeetCode problem "twosum", which, given an array of integers,
returns indices of two numbers such that they add up to a specific target.

It is assumed that each input has exactly one solution.

Author: Anthony Shackell, Jan 18, 2017
*/

#include <stdlib.h>
#include <stdio.h>

// Brute force O(n^2)
int* twosum (int* nums, int numsSize, int target) {
  int i;
  int* indices = malloc(sizeof(int) * 2);
  if (indices == NULL){
    printf("%s\n", "Somehow ran out of memory allocating space for a two element array. Exiting.");
    return NULL;
  }
  for(i = 0; i < numsSize; i++) {
    int j;
    for(j=i+1; j < numsSize; j++) {
      if (nums[i] + nums[j] == target) {
        indices[0] = i;
        indices[1] = j;
        return indices;
      }
    }
  }
  return NULL;
}

int main() {
  // The following is just a single test case. Not meant to be exhaustive.
  int nums[7] = {0,1,1,1,1,1,3};
  int* indices = twosum(nums, 7, 5);
  if (!indices) {
    printf("no indices found.\n");
    exit(1);
  }
  printf("The indices are: ");
  int i;
  for (i = 0; i < 2; i++){
    printf("%i ", indices[i]);
  }
  printf("\n");
}
