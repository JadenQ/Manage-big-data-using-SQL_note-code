#3
SELECT saledate, SUM(amt) AS totalP
FROM trnsact
WHERE stype = 'P'
GROUP BY saledate
ORDER BY totalP DESC;

#4
SELECT d.dept, d.deptdesc, COUNT(DISTINCT s.sku) AS totalSKU
FROM deptinfo d JOIN skuinfo s ON d.dept = s.dept
GROUP BY d.dept, d.deptdesc
ORDER BY totalSKU DESC;

#5
SELECT COUNT(DISTINCT sku)
FROM trnsact;

SELECT COUNT(DISTINCT sku)
FROM skstinfo;

SELECT COUNT(DISTINCT sku)
FROM skuinfo;

#6
SELECT COUNT(DISTINCT s.sku)
FROM skstinfo s LEFT JOIN skuinfo sku ON s.sku = sku.sku
WHERE sku.sku IS NULL;

#7
SELECT SUM(t.amt - s.cost)/COUNT(DISTINCT t.saledate) AS AvgProfit
FROM trnsact t JOIN skstinfo s ON t.sku = s.sku AND t.store = s.store
WHERE t.stype = 'P';

#8
SELECT COUNT(msa),MIN(msa_pop),MAX(msa_income)
FROM store_msa
WHERE state = 'NC';

#9
SELECT d.dept, d.deptdesc, sk.brand, sk.style, sk.color, SUM(t.amt) AS totalSale
FROM deptinfo d JOIN skuinfo sk ON d.dept = sk.dept
JOIN trnsact t ON t.sku = sk.sku
WHERE t.stype = 'P'
GROUP BY d.dept, d.deptdesc, sk.brand, sk.style, sk.color
ORDER BY totalSale DESC;

#10
SELECT COUNT(DISTINCT store)
FROM skstinfo
WHERE store IN(
 SELECT DISTINCT store
 FROM skstinfo
 GROUP BY store
 HAVING COUNT(DISTINCT sku) > 180000
);

#11
SELECT  *
FROM skuinfo s JOIN deptinfo d ON s.dept = d.dept
WHERE d.deptdesc = 'cop' AND s.brand = 'federal' AND s.color = 'rinse wash';

#12
SELECT COUNT(DISTINCT sku.sku)
FROM skuinfo sku LEFT JOIN skstinfo s ON sku.sku = s.sku
WHERE s.sku IS NULL;

#13
SELECT s.city,s.state, s.store, SUM(t.amt) AS totalS
FROM trnsact t JOIN strinfo s ON s.store = t.store
GROUP BY s.city,s.state,s.store
ORDER BY totalS DESC;

#15
SELECT COUNT(DISTINCT state)
FROM strinfo
WHERE state IN(
 SELECT state
 FROM strinfo
 GROUP BY state
 HAVING COUNT(DISTINCT store) > 10
)

#16
SELECT sks.retail,sks.sku,sku.brand,sku.color,d.deptdesc
FROM skstinfo sks JOIN skuinfo sku ON sks.sku = sku.sku 
JOIN deptinfo d ON sku.dept = d.dept
WHERE d.deptdesc = 'reebok' AND sku.brand = 'skechers' AND sku.color = 'wht/saphire';