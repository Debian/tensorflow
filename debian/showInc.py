#!/usr/bin/python3.6
# show increment between two file lists
from typing import *
import os
import sys
import re
import argparse


def cG(s: str) -> str:
    return f'\x1b[1;32m{s}\x1b[0;m'


def cR(s: str) -> str:
    return f'\x1b[1;31m{s}\x1b[0;m'


def bazelMangle(l: List[str]) -> List[str]:
    ret = []
    for x in l:
        if x.startswith('@'): continue
        x = re.sub('^//', '', x)
        x = re.sub(':', '/', x)
        ret.append(x)
    return ret


if __name__ == '__main__':

    ag = argparse.ArgumentParser()
    ag.add_argument('-f', help='from', type=str, required=True)
    ag.add_argument('-t', help='to', type=str, required=True)
    ag = ag.parse_args()
    print(vars(ag))

    src = set(bazelMangle([l.strip() for l in open(ag.f, 'r').readlines()]))
    dst = set(bazelMangle([l.strip() for l in open(ag.t, 'r').readlines()]))

    inc = [x for x in dst if x not in src]
    dec = [x for x in src if x not in dst]

    for x in sorted(inc):
        print(cG(f'+{x}'))
    for x in sorted(dec):
        print(cR(f'-{x}'))
