create database pizzahut;

create table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id)
);

create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id)
);

-- 1. Retrieve the total number of order placed
select count(order_id) as total_orders from orders;


-- 2. Get total revenue generated from pizza sales
select round(sum(order_details.quantity * pizzas.price) )as total_sales
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id;

-- 3. what is the highest priced pizza they got?
select pt.name, p.price
from pizza_types pt
join pizzas p
on pt.pizza_type_id = p.pizza_type_id
order by p.price desc limit 1;

-- 4. find out most common sized pizza ordered 
select p.size, count(ord.order_id) total_order_placed
from pizzas p
join order_details ord
on p.pizza_id = ord.pizza_id
group by p.size
order by total_order_placed desc;

-- 5. List top 5 most common ordred pizza types with their quantity
select distinct pt.name, sum(od.quantity) as quantity
from pizza_types pt
join pizzas p 
on pt.pizza_type_id = p.pizza_type_id
join order_details od
on od.pizza_id = p.pizza_id
group by pt.name
order by quantity desc limit 5;


-- Join tables to get total quantity of each pizza category ordered
select pizza_types.category, sum(order_details.quantity) as total_qty
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category;

-- find out distribution of orders by hour of the day 
select hour(order_time), count(order_id) 
from orders
group by hour(order_time);

-- find out category wise distribution of pizza 
select category, count(name)
from pizza_types
group by category;

-- Group the order by date & cal avg num of pizzas ordered per day
select round(avg(quantity)) as avg_pizza_ordered_perday from 
(select order_date, sum(quantity) as quantity
from orders
join order_details
on order_details.order_id = orders.order_id
group by order_date) as order_quantity;

-- find out top 3 most ordered pizza types based on revenue
select pt.name, sum(ord.quantity * p.price) as revenue
from pizza_types pt
join pizzas p
on pt.pizza_type_id = p.pizza_type_id
join order_details ord
on ord.pizza_id = p.pizza_id
group by pt.name
order by revenue desc limit 3;

-- cal percentage contribution of each pizza type to total revenue 
select pizza_types.category,
round(sum(order_details.quantity * pizzas.price) / (select round(sum(order_details.quantity * pizzas.price)) as total_sales
from order_details
join pizzas
on order_details.pizza_id = pizzas.pizza_id) * 100, 2) as revenue
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category
order by revenue desc;

-- Analyze cumulative revenue generated over time
select order_date,
sum(revenue) over(order by order_date) as cum_revenue
from 
(select orders.order_date,
sum(order_details.quantity * pizzas.price) as revenue
from order_details
join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on order_details.order_id = orders.order_id
group by orders.order_date) as sales;

-- find out top 3 most ordered pizza types based on revenue for each pizza category
select name, revenue
from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue	
from pizza_types
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b 
where rn <= 3;









