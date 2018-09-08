#!/usr/bin/python3.6
# show increment between two file lists
from typing import *
import os
import sys
import re
import argparse
import glob
from pprint import pprint


def bazelMangle(l: List[str]) -> List[str]:
    ret = []
    for x in l:
        if x.startswith('@'): continue
        if 'third_party' in x: continue
        x = re.sub('^//', '', x)
        x = re.sub(':', '/', x)
        ret.append(x)
    return ret


if __name__ == '__main__':

    ag = argparse.ArgumentParser()
    ag.add_argument('-f', help='from', type=str, required=True)
    ag = ag.parse_args()
    print(vars(ag))

    src = set(bazelMangle([l.strip() for l in open(ag.f, 'r').readlines()]))
    src = [x for x in src if x.endswith('.cc')]

    #pprint(src, indent=2, compact=True)
    testprobe = []

    for x in src:
        xd = os.path.dirname(x)
        xn = os.path.basename(x).split('.')[0]
        xs = '.'.join(os.path.basename(x).split('.')[1:])
        probe = [y for y in glob.glob(f'{xd}/*{xn}*.cc') if x != y]
        probe = [x for x in probe if x.endswith('.cc')]
        testprobe.extend(probe)
        #if probe:
        #    print(probe)

    #pprint(testprobe)
    for x in sorted(testprobe):
        print(x)
