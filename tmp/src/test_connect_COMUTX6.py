#!/usr/bin/python3

import cx_Oracle
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib import style
import os

if __name__ == '__main__':

    dsn_tns = cx_Oracle.makedsn('10.221.47.177', '1521', service_name='COMUTX6') 
    connection = cx_Oracle.connect(user="system",password="Ty67_1_June19",dsn=dsn_tns)
    connection.close()
