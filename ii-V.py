#! /usr/bin/env python

"""
This script is intended to drill a user with ii-V progressions in an effort
to assist with memorization.

usage:

./ii-V.py

q as any answer exits the script with a report.

Author: Anthony Shackell - August 16, 2016
"""

from random import randint

root_notes = ['Gb', 'G', 'Ab', 'A', 'Bb', 'B', 'Cb', 'C', 'C#', 'Db', 'D', 'Eb', 'E', 'F', 'F#']
ii_notes = ['ab', 'a', 'bb', 'b', 'c', 'c#', 'db', 'd', 'd#', 'eb', 'e', 'f', 'f#', 'g', 'g#']
V_notes = ['Db', 'D', 'Eb', 'E', 'F', 'F#', 'Gb', 'G', 'G#', 'Ab', 'A', 'Bb', 'B', 'C', 'C#']

correct = 0
incorrect = 0
keys_asked = []

while(True):
    # generate random index for above lists
    ind = randint(0, len(root_notes)-1)
    # ask user for key
    answer = raw_input('Progression: ' + ii_notes[ind] + 'm - ' + V_notes[ind] + '7\n')

    # user is terminating session
    if answer == 'q':
        print 'Thanks for testing! You got ' + str(correct) + ' correct answers and ' + str(incorrect) + ' incorrect ones.'
        if keys_asked:
            print 'Keys tested: ' + ', '.join(keys_asked)
        quit()
    # wrong answer
    elif answer != root_notes[ind]:
        print 'Sorry, incorrect. The correct key is ' + root_notes[ind] + '.'
        incorrect += 1
    # right answer!
    else:
        print 'Correct!'
        correct += 1

    # relatively inexpensive operation to keep track of visited keys
    if not root_notes[ind] in keys_asked:
        keys_asked.append(root_notes[ind])
