#!/usr/bin/python3

import argparse

ap = argparse.ArgumentParser()
ap.add_argument("--dsn", required=False)
# Combine all arguments into a list called args
args = vars(ap.parse_args())
if args["dsn"] is not None:
# do something
    print ("dsn has been set (value is %s)" % args["dsn"] )
