OPEN SCHEMA FG_SECURITY;  -- use any schema you fancy
CREATE OR REPLACE LUA SCRIPT "GMPREPROCESSORSCRIPT_RCD" () RETURNS ROWCOUNT AS
function gm_preprocessor_function_RCD(sqltext)
uppertext=string.upper(sqltext)
if string.find(uppertext,'^%s*SELECT')==nil then return sqltext end
if string.find(uppertext,'%sOLAP%.CASINO_ACTIVES')==nil then return sqltext end
_, _, calendar_key, other_keys, measure_name, table_name, rest_of_query=string.find(uppertext,'SELECT%s+([^,]*),(.*),([^,]*)%s+FROM%s+(%S+%s)%s*[CA]*%s*([^;]*)')
if (measure_name=='MTD_ACTIVITY_COUNT') then granularity='MON' else granularity='MON' end
line1="select first_play_date as "..calendar_key..", " 
line2=" "..other_keys.." "
line3=", sum(count(*)) over (partition by trunc(first_play_date,'"..granularity.."'), "..other_keys.." order by first_play_date) as  "..measure_name.." " 
line4="from (select distinct ppd.profile_id, ppd.profile_id_source,  "
line5=other_keys..", "  
line6="min(cgpf.game_start_date_key) " 
line7="over (partition by trunc(cgpf.game_start_date_key,'"..granularity.."'), ppd.profile_id, ppd.profile_id_source) as first_play_date "
line8="from olap.casino_game_play_fact cgpf join olap.player_profile_dim ppd on (cgpf.player_profile_key=ppd.player_profile_key)"
line9=" "..rest_of_query..") " 
line10="group by first_play_date,"..other_keys.." "
returntext=line1..line2..line3..line4..line5..line6..line7..line8..line9..line10
-- return the preprocessed query text
return returntext
end
/

CREATE LUA SCRIPT "GM_WRAPPER_SCRIPT_RCD" () RETURNS ROWCOUNT AS
import( 'fg_security.gmpreprocessorscript_RCD', 'gmpreprocessorscript_RCD') -- second parameter is just an alias 
sqlparsing.setsqltext(
gmpreprocessorscript_RCD.gm_preprocessor_function_RCD(sqlparsing.getsqltext()))
/
