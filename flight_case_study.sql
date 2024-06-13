select * from flights;

-- 1. Find the month with most number of flights
select monthname(date_of_journey) as month,count(*)as no_of_flights from flights
group by 1
order by 2 desc limit 1;

-- 2. Which week day has most costly flights
select dayname(date_of_journey) as day,round(avg(price),2) as price from flights
group by 1
order by 2 desc limit 1;

-- 3. Find number of indigo flights every month
select monthname(Date_of_Journey) as month,count(*)  from flights
where airline ='indigo'
group by 1 
order by 2 desc

-- 4. Find list of all flights that depart between 10AM and 2PM from
-- Delhi to Banglore
select * from flights
where dep_time between '10:00:00' and '14:00:00' and
destination = 'Delhi' and source = 'Banglore'

-- 5. Find the number of flights departing on weekends from Bangalore
select dayname(date_of_journey)as day,count(*) from flights
where source = 'Banglore' and dayname(date_of_journey) in ('saturday','sunday')
group by 1

-- 6. Calculate the arrival time for all flights by adding the duration to
-- the departure time.
select airline,time(arrival) from flights
alter table flights add column departure datetime
update flights
set departure = str_to_date(concat(date_of_journey,' ',dep_time),'%Y-%m-%d %H:%i')

alter table flights
add column duration_mins integer

alter table flights
add column arrival datetime

-- select duration,replace(substring_index(duration,' ',1),'h',' ')*60  +
-- case when substring_index(duration,' ',-1) = substring_index(duration,' ',1) then 0 
-- else replace(substring_index(duration,' ',-1),'m',' ')
-- end as mins
-- from flights

UPDATE flights
SET duration_mins = 
  CASE
    WHEN duration LIKE '%h%' THEN 
      REPLACE(SUBSTRING_INDEX(duration, ' ', 1), 'h', '') * 60 + 
      REPLACE(REPLACE(SUBSTRING_INDEX(duration, ' ', -1), 'm', ''), 'h', '')
    WHEN duration LIKE '%m%' THEN REPLACE(SUBSTRING_INDEX(duration, ' ', 1), 'm', '')
    ELSE 0 
  END;

-- adding the arrival column data
-- select departure,date_add(departure,interval duration_mins minute) from flights

update flights
set arrival = date_add(departure,interval duration_mins minute)

-- 7. Calculate the arrival date for all the flights
select airline,date_of_journey,source,destination,dep_time,duration,date(arrival)as arrival from flights

-- 8.  Find the number of flights which travel on multiple dates.
SELECT * FROM flights
WHERE DATE(departure) != DATE(arrival);

-- Calculate the average duration of flights between all city pairs. The answer should In xh ym format
select source,destination,time_format(sec_to_time(avg(duration_mins)*60),'%kh %im') as avg_duration from flights
group by 1,2

-- Find all flights which departed before midnight but arrived at their destination after midnight having only 0 stops.
SELECT count(*) FROM flights
WHERE total_stops = 0 AND
DATE(departure) < DATE(arrival);

-- Find quarter wise number of flights for each airline
select quarter(date_of_journey) as quarter,airline,count(*) from flights
group by 1,2

-- Average time duration for flights that have 1 stop vs more than 1 stops
select avg(duration_mins) from flights
where total_stops = 1
select avg(duration_mins) from flights
where total_stops >1

select stops,time_format(sec_to_time(avg(duration_mins)*60),'%kh %im') as avg_time from
(select duration_mins,case when total_stops = 0 then 'non stop'
else 'with stops' end as stops
 from flights) flights
group by 1

-- 	14. Find all Air India flights in a given date range originating from Delhi
-- 1st Mar 2019 to 10th Mar 2019 
select * from flights 
where airline = 'Air India' and source = 'Delhi' and date_of_journey between '2019-03-01' and '2019-03-10'

-- Find the longest flight of each airline
select airline,time_format(sec_to_time(max(duration_mins)*60),'%kh %im')as max_time from flights
group by 1

-- 16. Find all the pair of cities having average time duration > 3 hours
select source,destination,time_format(sec_to_time(avg(duration_mins)*60),'%kh %im') as avg_time from flights
group by 1,2
having avg(duration_mins) > 180

-- 	17. Make a weekday vs time grid showing frequency of flights from Banglore and Delhi
select dayname(departure) as day,
sum(case when hour(departure) between 0 and 5 then 1 else 0 end) as '12am-6am',
sum(case when hour(departure) between 6 and 11 then 1 else 0 end) as '6am-12pm',
sum(case when hour(departure) between 12 and 17 then 1 else 0 end) as '12pm-6pm',
sum(case when hour(departure) between 18 and 23 then 1 else 0 end) as '6pm-12pm'
 from flights
where source = 'banglore' and destination = 'new delhi'
group by 1

select * from flights