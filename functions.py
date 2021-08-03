import cx_Oracle
import pandas as pd
from configparser import ConfigParser

def config(filename='database.ini', section='oracle'):
    # create a parser
    parser = ConfigParser()
    # read config file
    parser.read(filename)

    # get section, default to postgresql
    db = {}
    if parser.has_section(section):
        params = parser.items(section)
        for param in params:
            db[param[0]] = param[1]
    else:
        raise Exception('Section {0} not found in the {1} file'.format(section,
filename))

    return db

def getCon(target):
    paramsO = config(section=target)
    dsn_tns = cx_Oracle.makedsn(paramsO['host'], paramsO['port'], service_name=paramsO['service'])
    conn = cx_Oracle.connect(user=paramsO['user'],password=paramsO['password'],dsn=dsn_tns)
    return( conn )

def normalizeName(name):
    return(name.lower().replace("_delta",""))

def multiIndex_pivot(df, index = None, columns = None, values = None):
    # https://github.com/pandas-dev/pandas/issues/23955
    output_df = df.copy(deep = True)
    if index is None:
        names = list(output_df.index.names)
        output_df = output_df.reset_index()
    else:
        names = index
    output_df = output_df.assign(tuples_index = [tuple(i) for i in output_df[names].values])
    if isinstance(columns, list):
        output_df = output_df.assign(tuples_columns = [tuple(i) for i in output_df[columns].values])  # hashable
        output_df = output_df.pivot(index = 'tuples_index', columns = 'tuples_columns', values = values) 
        output_df.columns = pd.MultiIndex.from_tuples(output_df.columns, names = columns)  # reduced
    else:
        output_df = output_df.pivot(index = 'tuples_index', columns = columns, values = values)    
    output_df.index = pd.MultiIndex.from_tuples(output_df.index, names = names)
    return output_df
