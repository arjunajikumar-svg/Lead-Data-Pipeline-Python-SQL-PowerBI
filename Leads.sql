CREATE DATABASE IF NOT EXISTS leads_db;
use leads_db;


delimiter $$
create procedure table_lead()
begin
select * from stg_leads;
end$$

delimiter ;

delimiter $$
create procedure Count_the_leads()
begin
select source,
		count(lead_id) as Total_Count
from stg_leads
group by source
order by Total_Count desc;
end $$

delimiter ;

delimiter $$
create procedure conversion_rate()
begin
select source,
	round(count(
    case  
    when status = "Won" then 1 else 0
    end ) * 100/ count(*),2) as conversion_rate 
from stg_leads
group by source
order by conversion_rate desc;
end $$

delimiter ;

delimiter $$
create procedure running_total_of_deal_value()
begin
select lead_id,month,
	deal_value,
	sum(deal_value) over (order by month,lead_id) as running_total_of_deal_value
from stg_leads;
end$$

delimiter ;

delimiter $$
create procedure Monthly_Total_deal_value()
begin
select month,
	sum(deal_value) as Monthly_Total
from stg_leads
where status = "Won"
group by month;
end$$

delimiter ;

delimiter $$
create procedure Analysis()
begin
call table_lead();
call Count_the_leads();
call conversion_rate();
call running_total_of_deal_value();
call Monthly_Total_deal_value();
end$$

delimiter ;

call Analysis;

CREATE OR REPLACE VIEW v_lead_counts AS
(select source,
		count(lead_id) as Total_Count
from stg_leads
group by source
order by Total_Count desc);

CREATE OR REPLACE VIEW v_conversion_rate AS
select source,
    round(sum(case when status = 'Won' then 1 else 0 end)*100 / count(*),2) as conversion_rate
from stg_leads
group by source;


CREATE OR REPLACE VIEW v_running_total AS (
select lead_id,month,
	deal_value,
	sum(deal_value) over (order by month,lead_id) as running_total_of_deal_value
from stg_leads
);

CREATE OR REPLACE VIEW v_monthly_deal_value AS (
select month,
	sum(deal_value) as Monthly_Total
from stg_leads
where status = "Won"
group by month
);
