#!/usr/bin/python3

# libraries
import numpy as np
import seaborn as sns
import pandas as pd
import matplotlib.pyplot as plt
 
# Create a dataset
my_count=["France","Australia","Japan","USA","Germany","Congo","China","England","Spain","Greece","Marocco","South Africa","Indonesia","Peru","Chili","Brazil"]
df = pd.DataFrame({
"country":np.repeat(my_count, 10),
"years":range(2000, 2010) * 16,
"value":np.random.rand(160)
})
 
# Create a grid : initialize it
g = sns.FacetGrid(df, col='country', hue='country', col_wrap=4, )
 
# Add the line over the area with the plot function
g = g.map(plt.plot, 'years', 'value')
 
# Fill the area with fill_between
g = g.map(plt.fill_between, 'years', 'value', alpha=0.2).set_titles("{col_name} country")
 
# Control the title of each facet
g = g.set_titles("{col_name}")
 
# Add a title for the whole plo
plt.subplots_adjust(top=0.92)
g = g.fig.suptitle('Evolution of the value of stuff in 16 countries')
 
plot.show()
