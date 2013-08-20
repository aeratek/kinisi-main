
-- temporary data loading and cleaning script
-- raw data goes into extract table
-- transform data into the staging table
-- copy transformed data into global fact table
-- N.B. this is temporary, does not protect well from really dirty data

truncate extract.egg_data;
copy extract.egg_data (
    ts, 
    temp_degc, 
    humidity, 
    no2_raw, 
    no2, 
    co_raw,
    co,
    voc_raw,
    voc) 
-- change the following line to actual location
from '/tmp/CHAQ_10.TXT' 
with CSV
;

drop table if exists staging.egg_data;

with transformed as (
    select
    ts::timestamp with time zone,
    -- change the platform_id to match it up with 
    -- the correct platform
    6::int as platform_id,
    temp_degc::numeric, 
    humidity::numeric, 
    no2_raw::numeric, 
    no2::numeric, 
    co_raw::numeric,
    co::numeric,
    voc_raw::numeric,
    voc::numeric
from extract.egg_data
where ts is not null)
select *
into staging.egg_data
from transformed
;


insert into fact.egg_data (
    ts, 
    platform_id,
    temp_degc, 
    humidity, 
    no2_raw, 
    no2, 
    co_raw,
    co,
    voc_raw,
    voc) 
select * from staging.egg_data
;


