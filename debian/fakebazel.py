#!/usr/bin/python3
# FakeBazel
# Copyright (C) 2019 Mo Zhou <lumin@debian.org>
import os, sys, re, argparse
from ninja_syntax import Writer
from typing import *

class FakeBazel(object):
    @staticmethod
    def parseBuildlog(path: str) -> List[str]:
        cmdlines = []
        lines = open(path, 'rt').readlines()
        for line in lines:
            line = line.strip()
            if line.endswith(')'):
                #print(re.sub('\)$', '', line))
                cmdlines.append(re.sub('\)$', '', line))
        print(f'* Parsed[{path}] {len(cmdlines)} command lines.')
        return cmdlines
    @staticmethod
    def rinseCmdlines(cmdlines: List[str]) -> List[str]:
        pass
    def __init__(self, path: str):
        self.cmdlines = self.parseBuildlog(path)

fakeb = FakeBazel(sys.argv[1])
