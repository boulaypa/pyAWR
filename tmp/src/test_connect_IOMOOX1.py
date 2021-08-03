#!/usr/bin/python3

import cx_Oracle
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib import style
import os

if __name__ == '__main__':

    dsn_tns = cx_Oracle.makedsn('10.221.47.162', '1521', service_name='IOMOOX1') 
    connection = cx_Oracle.connect(user="DBA_TOOLS",password="magnus01",dsn=dsn_tns)
    connection.close()
