1. Have you completed the week 2 Teradata practice exercises guide?
   
   Yes
2. Which of the following keywords are required in any query to retrieve data from a relational database?
   
   FROM

3. Which of the following database systems recognize the keyword “LIMIT” to limit the number of rows displayed from a query output?
   
   MySQL

4. Which keywords could you use to determine the names of the columns contained in a table?
   
   DESCRIBE in MySQL and HELP in Teradata

5. In how many columns of the STRINFO table of the Dillard’s database are NULL values *permitted*?
   
   3
   ```sql
   HELP TABLE strinfo;
   ```

6. In how many columns of the STRINFO table of the Dillard’s database are NULL values *present*?
   
   0
    ```sql
    SELECT *
    FROM strinfo
    WHERE CITY IS NULL;
    SELECT *
    FROM strinfo
    WHERE state IS NULL;
    SELECT *
    FROM strinfo
    WHERE zip IS NULL;
    ```

7. What was the highest original price in the Dillard’s database of the item with SKU 3631365?
   
    17.5
    ```sql
    SELECT TOP 1 orgprice 
    FROM trnsact
    WHERE sku = 3631365
    ORDER BY orgprice DESC;
    ```

8. What is the color of the Liz Claiborne brand item with the highest SKU # in the Dillard’s database (the Liz Claiborne brand is abbreviated “LIZ CLAI” in the Dillard’s database)?
   
    TEAK CBO
    ```sql
    SELECT TOP 10 color, sku
    FROM skuinfo
    WHERE brand = 'LIZ CLAI'
    ORDER BY sku DESC
    ```

9.  What aspect of the following query will make the query crash?
    There is a comma after "amt" in the first line of the query

    There is a comma after "amt" in the first line of the query

10. What is the sku number of the item in the Dillard’s database that had the highest original sales price?
    
    6200173
    ```sql
    SELECT TOP 10 sku, orgprice
    FROM trnsact
    ORDER BY orgprice DESC
    ```

11. According to the strinfo table, in how many states within the United States are Dillard’s stores located? (HINT: the bottom of the SQL scratchpad reports the number of rows in your output)

    31
    ```sql
    SELECT DISTINCT state
    FROM strinfo
    ```
12. How many Dillard’s departments start with the letter “e”
    
    5
    ```sql 
    SELECT deptdesc
    FROM deptinfo
    WHERE deptdesc LIKE ('e%')
    ```

13. What was the date of the earliest sale in the database where the sale price of the item did not equal the original price of the item, and what was the largest margin (original price minus sale price) of an item sold on that earliest date?