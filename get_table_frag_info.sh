SCRIPT=get_table_frag_info.sql
SCRIPT=get_index_frag_info.sql

target=DOMUTP6
schema=ESBBWPP1

target=DOMUTX6
schema=ESBBWPX1

get_table_frag_info.py --target $target --sql $SCRIPT --schema $schema 
