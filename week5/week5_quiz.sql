#2
SELECT COUNT(DISTINCT sku)
FROM skuinfo
WHERE brand = 'Polo fas' AND (size = 'XXL' OR color = 'black');

#3
SELECT s.city,s.state,t.store
FROM(
	SELECT store,
	EXTRACT(MONTH FROM saledate) AS m,
	EXTRACT(YEAR FROM saledate) AS y,
	COUNT(DISTINCT saledate) AS num_day
	FROM trnsact
	GROUP BY store,m,y
) AS t
JOIN strinfo AS s ON t.store = s.store
WHERE t.num_day = 11;

#4
SELECT TOP 1  t.sku,
SUM(CASE WHEN t.m = 11 THEN t.totalS END) AS nov_sale,
SUM(CASE WHEN t.m = 12 THEN t.totalS END) AS dec_sale,
(dec_sale - nov_sale) AS increase
FROM(
	SELECT sku,
	EXTRACT(MONTH FROM saledate) AS m,
	EXTRACT(YEAR FROM saledate) AS y,
	COUNT(DISTINCT saledate) AS num_day,
	SUM(amt) AS totalS
	FROM trnsact
	WHERE stype = 'P'
	GROUP BY m, y,sku
	HAVING num_day >= 20 AND m IN (11,12)
	) AS t
GROUP BY t.sku
ORDER BY increase DESC;

#5
SELECT s.vendor, COUNT(DISTINCT s.sku) AS num_sku
FROM trnsact AS t JOIN skuinfo s ON t.sku = s.sku
LEFT JOIN skstinfo sks ON sks.sku = t.sku 
WHERE sks.sku IS NULL
GROUP BY s.vendor
ORDER BY num_sku DESC;

#6
#should use count(*) to calculate the number of transactions instead of saledate#
#应当使用count(*)而不是count(saledate)来计算交易数目#
SELECT TOP 3 t.sku, s.brand, t.std
FROM(
	SELECT sku, STDDEV_SAMP(sprice) AS std, COUNT(*) AS num_trans
	FROM trnsact
	WHERE stype = 'P'
	GROUP BY sku
	HAVING num_trans > 100
) AS t
JOIN skuinfo AS s
ON t.sku = s.sku
ORDER BY t.std DESC;

#7

SELECT t2.store, s.city, s.state
FROM(
	SELECT TOP 1 t.store,
	SUM(CASE WHEN t.m = 11 THEN totalS END) AS nov_sale,
	SUM(CASE WHEN t.m = 12 THEN totalS END) AS dec_sale,
	SUM(CASE WHEN t.m = 11 THEN num_day END) AS nov_day,
	SUM(CASE WHEN t.m = 12 THEN num_day END) AS dec_day,
	nov_sale / nov_day AS nov_avg,
	dec_sale / dec_day AS dec_avg,
	(dec_avg - nov_avg) AS increase
	FROM(
		SELECT store,
		EXTRACT(MONTH FROM saledate) AS m,
		EXTRACT(YEAR FROM saledate) AS y,
		COUNT(DISTINCT saledate) AS num_day,
		sum(amt) AS totalS
		FROM trnsact
		WHERE stype = 'P'
		GROUP BY store,m,y
		HAVING num_day >= 20 AND m IN (11,12)
	) AS t
	GROUP BY store
	ORDER BY increase DESC
) AS t2
JOIN store_msa AS s
ON t2.store = s.store;

#8
SELECT msa_income,store,state,city
FROM store_msa
ORDER BY msa_income DESC;

#9
SELECT
CASE 
	WHEN s.msa_income >= 1 AND s.msa_income < 20000 THEN 'low' 
	WHEN s.msa_income >= 20000 AND s.msa_income < 30000 THEN 'med-low'
	WHEN s.msa_income >= 30001 AND s.msa_income < 40000 THEN 'med-high' 
	WHEN s.msa_income >= 40000 THEN 'high' END AS ranking,
SUM(t.totalS)/SUM(t.num_day) AS daily_avg
FROM(
	SELECT store,
	EXTRACT(MONTH FROM saledate) AS m,
	EXTRACT(YEAR FROM saledate) AS y,
	SUM(amt) AS totalS,
	COUNT(DISTINCT saledate) AS num_day,
	EXTRACT(MONTH FROM saledate) || EXTRACT(YEAR FROM saledate) AS dmy
	FROM trnsact
	WHERE stype = 'P'
	GROUP BY store, m,y
	HAVING num_day >= 20 AND dmy <> '2005 8'
) AS t
JOIN store_msa s ON s.store = t.store
GROUP BY ranking
ORDER BY daily_avg DESC;

