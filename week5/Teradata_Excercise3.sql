#1
SELECT EXTRACT(MONTH FROM saledate) AS m, EXTRACT(YEAR FROM saledate) AS y, 
COUNT(DISTINCT EXTRACT(DAY FROM saledate))
FROM trnsact
GROUP BY y,m
ORDER BY y ASC, m ASC;

#2
#sub:
SELECT sku, amt, EXTRACT(MONTH FROM saledate) AS mth
FROM trnsact
WHERE stype = 'P'
#zeroifnull is an important function to use ZEROIFNULL应当使用，防止有不存在交易额的月份
SELECT s.sku,
SUM(CASE WHEN s.mth = 6 THEN s.amt END) AS Sjune,
SUM(CASE WHEN s.mth = 7 THEN s.amt END) AS Sjuly,
SUM(CASE WHEN s.mth = 8 THEN s.amt END) AS Saugust,
ZEROIFNULL(Sjune)+ZEROIFNULL(Sjuly)+ZEROIFNULL(Saugust) AS all_sum
FROM(
	SELECT sku, amt, EXTRACT(MONTH FROM saledate) AS mth
	FROM trnsact
	WHERE stype = 'P'
) AS s
GROUP BY s.sku
ORDER BY all_sum DESC;

#3
SELECT store, EXTRACT(MONTH FROM saledate) AS m, EXTRACT(YEAR FROM saledate) AS y
FROM trnsact
GROUP BY store, m, y
ORDER BY m ASC, y ASC;

#4
#label shows a unique class label作为一个标记独特年月的方式
SELECT store, m, y, num_day, daily_avg, label
FROM(
	SELECT store,
	EXTRACT(MONTH FROM saledate) AS m,
	EXTRACT(YEAR FROM saledate) AS y,
	COUNT(DISTINCT saledate) AS num_day,
	SUM(amt)/num_day AS daily_avg,
	EXTRACT(YEAR FROM saledate) || EXTRACT(MONTH FROM saledate) AS label
	FROM trnsact
	WHERE stype = 'P'
	GROUP BY store, m, y
	HAVING num_day >= 20 AND label <> '2005 8'
) AS T
ORDER BY T.num_day ASC;

##############5############
#1:USING THE sub in exercise 4 第一个子查询用来得到各商店每日平均，（删去group by m,y）区别是不必进行年月排列了
#2:sub2: get the ranking  第二个子查询用来的到分类
SELECT store,
CASE
	WHEN (msa_high >= 50 AND msa_high <= 60) THEN 'low'
	WHEN(msa_high >=60.01 AND msa_high <= 70) THEN 'medium'
	WHEN(msa_high > 70) THEN 'high'
	ELSE 'very low'
	END
FROM store_msa;
#mistakes: avg 不是上面练习中的按照年月商店分组/不是求各月平均，而是全年各商店
#overall query: 不能将商店平均/商店总和放在第一个sub里面算，因为跳不出store的framework
#::::::wrong:::::::#
#商店/日期杂揉计算了#
SELECT s.ranking, t.avg, t.store
FROM(
	SELECT store,
	COUNT(DISTINCT saledate) AS num_day,
	SUM(num_day) AS all_day,
	SUM(amt) AS totalS,
	totalS/all_day AS avg,
	EXTRACT(YEAR FROM saledate) || EXTRACT(MONTH FROM saledate) AS label
	FROM trnsact
	WHERE stype = 'P'
	GROUP BY store
	HAVING num_day >= 20 AND label <> '2005 8'
) AS t
JOIN
(
	SELECT store,
	CASE
		WHEN (msa_high >= 50 AND msa_high <= 60) THEN 'low'
		WHEN(msa_high >60 AND msa_high <= 70) THEN 'medium'
		WHEN(msa_high > 70) THEN 'high'
		ELSE 'very low'
	END AS ranking
	FROM store_msa
) AS s
ON t.store = s.store
GROUP BY s.ranking
ORDER BY s.ranking DESC;

#:::::correct:::::#
#先在sub里计算每个商店sum，再算每天#
#只分等级即可,等级不可排序#
#去掉多余的属性，比如label#
#where,having, group by操作的顺序，注意先用where清洗数据#

