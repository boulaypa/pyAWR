with hotsegmentvw as
(
select * from
(
SELECT obj# obj_id ,dataobj# data_obj_id,
     sum(logical_reads_delta) AS total_logical_reads
FROM dba_hist_seg_stat a
WHERE     a.snap_id in (select snap_id from dba_hist_snapshot  where trunc(BEGIN_INTERVAL_TIME)=trunc(sysdate))
GROUP BY obj#,dataobj#
order by sum(logical_reads_delta) desc
)
where rownum <= 20
)
