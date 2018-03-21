#!/usr/bin/env python3

'''neovim_pwd.py

This script is to set in `chpwd_functions` for zsh.  If this is executed in
NeoVim terminal, it sets the current dir into the buffer variable.
'''

import os
import sys
from argparse import ArgumentParser, RawTextHelpFormatter
from neovim import attach


def main():
    '''main routine'''
    parser = ArgumentParser(description=__doc__,
                            formatter_class=RawTextHelpFormatter)
    parser.add_argument('-v', '--verbose',
                        help='log verbosely', action='store_true')
    args = parser.parse_args()

    path = os.environ.get('NVIM_LISTEN_ADDRESS', None)
    if not path:
        return 1

    nvim = attach('socket', path=path)
    pwd = os.getcwd().translate(str.maketrans({'"': r'\"', '\\': r'\\'}))
    nvim.command('let b:__pwd__ = "{}"'.format(pwd))
    if args.verbose:
        nvim.command('echo "pwd changed"')

    return 0


if __name__ == '__main__':
    sys.exit(main())
