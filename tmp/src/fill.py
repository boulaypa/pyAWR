#!/usr/bin/python3

# importing pandas as pd 
import pandas as pd 
  
# Creating the Series 
sr = pd.Series([100, None, None, 18, 65, None, 32, 10, 5, 24, None]) 
  
# Create the Index 
index_ = pd.date_range('2010-10-09', periods = 11, freq ='M') 
  
# set the index 
sr.index = index_ 
  
# Print the series 
print(sr) 

# fill the values using forward fill method 
result = sr.fillna(method = 'ffill') 
print(result) 

result2 = sr.fillna(0) 
print(result2) 

