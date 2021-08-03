target0=DOMUTR6
target1=DOMUTX6

sql0=sp_sqlid_count.sql
sql1=awr_sqlid_count.sql 

sql_to_csv_2source.py --target0 $target0 --sql0 $sql0 --target1 $target1 --sql1 $sql1
