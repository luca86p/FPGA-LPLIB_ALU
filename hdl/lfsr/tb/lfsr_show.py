#!/usr/bin/env python
# =============================================================================
# Whatis        : Model to verify the states of a lfsr
# Project       : FPGA-LPLIB_ALU
# -----------------------------------------------------------------------------
# File          : lfsr_show.py
# Language      : Python 3.9
# Module        : main()
# Library       : 
# -----------------------------------------------------------------------------
# Author(s)     : Luca Pilato <pilato[punto]lu[chiocciola]gmail[punto]com>
#                 
# Company       : 
# Addr          : 
# -----------------------------------------------------------------------------
# Description
#
#   python lfsr_show.py <taps_hex>
#
#   # Example to see x^{3}+x^{1}+1
#   python lfsr_show.py B
#
#       LFSR polynomial [3, 1, 0] = x^3 + x^1 + 1
#          0 100
#          1 110
#          2 111
#          3 011
#          4 101
#          5 010
#          6 001
#          7 100
#       sequence length 7
#       Maximum-length polynomial!
#
# -----------------------------------------------------------------------------
# Dependencies
# 
# -----------------------------------------------------------------------------
# Issues
# 
# -----------------------------------------------------------------------------
# Copyright (c) 2021 Luca Pilato
# MIT License
# -----------------------------------------------------------------------------
# date        who               changes
# 2021-02-09  Luca Pilato       file creation
# =============================================================================

import sys

# x    is the integer value of the register
# poly e.g. [7 6 0] is the 7-th grade polynomial x^7 + x^6 + 1.
def lfsr_step(x,poly):
    n = max(poly)                       # polynomial grade n
    new_lsb = (x & 1<<(n-1)) >> (n-1)   # init of what to shift in position 0
    for tap in poly:
        if (tap != 0) and (tap != n):
            new_lsb ^= (x & 1<<(tap-1)) >> (tap-1) # bit operation
    # print("new_lsb", new_lsb)
    y = ((x << 1) + new_lsb) % 2**n
    return y


def main():
    
    try:
        taps_hex    = int(sys.argv[1], 16)
    except:
        print("Not enough arg(s)")
        return

    poly = []
    while taps_hex != 0:
        poly.append(taps_hex % 2)
        taps_hex //= 2
        # print(poly)
    poly = [i for i, x in enumerate(poly) if x == 1] # all the occurrences
    poly.sort(reverse = True)
    print("LFSR polynomial", str(poly), end=' = ')
    for i, n in enumerate(poly):
        if n != 0:
            print("x^" + str(n), end=' + ')
        else:
            print("1")

    n = max(poly)
    
    x = 2**(n-1) # init
    y = str(bin(x))[2:].rjust(n,'0')
    print("{:4d} {}".format(0,y[::-1]))

    step_cnt = 0
    for i in range(1,2**n):
        x = lfsr_step(x,poly)
        y = str(bin(x))[2:].rjust(n,'0')
        print("{:4d} {}".format(i,y[::-1]))
        if x == 2**(n-1):
            print("sequence length", i)
            if i == 2**n-1:
                print("Maximum-length polynomial!")
            break   
    return

main()