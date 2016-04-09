# Running-Count-Distinct
Implement Running Count Distinct logic in EXASOL

SELECT calendar_key, channel_key, mtd_activity_count
FROM   olap.casino_actives  ca
INNER JOIN olap.site_dim sd 
ON (cgpf.casino_site_key = sd.site_key)

INTO :-

select first_play_date as CALENDAR_KEY,   CHANNEL_KEY , 
                sum(count(*)) over (partition by trunc(first_play_date,'MON'),  CHANNEL_KEY order by first_play_date) as   MTD_ACTIVITY_COUNT 
from (select distinct ppd.profile_id, ppd.profile_id_source,   CHANNEL_KEY, 
                                min(cgpf.game_start_date_key) over (partition by trunc(cgpf.game_start_date_key,'MON'), ppd.profile_id, ppd.profile_id_source) as first_play_date 
                from olap.casino_game_play_fact cgpf 
                join olap.player_profile_dim ppd on (cgpf.player_profile_key=ppd.player_profile_key) 
INNER JOIN OLAP.SITE_DIM SD 
ON (CGPF.CASINO_SITE_KEY = SD.SITE_KEY)
) group by first_play_date, CHANNEL_KEY


