# [SQL] [Exercice] SQL for Data Analysis

Este repositório surge da minha necessidade em organizar instruções que eu não uso no meu dia a dia de trabalho, mas que podem ser úteis em algum momento. 
A maior parte deste material é proveniente do curso **SQL Para Data Science** da [DSA Academy](https://www.datascienceacademy.com.br/). Para sintetixar as instruções, busquei mais informações na [documentação SQL](https://docs.microsoft.com/pt-br/sql/t-sql/) e no [W3 Schools](https://www.w3schools.com/).

# SQL Statements

Nesta seção do repositório vamos reunir sintaxes de algumas instruções do SQL.

## Instruções usadas no exercício 04

1. **Having**

A proposta do HAVING é permitir o retorno de linhas onde os valores agregados atendem às condições especificadas. 
A instrução foi adicionada ao SQL para facilitar o filtro com agregações, visto que o WHERE não pode ser usado nesses casos.

```
SELECT
	metodo,
  pgto_total
FROM vw_media_pagamento
GROUP BY 1
HAVING pgto_total > 100;

```

2. **Grouping**

A instrução GROUPING é usada para distinguir os valores nulos retornados por ROLLUP, CUBE ou GROUPING SETS. 
Cabe notar que o NULL do GROUPING é um valor especial e, por isso, utilizar CASE não seria o ideal.


```
SELECT 
	IF(GROUPING(dr.driver_type), 'Total Entregas Realizadas', dr.driver_type) as Tipo,
  COUNT(de.driver_id) as entregas_completas 
FROM drivers as dr
LEFT JOIN deliveries as de
USING (driver_id)
WHERE de.delivery_status in ('Delivered')
GROUP BY dr.driver_type with rollup
ORDER BY GROUPING(dr.driver_type);
```

3. Cube

```

```

4. Roll Up

```
SELECT 
	IF(GROUPING(dr.driver_type), 'Total Entregas Realizadas', dr.driver_type) as Tipo,
  COUNT(de.driver_id) as entregas_completas 
FROM drivers as dr
LEFT JOIN deliveries as de
USING (driver_id)
WHERE de.delivery_status in ('Delivered')
GROUP BY dr.driver_type with rollup
ORDER BY grouping(dr.driver_type);
```

5. Coalesce

```
SELECT
	coalesce(store_name, 'Sem Loja'),
  count(order_id) as contagem
FROM orders
LEFT JOIN stores
USING (store_id)
GROUP BY store_name
ORDER BY contagem desc;
```
