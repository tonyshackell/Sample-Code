/*
A solution to the LeetCode problem "Add Two Numbers". LeetCode description:
"You are given two non-empty linked lists representing two non-negative integers.
The digits are stored in reverse order and each of their nodes contain a single digit.
Add the two numbers and return it as a linked list."

It is assumed that the two numbers do not contain any leading zeros, except the number 0 itself.

Author: Anthony Shackell, Jan 18, 2017
*/

#include <stdlib.h>
#include <stdio.h>

struct ListNode {
  int val;
  struct ListNode* next;
};

// partially implemented
int* addTwoNumbers (struct ListNode* l1, struct ListNode* l2) {
  struct ListNode return_head;
  struct ListNode return_builder = return_head;

  int continue_first = 1;
  int continue_second = 1;
  int add_bit = 0;

  while(continue_first || continue_second) {
    int digit = l1.val + l2.val;
    if (add_bit) {
      digit += 1;
    }
    return_builder.val = digit;
    Struct ListNode nextDig;
    return_builder.next = nextDig;

    if (digit > 9) {
      add_bit = 1;
    }

  }
}

int main() {

}
