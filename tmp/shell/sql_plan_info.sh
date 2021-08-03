start="TO_DATE('20190801','YYYYMMDD')"
end="TO_DATE('20190905','YYYYMMDD')"

id=b6243y0rb6sux
id=1zw15nxf1canp
id=705p9k1z0qsfq
id=c4jv0rj7bcnb4



start="TO_DATE('2019040820','YYYYMMDDHH24')"
end="TO_DATE('2019040901','YYYYMMDDHH24')"
tag=08Avr2019

start="TO_DATE('2019120920','YYYYMMDDHH24')"
end="TO_DATE('2019121023','YYYYMMDDHH24')"
tag="09Dec2019"

./sql_plan_info.py NTOP00 $id "$start" "$end" sql_${id}_sqlplan_${tag}.png
