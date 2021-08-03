script=get_index_for_schema.sql
target=DOMUTR6
schema=ESBBWPR1

gen_schema_index_ddl.py --target $target --sql $script --schema $schema 
