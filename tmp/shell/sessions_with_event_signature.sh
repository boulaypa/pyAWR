start="TO_DATE('2019040820','YYYYMMDDHH24')"
end="TO_DATE('2019040901','YYYYMMDDHH24')"
tag="08Avr2019"
event="enq: TX - row lock contention"
dbname=NTOP00

start="TO_DATE('2019120912','YYYYMMDDHH24')"
end="TO_DATE('2019121023','YYYYMMDDHH24')"
tag="09Dec2019"

./sessions_with_event_signature.py $dbname "$event" "$start" "$end" "sessions_with_event_signature_${tag}.png"