#10
SELECT
CASE 
	WHEN s.msa_pop > 0 AND s.msa_pop <= 100000 THEN 'very small' 
	WHEN s.msa_pop > 100000 AND s.msa_pop <= 200000 THEN 'small'
	WHEN s.msa_pop > 200000 AND s.msa_pop <= 500000 THEN 'med-small' 
	WHEN s.msa_pop > 500000 AND s.msa_pop <= 1000000 THEN 'med-large' 
	WHEN s.msa_pop > 1000000 AND s.msa_pop <= 5000000 THEN 'large'
	WHEN s.msa_pop > 5000000 THEN 'very large'
	END AS ranking,
SUM(t.totalS)/SUM(t.num_day) AS daily_avg
FROM(
	SELECT store,
	EXTRACT(MONTH FROM saledate) AS m,
	EXTRACT(YEAR FROM saledate) AS y,
	SUM(amt) AS totalS,
	COUNT(DISTINCT saledate) AS num_day,
	EXTRACT(MONTH FROM saledate) || EXTRACT(YEAR FROM saledate) AS dmy
	FROM trnsact
	WHERE stype = 'P'
	GROUP BY store, m,y
	HAVING num_day >= 20 AND dmy <> '2005 8'
) AS t
JOIN store_msa s ON s.store = t.store
GROUP BY ranking
ORDER BY daily_avg DESC;

#11
#easy way out: not necessary to join the tables
#因为是选择题，只Join了store_msa表
#未能得到正确答案，可能是Pine Bluff,AR
SELECT t2.store, s.city, s.state
FROM(
	SELECT TOP 1 t.store,
	SUM(CASE WHEN t.m = 11 THEN totalS END) AS nov_sale,
	SUM(CASE WHEN t.m = 12 THEN totalS END) AS dec_sale,
	SUM(CASE WHEN t.m = 11 THEN num_day END) AS nov_day,
	SUM(CASE WHEN t.m = 12 THEN num_day END) AS dec_day,
	nov_sale / nov_day AS nov_avg,
	dec_sale / dec_day AS dec_avg,
	(dec_avg - nov_avg) / nov_avg AS per_increase
	FROM(
		SELECT store,
		EXTRACT(MONTH FROM saledate) AS m,
		EXTRACT(YEAR FROM saledate) AS y,
		COUNT(DISTINCT saledate) AS num_day,
		sum(amt) AS totalS
		FROM trnsact
		WHERE stype = 'P'
		GROUP BY store,m,y
		HAVING num_day >= 20 AND m IN (11,12)
	) AS t
	HAVING nov_day >= 1000 AND dec_day >= 1000
	GROUP BY store
	ORDER BY per_increase DESC
) AS t2
JOIN store_msa AS s
ON t2.store = s.store;

#12
#注意对表的重命名/decrease 可能不存在
SELECT deptinfo.deptdesc, t2.dept, st.store, st.city, st.state, t2.decrease
FROM(
	SELECT t.store, t.dept, 
	SUM(CASE WHEN t.m = 8 THEN t.num_day END) AS aug_days,
	SUM(CASE WHEN t.m = 9 THEN t.num_day END) AS sep_days,
	SUM(CASE WHEN t.m = 8 THEN t.totalS END) AS aug_sale,
	SUM(CASE WHEN t.m = 9 THEN t.totalS END) AS sep_sale,
	aug_sale / aug_days AS aug_avg,
	sep_sale / sep_days AS sep_avg,
	(sep_avg - aug_avg)  AS decrease
	FROM(
		SELECT tr.store, d.dept,
		EXTRACT(MONTH FROM saledate) AS m,
		EXTRACT(YEAR FROM saledate) AS y,
		COUNT(DISTINCT saledate) AS num_day,
		SUM(amt) AS totalS
		FROM trnsact tr 
		JOIN skuinfo sku ON tr.sku = sku.sku
		JOIN deptinfo d ON d.dept = sku.dept
		WHERE stype = 'P'
		GROUP BY store, m, y, d.dept
		HAVING num_day >= 20 AND m IN (8,9) AND y <> 2005
		) AS t
	GROUP BY t.store, t.dept
) as t2
JOIN store_msa AS st ON st.store = t2.store
WHERE t2.decrease IS NOT NULL
ORDER BY t2.decrease ASC;

