#!/usr/bin/python3
import pandas as pd
import datetime
 
TODAY = datetime.date.today()
ONE_WEEK = datetime.timedelta(days=7)
ONE_DAY = datetime.timedelta(days=1)
 
df = pd.DataFrame({'dt': [TODAY-ONE_WEEK, TODAY-3*ONE_DAY, TODAY], 'x': [42, 45,127]})

print ( df )


r = pd.date_range(start=df.dt.min(), end=df.dt.max())
df.set_index('dt').reindex(r).fillna(0.0).rename_axis('dt').reset_index()

print ( df )
