
import datetime 
import matplotlib.pyplot as plt 
import matplotlib.dates as mdates 
import numpy as np 
  
  
dummy_date = datetime.datetime(2020, 2, 1) 
  
# random date generator 
dates = np.array([dummy_date + datetime.timedelta(hours =(2 * i)) 
                  for i in range(732)]) 
date_length = len(dates) 
  
np.random.seed(194567801) 
y_axis = np.cumsum(np.random.randn(date_length)) 
  
lims = [(np.datetime64('2020-02'),  
         np.datetime64('2020-04')), 
        (np.datetime64('2020-02-03'),  
         np.datetime64('2020-02-15')), 
        (np.datetime64('2020-02-03 11:00'),  
         np.datetime64('2020-02-04 13:20'))] 
  
figure, axes = plt.subplots(3, 1,  
                            constrained_layout = True,  
                            figsize =(6, 6)) 
  
for nn, ax in enumerate(axes): 
      
    locator = mdates.AutoDateLocator(minticks = 3, maxticks = 7) 
    formatter = mdates.ConciseDateFormatter(locator) 
      
    ax.xaxis.set_major_locator(locator) 
    ax.xaxis.set_major_formatter(formatter) 
  
    ax.plot(dates, y_axis) 
    ax.set_xlim(lims[nn]) 
      
axes[0].set_title('Concise Date Formatter') 
  
plt.show() 