SELECT s.ranking, SUM(t.totalS)/SUM(t.num_day) AS avg_perdayperstore
FROM(
	SELECT store,
	COUNT(DISTINCT saledate) AS num_day, SUM(amt) AS totalS
	FROM trnsact
	WHERE stype = 'P' AND (EXTRACT(YEAR FROM saledate) || EXTRACT(MONTH FROM saledate)) <> '2005 8'
	GROUP BY store
	HAVING num_day >= 20 
) AS t
JOIN
(
	SELECT store,
	CASE
		WHEN (msa_high >= 50 AND msa_high <= 60) THEN 'low'
		WHEN(msa_high >60 AND msa_high <= 70) THEN 'medium'
		WHEN(msa_high > 70) THEN 'high'
		ELSE 'very low'
	END AS ranking
	FROM store_msa
) AS s
ON t.store = s.store
GROUP BY s.ranking;

#6
#6.1compare the two situations: highest median income / lowest median income两种情况的日均值#
SELECT t.store, s1.msa_income, s2.msa_income, s1.state, s1.city,s2.state,s2.city,t.totalS/t.num_day
FROM(
	SELECT store,
	COUNT(DISTINCT saledate) AS num_day, SUM(amt) AS totalS
	FROM trnsact
	WHERE stype = 'P' AND (EXTRACT(YEAR FROM saledate) || EXTRACT(MONTH FROM saledate)) <> '2005 8'
	GROUP BY store
	HAVING num_day >= 20 

) AS t
LEFT JOIN
(
	SELECT store, msa_income,state,city
	FROM(
			SELECT TOP 1 store,msa_income,state,city
			FROM store_msa
			ORDER BY msa_income DESC
		) AS msa1
) AS s1
ON t.store = s1.store
LEFT JOIN(
	SELECT store, msa_income,state,city
	FROM(
			SELECT TOP 1 store,msa_income,state,city
			FROM store_msa
			ORDER BY msa_income ASC
		) AS msa2
) AS s2
ON t.store = s2.store
WHERE s1.msa_income IS NOT NULL OR s2.msa_income IS NOT NULL;

#6.2最高平均值的商店（可以和store_msa表结合求得city和state）#
SELECT TOP 1 store,
COUNT(DISTINCT saledate) AS num_day, SUM(amt) AS totalS
FROM trnsact
WHERE stype = 'P' AND (EXTRACT(YEAR FROM saledate) || EXTRACT(MONTH FROM saledate)) <> '2005 8'
GROUP BY store
HAVING num_day >= 20 
ORDER BY (totalS/num_day);

#7
#sub#
SELECT sku, sku.brand, STDDEV_SAMP(sprice) AS div_price, COUNT(DISTINCT saledate) AS num_trans
FROM trnsact
GROUP BY sku
HAVING num_trans > 100;

#the overall query#
SELECT TOP 1 s.sku, s.brand, t.std 
FROM(
	SELECT sku, STDDEV_SAMP(sprice) AS std, COUNT(DISTINCT saledate) AS num_trans
	FROM trnsact
	GROUP BY sku
	HAVING num_trans > 100
) AS t
JOIN skuinfo AS s
ON s.sku = t.sku
ORDER BY t.std DESC;

#8
#order by can't be used in subquery unless there is a top#
SELECT t.sku, t2.sprice, t.std
FROM(
	SELECT TOP 1 sku, STDDEV_SAMP(sprice) AS std, COUNT(DISTINCT saledate) AS num_trans
	FROM trnsact
	GROUP BY sku
	HAVING num_trans > 100
	ORDER BY std DESC
) AS t
JOIN trnsact AS t2
ON t.sku = t2.sku;

#9
SELECT m, y, num_day, daily_avg, label
FROM(
	SELECT EXTRACT(MONTH FROM saledate) AS m,
	EXTRACT(YEAR FROM saledate) AS y,
	COUNT(DISTINCT saledate) AS num_day,
	SUM(amt)/num_day AS daily_avg,
	EXTRACT(YEAR FROM saledate) || EXTRACT(MONTH FROM saledate) AS label
	FROM trnsact
	WHERE stype = 'P'
	GROUP BY m, y
	HAVING num_day >= 20 AND label <> '2005 8'
) AS T
ORDER BY y ASC;

