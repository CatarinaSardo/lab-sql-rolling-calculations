-- Get number of monthly active customers.

select
    month(r.rental_date) as month,
    count(distinct r.customer_id) as monthly_active_customers
from
    rental r
join
    payment p on r.rental_id = p.rental_id
group by
    month(r.rental_date)
order by
    month(r.rental_date);


-- Active users in the previous month.

with monthly_active_customers as (
    select
        date_format(r.rental_date, '%Y-%m') as month,
        count(distinct r.customer_id) as active_customers
    from
        rental r
    join
        payment p on r.rental_id = p.rental_id
    group by
        date_format(r.rental_date, '%Y-%m')
)
select
    m1.month as current_month,
    m1.active_customers as current_month_active,
    lag(m1.active_customers) over (order by m1.month) as previous_month_active,
    (m1.active_customers - lag(m1.active_customers) over (order by m1.month)) as change_in_active_customers
from
    monthly_active_customers m1
order by
    m1.month;



-- Percentage change in the number of active customers.

with monthly_active_customers as (
    select
        date_format(r.rental_date, '%Y-%m') as month,
        count(distinct r.customer_id) as active_customers
    from
        rental r
    join
        payment p on r.rental_id = p.rental_id
    group by
        date_format(r.rental_date, '%Y-%m')
)
select
    m1.month as current_month,
    m1.active_customers as current_month_active,
    lag(m1.active_customers) over (order by m1.month) as previous_month_active,
    (m1.active_customers - LAG(m1.active_customers) over (order by m1.month)) as change_in_active_customers,
    round(((m1.active_customers - lag(m1.active_customers) over (order by m1.month)) / lag(m1.active_customers) over (order by m1.month)) * 100, 2) as percentage_change
from
    monthly_active_customers m1
order by
    m1.month;


-- Retained customers every month.

with monthly_active_customers as (
    select
        date_format(r.rental_date, '%Y-%m') as month,
        count(distinct r.customer_id) as active_customers
    from
        rental r
    join
        payment p on r.rental_id = p.rental_id
    group by
        date_format(r.rental_date, '%Y-%m')
),
retained_customers as (
    select
        month,
        active_customers,
        lag(active_customers) over (order by month) as previous_month_customers
    from
        monthly_active_customers
)
select
    month,
    active_customers,
    coalesce(active_customers - previous_month_customers, active_customers) as retained_customers
from
    retained_customers
order by
    month;

