SELECT sku,retail,cost, COUNT(sku)
FROM skstinfo
GROUP BY sku,retail,cost;

SELECT sku,retail,cost, COUNT(sku), AVG(retail), AVG(cost)
FROM skstinfo
GROUP BY sku,retail,cost;

##excercise1A
SELECT COUNT(DISTINCT sku)
FROM skuinfo;

SELECT COUNT(DISTINCT sku)
FROM skstinfo;

SELECT COUNT(DISTINCT sku)
FROM trnsact;

SELECT sku FROM skuinfo
WHERE skuinfo.sku IS NOT IN
(SELECT sku FROM trnsact);

SELECT sku FROM skuinfo
WHERE skuinfo.sku IS IN 
(SELECT sku FROM skstinfo);


SELECT DISTINCT s.sku AS SKU_S, k.sku AS SKU_K, t.sku AS SKU_T
FROM skuinfo s INNER JOIN skstinfo k ON s.sku=k.sku
INNER JOIN trnsact t ON s.sku=t.sku;

SELECT DISTINCT s.sku AS SKU_S, k.sku AS SKU_K, t.sku AS SKU_T
FROM skuinfo s LEFT JOIN skstinfo k ON s.sku=k.sku
LEFT JOIN trnsact t ON s.sku=t.sku
WHERE SKU_S IS NULL AND SKU_T IS NULL;


##1B
SELECT sku,store, COUNT(*)
FROM skstinfo
GROUP BY sku, store;

SELECT sku,store, COUNT(*)
FROM trnsact
GROUP BY sku, store;

##2a
SELECT COUNT(DISTINCT store)
FROM strinfo;

SELECT COUNT(DISTINCT store)
FROM store_msa;

SELECT COUNT(DISTINCT store)
FROM skstinfo;

SELECT COUNT(DISTINCT store)
FROM trnsact;

##2b
SELECT a.store
FROM strinfo a INNER JOIN skstinfo b ON a.store = b.store
INNER JOIN store_msa c ON b.store = c.store
INNER JOIN trnsact d ON d.store = c.store;

##unique in strinfo PAIR WITH skstinfo
SELECT COUNT(DISTINCT a.store)
FROM strinfo a LEFT JOIN skstinfo b ON a.store = b.store
WHERE b.store IS NULL;

##unique in skstinfo pair with store_msa
SELECT COUNT(DISTINCT a.store)
FROM skstinfo a LEFT JOIN store_msa b ON a.store = b.store
WHERE b.store IS NULL; 

##unique in trnsact pair with skstinfo
SELECT COUNT(DISTINCT a.store)
FROM trnsact a LEFT JOIN skstinfo b ON a.store = b.store
WHERE b.store IS NULL;

#3
SELECT *
FROM trnsact LEFT JOIN skstinfo ON trnsact.sku = skstinfo.sku
WHERE skstinfo.sku IS NULL;

#4
SELECT SUM(t.amt - s.cost)/COUNT(DISTINCT t.saledate) AS AvgProfit
FROM trnsact t JOIN skstinfo s ON t.sku = s.sku AND t.store = s.store
WHERE t.stype = 'P' AND s.cost IS NOT NULL;

#5
SELECT t.saledate, SUM(s.cost) AS Totalcost
FROM trnsact t JOIN skstinfo s ON t.sku = s.sku AND t.store = s.store
WHERE t.stype = 'R'
GROUP BY t.saledate
ORDER BY Totalcost DESC;

SELECT t.saledate, SUM(t.quantity) AS TotalNum
FROM trnsact t JOIN skstinfo s ON t.sku = s.sku AND t.store = s.store
WHERE t.stype = 'R'
GROUP BY t.saledate
ORDER BY TotalNum DESC;

##6
SELECT MAX(sprice) AS maxprice
FROM trnsact;

SELECT MIN(sprice) AS minprice
FROM trnsact;

database ua_dillards
#7
SELECT COUNT(d.dept)
FROM deptinfo d JOIN skuinfo s ON d.dept = s.dept
HAVING COUNT(DISTINCT s.brand) > 100;

SELECT dept, deptdesc
FROM deptinfo
WHERE dept IN(
  SELECT DISTINCT d.dept
  FROM deptinfo d JOIN skuinfo s ON d.dept = s.dept
  GROUP BY d.dept
  HAVING COUNT(DISTINCT s.brand) > 100
);

#8
SELECT skst.sku,d.deptdesc
FROM skstinfo skst JOIN skuinfo sku ON skst.sku = sku.sku
JOIN deptinfo d ON sku.dept = d.dept

#9
SELECT d.dept,d.deptdesc,s.brand,s.style,s.color,SUM(t.amt) AS totalV
FROM deptinfo d JOIN skuinfo s ON d.dept = s.dept
JOIN trnsact t ON t.sku = t.sku
WHERE t.stype = 'R'
GROUP BY d.dept,d.deptdesc,s.brand, s.style, s.color
ORDER BY totalV DESC;

#10
SELECT s.state, s.zip, SUM(t.amt) AS totalR
FROM strinfo s JOIN trnsact t ON s.store = t.store
WHERE t.stype = 'P'
GROUP BY s.state,s.zip
ORDER BY totalR DESC;



