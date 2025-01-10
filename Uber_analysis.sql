select * from public."Uber_dataset"

select count(*) as total_data from public."Uber_dataset"

select distinct(year) from public."Uber_dataset"

-- 1

select year, avg(fare_price) as year_fare_trend from public."Uber_dataset" group by year

select month,avg(fare_price) as month_fare_trend from public."Uber_dataset" group by month

select week,avg(fare_price) as week_fare_trend from public."Uber_dataset" group by week

select day,avg(fare_price) as day_fare_trend from public."Uber_dataset" group by day

--2
select travel_mode, count(*) as most_popular
                 from public."Uber_dataset"
                 group by travel_mode
                 order by most_popular desc

--3
select extract(Hour from pickup_time) as peak_ride_hour,
               count(*) as ride_count
               from public."Uber_dataset"
               group by peak_ride_hour
               order by ride_count desc
				 
--4
select pickup_longitude,pickup_latitude,dropoff_longitude,dropoff_latitude,count(*) as most_frequent_location
               from public."Uber_dataset"
			   group by pickup_longitude,pickup_latitude,dropoff_longitude,dropoff_latitude
			   order by most_frequent_location desc limit 10

--5
select distinct(passeger_count),cume_dist() 
               over (order by passeger_count) as passenger_distribution
			   from public."Uber_dataset"

--6
select travel_mode,avg(fare_price)as Avg_fare_price
               from public."Uber_dataset" group by travel_mode

create extension postgis

--7
select travel_mode,
       avg(ST_Distance(ST_makepoint(pickup_longitude,pickup_latitude),
	       ST_makepoint(dropoff_longitude,dropoff_latitude))) as avg_trip_distance
		   from public."Uber_dataset" group by travel_mode

--8
select 
    extract(hour from pickup_time) as hour_of_day, 
    fare_price
from public."Uber_dataset"

select hour_of_day, 
       avg(fare_price) as avg_fare_price
       from(
    select extract(hour from pickup_time) as hour_of_day, 
        fare_price
    from public."Uber_dataset"
) as hourly_fares
group by hour_of_day
order by hour_of_day

--9

with WeekdayData as (
    select pickup_longitude,pickup_latitude,
        count(*) as weekday_trips
    from public."Uber_dataset"
    where extract (dow from pickup_datetime) not in (0, 6) -- Exclude Saturdays and Sundays
    group by pickup_longitude,pickup_latitude
),
WeekendData as (
    select pickup_longitude,pickup_latitude,
        count(*) as weekend_trips
    from
        public."Uber_dataset"
    where
        extract(dow from pickup_datetime) in (0, 6) -- Include Saturdays and Sundays
    group by pickup_longitude,pickup_latitude
)
select
    wd.pickup_longitude,
    wd.pickup_latitude,
    wd.weekday_trips,
    w.weekend_trips
from
    WeekdayData wd
join
    WeekendData w on wd.pickup_longitude = w.pickup_longitude and wd.pickup_latitude = w.pickup_latitude
order by
    case 
        when wd.weekday_trips > w.weekend_trips then wd.weekday_trips
        else w.weekend_trips
    end desc
limit 20

--10

select
    case
        when st_distance(st_makepoint(pickup_longitude, pickup_latitude), st_makePoint(-74.0060, 40.7128)) <= 0.5 THEN 'Times Square' 
        when st_distance(st_makePoint(dropoff_longitude, dropoff_latitude), st_makePoint(-74.0060, 40.7128)) <= 0.5 THEN 'Times Square'
        else 'Other'
        end as location,
        avg(fare_price) as avg_fare_price
from public."Uber_dataset"
group by location