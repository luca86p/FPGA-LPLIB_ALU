#!/usr/bin/env python
# =============================================================================
# Whatis        : Model to verify the states of a lfsr
# Project       : FPGA-LPLIB_ALU
# -----------------------------------------------------------------------------
# File          : lfsr_verif.py
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
#   python lfsr_verif.py <taps_hex>
#
#   # Example to see x^{3}+x^{1}+1
#   python lfsr_verif.py B
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

class LFSR():

    def __init__(self, taps_hex, arch="fibonacci"):
        self.register = []
        self.taps_hex = taps_hex
        self.arch = arch

    def get_poly(self):
        taps = []
        taps_hex = self.taps_hex
        while taps_hex != 0:
            taps.append(taps_hex % 2)
            taps_hex //= 2
        poly = [i for i, x in enumerate(taps) if x == 1] # all the occurrences
        poly.sort(reverse = True)
        return poly
    
    def print_poly(self):
        poly = self.get_poly()
        print("LFSR polynomial", str(poly), end=' = ')
        for i, n in enumerate(poly):
            if n != 0:
                print("x^" + str(n), end=' + ')
            else:
                print("1")
        return

    def get_ord(self):
        return max(self.get_poly())

    def set_seed(self, seedval):
        self.register = seedval.copy()

    def step(self):
        if self.arch=="fibonacci":
            new_bit = self.register.pop() # get and delete last bit
            for tap in self.get_poly():
                if (tap != 0) and (tap != self.get_ord()):
                    new_bit ^= self.register[tap-1]
            self.register.insert(0,new_bit)
        elif self.arch=="galois":
            pass
        

    def __str__(self):
        return "{}".format(''.join(map(str,self.register)))


def main():

    try:
        taps_hex = int(sys.argv[1], 16)
    except:
        print("Not enough arg(s)")
        return

    reg = LFSR(taps_hex=taps_hex)

    reg.print_poly()
    n = reg.get_ord()
    seed = [0]*n
    seed[-1] = 1
    reg.set_seed(seed)

    print("{:4d} {}".format(0,reg))

    # advance the register 3 steps
    for i in range(1,2**n):
        reg.step()
        print("{:4d} {}".format(i,reg))
        if reg.register == seed:
            print("sequence length", i)
            if i == 2**n-1:
                print("Maximum-length polynomial!")
            break 
    return

if __name__ == '__main__':
    main()