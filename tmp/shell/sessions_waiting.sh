owner=HAUP00_OWNER
object=DB_NUMBER
start="TO_DATE('20191201','YYYYMMDD')"
end="TO_DATE('20191231','YYYYMMDD')"
./sessions_waiting.py NTOP00  $owner $object $start $end session_wait__${owner}_${object}.png "count"
