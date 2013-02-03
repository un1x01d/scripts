#!/usr/bin/python
#
# Generate Password Hashes
# Copyright (C) 2011 NC State University
# Written by Jack Neely <jjneely@ncsu.edu>
#
# SDG
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

# This script depends on the GNU extensions to the crypt() glibc
# function call.  So, stick to Linux, alright?

from crypt import crypt
from getpass import getpass

import optparse
import random
import string
import sys

def salt(prefix=""):
    chars = string.ascii_letters + string.digits + "./"
    if prefix in ["$0$", ""]:
        return ''.join(random.choice(chars) for x in range(2))
    else:
        return prefix + ''.join(random.choice(chars) for x in range(8))

def main():
    usage = ''
    parser = optparse.OptionParser(usage)

    parser.add_option("-p", "--password", action="store",
        default=None,
        dest="password",
        help="Clear Text Password to Hash")
    parser.add_option("-6", "--sha512", action="store_true",
        default=False,
        dest="sha512",
        help="Generate a SHA512 Hash")
    parser.add_option("-1", "--md5", action="store_true",
        default=False,
        dest="md5",
        help="Generate a MD5 Hash")
    parser.add_option("-0", "--crypt", action="store_true",
        default=False,
        dest="crypt",
        help="Generate a crypt() Hash")
    parser.add_option("-a", "--all", action="store_true",
        default=False,
        dest="all",
        help="Generate all Hash Values")

    (options, args) = parser.parse_args()

    if not (options.all or options.crypt or options.md5 or options.sha512):
        print "Generate UNIX password hashes.\n"
        parser.print_help()
        sys.exit(1)

    if options.password is None:
        p = getpass("Password: ")
        p2 = getpass("Verify: ")
        if p != p2:
            print "Passwords to not match."
            sys.exit(1)
        else:
            options.password = p
            del p
            del p2

    if options.crypt or options.all:
        print "crypt:  " + crypt(options.password, salt())
    if options.md5 or options.all:
        print "MD5:    " + crypt(options.password, salt("$1$"))
    if options.sha512 or options.all:
        print "SHA512: " + crypt(options.password, salt("$6$"))


if __name__ == "__main__":
    main()