#13
#:::OK SOLUTION:::#
SELECT deptinfo.deptdesc, t2.dept, st.store, st.city, st.state, t2.decrease
FROM(
	SELECT t.store, t.dept, 
	SUM(CASE WHEN t.m = 8 THEN t.num_items END) AS aug_item,
	SUM(CASE WHEN t.m = 9 THEN t.num_items END) AS sep_item,
	(sep_item - aug_item)  AS decrease
	FROM(
		SELECT tr.store, d.dept,
		EXTRACT(MONTH FROM saledate) AS m,
		EXTRACT(YEAR FROM saledate) AS y,
		COUNT(DISTINCT saledate) AS num_day,
		SUM(quantity) AS num_items
		FROM trnsact tr 
		JOIN skuinfo sku ON tr.sku = sku.sku
		JOIN deptinfo d ON d.dept = sku.dept
		WHERE stype = 'P'
		GROUP BY store, m, y, d.dept
		HAVING num_day >= 20 AND m IN (8,9) AND y <> 2005
		) AS t
	GROUP BY t.store, t.dept
) as t2
JOIN store_msa AS st ON st.store = t2.store
WHERE t2.decrease IS NOT NULL
ORDER BY t2.decrease ASC;

#:::::RECOMMENDED:::::#
SELECT T2.store, T2.dept, deptinfo.deptdesc, msa.city, msa.state, T2.change
FROM (
	SELECT T.store, T.dept,
		SUM(CASE WHEN T.dm=8 THEN T.num_items END) AS aug_day_sum,
		SUM(CASE WHEN T.dm=9 THEN T.num_items END) AS sept_day_sum,
		aug_day_sum - sept_day_sum AS change
	FROM (
		SELECT store, skuinfo.dept,
			EXTRACT(MONTH FROM saledate) AS dm, 
			EXTRACT (YEAR FROM saledate) AS dy, 
			COUNT(DISTINCT saledate) AS num_days, 
			SUM(quantity) AS num_items
		FROM trnsact
		JOIN skuinfo
		ON trnsact.sku = skuinfo.sku  
		WHERE stype = 'P'
		GROUP BY store, dept, dm, dy
		HAVING num_days >= 20 AND dm IN (8,9) AND dy <> 2005) AS T
	GROUP BY T.store, T.dept) AS T2
JOIN store_msa AS msa
ON T2.store = msa.store
JOIN deptinfo
ON T2.dept = deptinfo.dept
WHERE T2.change IS NOT NULL
ORDER BY T2.change DESC;

#14
#FIND the MIN average daily, so use ASC#
#寻找每个商店最低平均销售额的月份，哪些月份有超过100家商店都在该月达到最低销售额#
SELECT t.m, COUNT(DISTINCT store)
FROM(
	SELECT store,
	EXTRACT(MONTH FROM saledate) AS m,
	EXTRACT(YEAR FROM saledate) AS y,
	COUNT(DISTINCT saledate) AS num_day,
	SUM(amt) AS totalS,
	totalS / num_day AS daily_avg,
	EXTRACT(MONTH FROM saledate) || EXTRACT(YEAR FROM saledate) AS label,
	RANK() OVER(PARTITION BY store ORDER BY daily_avg ASC) AS ranking
	FROM trnsact
	WHERE stype = 'P'
	GROUP BY store, m, y
	HAVING num_day >= 20 AND label <> '2005 8'
) as t
WHERE t.ranking = 1
GROUP BY t.m;

#15
SELECT t.m, COUNT(DISTINCT store)
FROM(
	SELECT store,
	EXTRACT(MONTH FROM saledate) AS m,
	EXTRACT(YEAR FROM saledate) AS y,
	COUNT(DISTINCT saledate) AS num_day,
	SUM(quantity) AS totalReturn,
	EXTRACT(MONTH FROM saledate) || EXTRACT(YEAR FROM saledate) AS label,
	RANK() OVER(PARTITION BY store ORDER BY totalReturn DESC) AS ranking
	FROM trnsact
	WHERE stype = 'R'
	GROUP BY store, m, y
	HAVING num_day >= 20 AND label <> '2005 8'
) as t
WHERE t.ranking = 1
GROUP BY t.m;


