#!/usr/bin/python3

import argparse as ap

def main():
    parser = ap.ArgumentParser(description="My Script")
    parser.add_argument("--dsn")
    args, leftovers = parser.parse_known_args()

    if args.dsn is not None:
        print ("dsn has been set (value is %s)" % args.dsn )
