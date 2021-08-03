#!/usr/bin/python3
# import pandas
import pandas as pd
import matplotlib.pyplot as plt

#load gapminder data from url as pandas dataframe
gapminder = pd.read_csv('../files/gapminder-FiveYearData.csv')
print(gapminder.head(3))

gapminder_us = gapminder[gapminder.country=="United States"]
print( gapminder_us )

# create figure and axis objects with subplots()
fig,ax = plt.subplots()
# make a plot
ax.plot(gapminder_us.year, gapminder_us.lifeExp, color="red", marker="o")
# set x-axis label
ax.set_xlabel("year",fontsize=14)
# set y-axis label
ax.set_ylabel("lifeExp",color="red",fontsize=14)

# twin object for two different y-axis on the sample plot
ax2=ax.twinx()
# make a plot with different y-axis using second axis object
ax2.plot(gapminder_us.year, gapminder_us["gdpPercap"],color="blue",marker="o")
ax2.set_ylabel("gdpPercap",color="blue",fontsize=14)
plt.show()
# save the plot as a file
fig.savefig('two_different_y_axis_for_single_python_plot_with_twinx.jpg',
            format='jpeg',
            dpi=100,
            bbox_inches='tight')
