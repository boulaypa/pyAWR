for target in DOMUTX6 DOMUTP6 DOMUTR6 DOMUTB6 DOMUTD6
do
    check_connection.py --target DOMUTP6 --sql stats_schema.sql
done
