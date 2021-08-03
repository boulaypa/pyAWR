#!/usr/bin/python3

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime as dt

# Generate sample data
sample_data = np.random.rand(24*365, 5)
df = pd.DataFrame(sample_data, index=pd.date_range('1/1/2015 00:00', periods=len(sample_data), freq='H'))

# Select date range to plot
date_from = dt(2015, 12, 22, 12, 0)
date_to = dt(2015, 12, 22, 23, 0)
df = df.loc[date_from:date_to]

# http://pandas.pydata.org/pandas-docs/stable/visualization.html
df.plot(kind='area', stacked='false', alpha=0.5, colormap='Reds')
plt.savefig('test.pdf', format='pdf', bbox_inches='tight', dpi=300 )
