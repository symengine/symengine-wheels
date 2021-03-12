import sys
from os.path import join as pjoin
import os
import shutil
from glob import glob
import tempfile
import subprocess

from delocate import wheeltools

def add_library(lib_paths, dist_path='dist'):
    wheel_fnames = glob(pjoin(dist_path, '*.whl'))
    for fname in wheel_fnames:
        print('Processing', fname)
        fname = os.path.abspath(fname)
        with wheeltools.InWheel(fname, fname):
            for lib_path in lib_paths:
                shutil.copy2(lib_path, pjoin('symengine', 'lib'))

def main():
    args = list(sys.argv)
    args.pop(0)
    add_library(args)

if __name__ == '__main__':
    main()