#10
SELECT d.deptdesc, st.store, st.city, st.state, t2.per_increase
FROM(
	SELECT TOP 1 t.store, t.sku,
	SUM(CASE WHEN t.m = 11 THEN t.num_day END) AS nov_days,
	SUM(CASE WHEN t.m = 12 THEN t.num_day END) AS dec_days,
	SUM(CASE WHEN t.m = 11 THEN t.totalS END) AS nov_sale,
	SUM(CASE WHEN t.m = 12 THEN t.totalS END) AS dec_sale,
	nov_sale / nov_days AS nov_avg,
	dec_sale / dec_days AS dec_avg,
	((dec_avg - nov_avg) / nov_avg ) * 100 AS per_increase
	FROM(
		SELECT store,sku,
		EXTRACT(MONTH FROM saledate) AS m,
		EXTRACT(YEAR FROM saledate) AS y,
		COUNT(DISTINCT saledate) AS num_day,
		SUM(amt) AS totalS
		FROM trnsact
		WHERE stype = 'P'
		GROUP BY store, m, y,sku
		HAVING num_day >= 20 AND m IN (11,12)
		) AS t
	GROUP BY store,sku
	ORDER BY per_increase DESC
) as t2
JOIN strinfo AS st ON st.store = t2.store
JOIN skuinfo AS sku ON sku.sku = t2.sku
JOIN deptinfo AS d ON sku.dept = d.dept;

#11
SELECT st.store, st.city, st.state, t2.per_decrease
FROM(
	SELECT TOP 1 t.store,
	SUM(CASE WHEN t.m = 8 THEN t.num_day END) AS aug_days,
	SUM(CASE WHEN t.m = 9 THEN t.num_day END) AS sep_days,
	SUM(CASE WHEN t.m = 8 THEN t.totalS END) AS aug_sale,
	SUM(CASE WHEN t.m = 9 THEN t.totalS END) AS sep_sale,
	aug_sale / aug_days AS aug_avg,
	sep_sale / sep_days AS sep_avg,
	((sep_avg - aug_avg) / aug_avg ) * 100 AS per_decrease
	FROM(
		SELECT store,
		EXTRACT(MONTH FROM saledate) AS m,
		EXTRACT(YEAR FROM saledate) AS y,
		EXTRACT(MONTH FROM saledate) || EXTRACT(YEAR FROM saledate) AS dmy,
		COUNT(DISTINCT saledate) AS num_day,
		SUM(amt) AS totalS
		FROM trnsact
		WHERE stype = 'P'
		GROUP BY store, m, y
		HAVING num_day >= 20 AND m IN (8,9) AND dmy <> '2005 8'
		) AS t
	GROUP BY store
	ORDER BY per_decrease DESC
) as t2
JOIN strinfo AS st ON st.store = t2.store

#12
#12.1#
#the same as #12.2 : change daily_avg to totalS
#12.2#
SELECT store,
EXTRACT(MONTH FROM saledate) AS m,
EXTRACT(YEAR FROM saledate) AS y,
EXTRACT(MONTH FROM saledate) || EXTRACT(YEAR FROM saledate) AS dmy,
COUNT(DISTINCT saledate) AS num_day,
SUM(amt) AS totalS,
(totalS / num_day) AS daily_avg,
RANK() OVER(PARTITION BY store ORDER BY daily_avg DESC) AS ranking
FROM trnsact
WHERE stype = 'P'
GROUP BY store, m, y
HAVING num_day >= 20 AND dmy <> '2005 8'


SELECT 
EXTRACT(MONTH FROM saledate) AS m,
EXTRACT(YEAR FROM saledate) AS y,
EXTRACT(MONTH FROM saledate) || EXTRACT(YEAR FROM saledate) AS dmy,
COUNT(DISTINCT saledate) AS num_day,
COUNT(DISTINCT store) as num_store,
SUM(amt) AS totalS
FROM trnsact
WHERE stype = 'P'
GROUP BY m, y
HAVING num_day >= 20 AND dmy <> '2005 8'
ORDER BY (totalS/num_day) DESC;

