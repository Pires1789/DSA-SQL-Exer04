# 1 - Qual o número de hubs por cidade?

select 
	hub_city as Cidade, 
	count(*) as Hubs_na_Cidade 
from hubs
group by 1
order by hubs_na_cidade desc;

# 2 - Qual o número de pedidos (orders) por status?

select
	order_status,
    count(order_id) as n_pedidos
from orders
group by 1
order by n_pedidos desc;

# 3 - Qual o número de lojas (stores) por cidade dos hubs?

select 
	b.hub_city as Cidade,
    count(a.store_name) as total
from stores as a
left join hubs as b 
USING (hub_id)
group by 1
order by total desc; 

# 4 - Qual o maior e o menor valor de pagamento (payment_amount) registrado?

select 
	payment_method as metodo,
	max(payment_amount) as pgto_max, 
    min(payment_amount) as pgto_min
from payments
group by 1
order by 
	payment_method, 
	max(payment_amount) desc, 
    min(payment_amount) desc;

# 5 - Qual tipo de driver (driver_type) fez o maior número de entregas?

select 
	if(grouping(dr.driver_type), 'Total Entregas Realizadas', dr.driver_type) as Tipo,
    count(de.driver_id) as entregas_completas 
 from drivers as dr
	left join deliveries as de
	using (driver_id)
 where de.delivery_status in ('Delivered')
 group by 
	dr.driver_type with rollup
order by
	grouping(dr.driver_type);
	
# 6 - Qual a distância média das entregas por tipo de driver (driver_modal)?

select
	dr.driver_modal as modal,
    round(avg(de.delivery_distance_meters),2) as distancia_media
from drivers as dr
	left join deliveries as de
	using (driver_id)
group by dr.driver_modal;

# 7 - Qual a média de valor de pedido (order_amount) por loja, em ordem decrescente?

select 
	st.store_name as Nome_Loja,
    round(avg(b.order_amount),2) as Media_Vlr_Pedido
from stores as st
	inner join orders as b
	using (store_id)
group by 1
order by avg(b.order_amount) desc;

# 8 - Existem pedidos que não estão associados a lojas? Se caso positivo, quantos?

select
	coalesce(store_name, 'Sem Loja'),
    count(order_id) as contagem
from orders
	left join stores
using (store_id)
group by store_name
order by contagem desc;

# 9 - Quantos pagamentos foram cancelados (chargeback)?

select
	payment_status,
    count(payment_status) as n
from payments
where
	payment_status = 'CHARGEBACK'
group by 1;

# 10 - Qual foi o valor médio dos pagamentos cancelados (chargeback)?

select
	payment_status,
    round(avg(payment_amount),2) as n
from payments
where
	payment_status = 'CHARGEBACK'
group by 1;

# 11 - Qual a média do valor de pagamento por método de pagamento (payment_method) em ordem decrescente?

create or replace view vw_media_pagamento as select
	payment_method as metodo,
    round(avg(payment_amount - payment_fee),2) as pgto_total
from payments
group by payment_method
order by pgto_total desc;

# Quais métodos de pagamento tiveram média superior a 100?

select 
	metodo,
    pgto_total
from vw_media_pagamento
group by 1
having pgto_total > 100;

# Qual a média do valor de pedido (order_amount) por estado do hub (hub_state), segemento da loja (store_segment) e tipo de canal (channel_type)?

select
	hub_state,
    store_segment,
    channel_type,
    round(avg(order_amount),2) as media
from 
	orders, 
    stores, 
    channels, 
    hubs
		where stores.store_id = orders.store_id
		and channels.channel_id = orders.channel_id
		and hubs.hub_id = stores.hub_id
group by hub_state, store_segment, channel_type
order by hub_state;

# 15-Qual estado do hub (hub_state), segmento da loja (store_segment) e tipo de canal (channel_type) teve média de valor de pedido (order_amount) maior que 450?

select
	hub_state,
    store_segment,
    channel_type,
    round(sum(order_amount),2) as media
from 
	orders, 
    stores, 
    channels, 
    hubs
		where stores.store_id = orders.store_id
		and channels.channel_id = orders.channel_id
		and hubs.hub_id = stores.hub_id
group by hub_state, store_segment, channel_type
having media > 450 -- Having é uma forma de filtro para agregações
order by hub_state;

# 16-Qual  o  valor  total  de  pedido  (order_amount)  por  estado  do  hub  (hub_state), 
-- segmento  da  loja  (store_segment)  e  tipo  de  canal  (channel_type)?  
-- Demonstre  os  totais intermediários e formate o resultado.

select
	if(grouping(hub_state), 'Total Hub State', hub_state) as Hub,
    if(grouping(store_segment), 'Total Segmento', store_segment) as Store,
    if(grouping(channel_type), 'Total Channel', channel_type) as Canal,
    round(sum(order_amount),2) as total_pedido
from orders, stores, channels, hubs
where 
	stores.store_id = orders.store_id and
	channels.channel_id = orders.channel_id and
    hubs.hub_id = stores.hub_id
group by hub_state, store_segment, channel_type with rollup
    

#  17-Quando  o  pedido  era  do  Hub  do  Rio  de  Janeiro  (hub_state),  segmento  de  loja 'FOOD',  tipo  de  canal  Marketplace  e  foi  cancelado,  qual  foi  a  média  de  valor  do  pedido (order_amount)?

select
	hub_state,
    store_segment,
    channel_type,
    round(avg(order_amount),2) as total_pedido
from orders, stores, channels, hubs
where 
	stores.store_id = orders.store_id and
	channels.channel_id = orders.channel_id and
    hubs.hub_id = stores.hub_id and
    hub_city = 'RIO DE JANEIRO' and
    store_segment = 'FOOD' and
    channel_type = 'MARKETPLACE' AND
    order_status = 'CANCELED'
group by 
	hub_state, 
    store_segment, 
    channel_type;
 
# 18-Quando o pedido era do segmento de loja 'GOOD', tipo de canal Marketplace e foi cancelado, algum hub_state teve total de valor do pedido superior a 100.000?

select
	hub_state,
    store_segment,
    channel_type,
    round(avg(order_amount),2) as total_pedido
from orders, stores, channels, hubs
where 
	stores.store_id = orders.store_id and
	channels.channel_id = orders.channel_id and
    hubs.hub_id = stores.hub_id and
    hub_city = 'RIO DE JANEIRO' and
    store_segment = 'FOOD' and
    channel_type = 'MARKETPLACE' AND
    order_status = 'CANCELED'
group by 
	hub_state, 
    store_segment, 
    channel_type;
    
# 19 - Em  que  data  houve  a  maior  média  de  valor  do  pedido  (order_amount)?  Dica: Pesquise e use a função SUBSTRING().

select
	substring(order_moment_created, 1, 9) as data_pedido,
    round(avg(order_amount),2) as media_pedido
from orders
group by data_pedido
order by media_pedido;

# 20-Em quais datas o valor do pedido foi igual a zero (ou seja, não houve venda)? Dica: Use a função SUBSTRING(

select
	substring(order_moment_created, 1, 9) as data_pedido,
    min(order_amount) as min_pedido
from orders
group by data_pedido
having min_pedido = 0
order by data_pedido asc;
