#!/usr/bin/python3

import pandas as pd
import pandas_functions as pf

df = pd.DataFrame({
    'name':[
        'john','mary','peter','jeff','bill'
    ],
    'year_born':[
        '2000', '1999', '2000', '1995', '1992',
    ],
})

df.index
# RangeIndex(start=0, stop=5, step=1)

# build a datetime index from the date column
datetime_series = pd.to_datetime(df['year_born'])
datetime_index = pd.DatetimeIndex(datetime_series.values)

# replace the original index with the new one
df3=df.set_index(datetime_index)

# we don't need the column anymore
df3.drop('year_born',axis=1,inplace=True)

# IMPORTANT! we can only add rows for missing periods
# if the dataframe is SORTED by the index
df3.sort_index(inplace=True)

df3.index

print('Add row for empty periods')
print(' print df3:')
print ( df3 )
# DatetimeIndex(['1992-01-01', '1995-01-01', '1999-01-01', '2000-01-01',
#               '2001-01-01'],
#              dtype='datetime64[ns]', freq=None)


# 'YS' stands for 'YEAR START'
#print ( 'df4=df3.asfreq<======== issue !!!')
#df4=df3.asfreq('YS')

#df4.index
