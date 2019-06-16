#!/usr/bin/python3
import os
import sys
from colorama import init, Fore, Style

# Intiialize Colorama.
init()

# Characters to print when a type does or does not have a particular permission.
y = Fore.GREEN + Style.BRIGHT + '✔'
n = Fore.RED   + Style.BRIGHT + '✖'

# Ensure a command-line argument was passed.
if len(sys.argv) > 1:
    # Expand relative path (~ to home directory) if necessary.
    arg = os.path.expanduser(sys.argv[1])
    # Check whether user provided a number or file/directory.
    if arg.isdigit():
        # Permission masks must be 3 digits long and each digit must be within the range of 0-7 (octal).
        # If user provides a four-digit mask (e.g. 0755), trim the leading zero.
        perm = arg[1:] if len(arg) == 4 and arg[0] == '0' else arg
        if not len(perm) == 3 or not all(int(digit) in range(0, 8) for digit in perm):
            sys.exit(Fore.RED + Style.BRIGHT + 'invalid permission mask' + Fore.RESET + Style.RESET_ALL)
    elif os.path.exists(arg):
        perm = oct(os.stat(arg).st_mode)[-3:]
    else:
        sys.exit(Fore.RED + Style.BRIGHT + 'invalid path' + Fore.RESET + Style.RESET_ALL)
else:
    sys.exit(Fore.RED + Style.BRIGHT + 'no argument provided' + Fore.RESET + Style.RESET_ALL)

# Create 'owner', 'group', and 'other' objects to store their respective read, write, and execute capabilities.
class Type:
    def __init__(self):
        self.r, self.w, self.x = n, n, n
owner, group, other = Type(), Type(), Type()

# Convert each individual digit to binary and pad it with zeros if necessary.
# The first bit of the binary result coresponds to read, second to write, and third to execute.
for i, type in enumerate([owner, group, other]):
    digit = '{:03b}'.format(int(perm[i]))
    if digit[0] == '1': type.r = y
    if digit[1] == '1': type.w = y
    if digit[2] == '1': type.x = y

print(                               '                 {}'.format(Fore.BLACK + Style.BRIGHT + perm))
print(Fore.RESET + Style.RESET_ALL + '         owner  group  other')
print(                               '   read   {}     {}     {}'.format(owner.r, group.r, other.r))
print(Fore.RESET + Style.RESET_ALL + '  write   {}     {}     {}'.format(owner.w, group.w, other.w))
print(Fore.RESET + Style.RESET_ALL + 'execute   {}     {}     {}'.format(owner.x, group.x, other.x))
