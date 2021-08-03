
import numpy as np 
import matplotlib.dates as mdates 
import matplotlib.pyplot as plt 
  
   
# dummy date 
dummy_date = np.arange("2020-04-10",  
                       "2020-05-14", 
                       dtype ="datetime64") 
  
random_x = np.random.rand(len(dummy_date)) 
   
figure, axes = plt.subplots() 
  
axes.plot(dummy_date, random_x) 
axes.xaxis.set( 
    major_locator = mdates.AutoDateLocator(minticks = 1, 
                                           maxticks = 5), 
) 
  
locator = mdates.AutoDateLocator(minticks = 15, 
                                 maxticks = 20) 
formatter = mdates.ConciseDateFormatter(locator) 
  
axes.xaxis.set_major_locator(locator) 
axes.xaxis.set_major_formatter(formatter) 
   
plt.show() 

