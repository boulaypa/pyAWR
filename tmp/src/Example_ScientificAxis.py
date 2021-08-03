import matplotlib.pyplot as plt
import numpy as np
#creating something to plot
x=np.arange(start=0, stop=10000, step=100)
y=np.random.rand(len(x))
y=x*y
#ploting something here
plt.plot(x,y, 'ro', markersize=12)
plt.ticklabel_format(axis='both', style='sci', scilimits=(-2,2))
plt.show()
