CREATE DATABASE IF NOT EXISTS chainForge;
USE chainForge;
DROP TABLE IF EXISTS supplychain;

CREATE TABLE supplychain (
    Order_Item_Id               INT,
    Customer_Id                 INT,
    Type                        VARCHAR(50),
    Days_for_shipping_real      INT,
    Days_for_shipment_scheduled INT,
    Benefit_per_order           DECIMAL(10,2),
    Sales_per_customer          DECIMAL(10,2),
    Delivery_Status             VARCHAR(100),
    Late_delivery_risk          TINYINT(1),
    Category_Name               VARCHAR(100),
    Customer_City               VARCHAR(100),
    Customer_Country            VARCHAR(100),
    Customer_Segment            VARCHAR(50),
    Customer_State              VARCHAR(100),
    Department_Name             VARCHAR(100),
    Market                      VARCHAR(50),
    Order_City                  VARCHAR(100),
    Order_Country               VARCHAR(100),
    Order_Customer_Id           INT,
    order_date                  DATE,
    Order_Id                    INT,
    Order_Item_Cardprod_Id      INT,
    Order_Item_Discount         DECIMAL(10,2),
    Order_Item_Discount_Rate    DECIMAL(5,4),
    Order_Item_Product_Price    DECIMAL(10,2),
    Order_Item_Profit_Ratio     DECIMAL(5,4),
    Order_Item_Quantity         INT,
    Sales                       DECIMAL(10,2),
    Order_Item_Total            DECIMAL(10,2),
    Order_Profit_Per_Order      DECIMAL(10,2),
    Order_Region                VARCHAR(100),
    Order_State                 VARCHAR(100),
    Order_Status                VARCHAR(50),
    Product_Category_Id         INT,
    Product_Name                VARCHAR(200),
    Product_Price               DECIMAL(10,2),
    shipping_date               DATE,
    Shipping_Mode               VARCHAR(50),
    Customer_Name               VARCHAR(150)
);

SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';
-- Should show: ON

LOAD DATA LOCAL INFILE '/Users/bhoomi/Documents/GitHub/ChainForge/supplychain_final.csv'
INTO TABLE supplychain
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) AS total_rows FROM supplychain;
SELECT * FROM supplychain LIMIT 5;


------------------------- Executive Dashboard -------------------------
-- Power BI shows: $4.29M
SELECT 
    ROUND(SUM(Sales), 2) AS total_revenue
FROM supplychain;

-- Power BI shows: 21K
SELECT 
    COUNT(*) AS total_orders
FROM supplychain;

-- Power BI shows: 54.52%
SELECT 
    CONCAT(ROUND(
        100.0 * COUNT(CASE WHEN Delivery_Status = 'Late delivery' THEN 1 END) / COUNT(*), 2
    ),'%') AS late_delivery_rate_pct
FROM supplychain;

-- Power BI shows: 469K
SELECT 
    ROUND(SUM(Order_Profit_Per_Order), 2) AS total_profit
FROM supplychain;

-- Power BI donut chart
SELECT 
    Delivery_Status,
    COUNT(*) AS total_orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS pct
FROM supplychain
GROUP BY Delivery_Status
ORDER BY total_orders DESC;



------------------------- Sales & Revenue -------------------------
-- Avg Order Value
SELECT
    ROUND(SUM(Sales) / COUNT(*), 2) AS Avg_Order_Value
FROM supplychain;

-- Cumulative Revenue YTD per year
SELECT
    YEAR(order_date)                    AS Year,
    MONTH(order_date)                   AS Month,
    ROUND(SUM(Sales), 2)                AS Monthly_Revenue,
    ROUND(SUM(SUM(Sales)) OVER (
        PARTITION BY YEAR(order_date)
        ORDER BY MONTH(order_date)
    ), 2)                               AS Cumulative_YTD
FROM supplychain
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY Year, Month;

-- Total Discount Given
SELECT
    ROUND(SUM(Order_Item_Quantity * Order_Item_Discount), 2) AS Total_Discount_Given
FROM supplychain;

-- Power BI shows: Europe 1.27M, LATAM 1.20M
SELECT 
    Market,
    ROUND(SUM(Sales), 2) AS total_revenue,
    ROUND(100.0 * SUM(Sales) / SUM(SUM(Sales)) OVER(), 2) AS market_share_pct
FROM supplychain
GROUP BY Market
ORDER BY total_revenue DESC;



------------------------- Delivery performance ------------------------- 
-- On Time Rate
SELECT
    ROUND(
        100.0 * COUNT(CASE WHEN Delivery_Status = 'Shipping on time' THEN 1 END)
        / COUNT(*), 2
    ) AS On_Time_Rate_Pct
FROM supplychain;

-- Avg Delay Days
SELECT
    ROUND(
        AVG(Days_for_shipping_real - Days_for_shipment_scheduled), 0
    ) AS Avg_Delay_Days
FROM supplychain
WHERE Delivery_Status = 'Late delivery';

-- Shipping Efficiency Overall %
SELECT
    ROUND(
        100.0 * AVG(Days_for_shipment_scheduled) 
        / NULLIF(AVG(Days_for_shipping_real), 0), 2
    ) AS Shipping_Efficiency_Pct
FROM supplychain;

-- Cancelled Orders Overall %
SELECT
    ROUND(
        100.0 * COUNT(CASE WHEN Delivery_Status = 'Shipping canceled' THEN 1 END)
        / COUNT(*), 2
    ) AS Cancelled_Orders_Pct
FROM supplychain;

-- Power BI shows: Standard Class highest
SELECT 
    Shipping_Mode,
    SUM(Late_delivery_risk) AS late_delivery_risk_total,
    ROUND(100.0 * SUM(Late_delivery_risk) / COUNT(*), 2) AS late_rate_pct
FROM supplychain
GROUP BY Shipping_Mode
ORDER BY late_delivery_risk_total DESC;


------------------------- Customer Analysis -------------------------
-- Power BI shows: 7K
SELECT 
    COUNT(DISTINCT Customer_Name) AS unique_customers
FROM supplychain;

-- Power BI shows: $601.12
SELECT 
    ROUND(SUM(Sales) / COUNT(DISTINCT Customer_Name), 2) AS revenue_per_customer
FROM supplychain;

-- Repeat Customers (customers with more than 1 order)
SELECT
    COUNT(*) AS Repeat_Customers
FROM (
    SELECT Customer_Name
    FROM supplychain
    GROUP BY Customer_Name
    HAVING COUNT(*) > 1
) AS repeated;

-- Repeat Customer Rate
SELECT
    ROUND(
        100.0 * COUNT(CASE WHEN order_count > 1 THEN 1 END)
        / COUNT(*), 2
    ) AS Repeat_Customer_Rate_Pct
FROM (
    SELECT 
        Customer_Name,
        COUNT(*) AS order_count
    FROM supplychain
    GROUP BY Customer_Name
) AS customer_orders;

-- Power BI shows: Consumer 2.23M, Corporate 1.31M, Home Office 0.75M
SELECT 
    Customer_Segment,
    ROUND(SUM(Sales), 2) AS total_revenue
FROM supplychain
GROUP BY Customer_Segment
ORDER BY total_revenue DESC;


------------------------- Product Analysis -------------------------
-- Power BI shows: 117
SELECT 
    COUNT(DISTINCT Product_Name) AS total_products
FROM supplychain;

-- Power BI shows: $979.43K
SELECT 
    ROUND(SUM(Order_Item_Quantity * Order_Item_Discount), 2) AS total_discount
FROM supplychain;

-- Avg Product Price
SELECT
    ROUND(AVG(Product_Price), 2) AS Avg_Product_Price
FROM supplychain;

-- Profit Per Product
SELECT
    ROUND(
        SUM(Order_Profit_Per_Order) 
        / NULLIF(COUNT(DISTINCT Product_Name), 0), 2
    ) AS Profit_Per_Product
FROM supplychain;

-- Discount Impact %
SELECT
    ROUND(
        100.0 * SUM(Order_Item_Quantity * Order_Item_Discount)
        / NULLIF(SUM(Sales), 0), 2
    ) AS Discount_Impact_Pct
FROM supplychain;

-- Power BI shows: Field & Stream $798K top
SELECT 
    Product_Name,
    ROUND(SUM(Sales), 2) AS total_sales,
    ROUND(SUM(Order_Profit_Per_Order), 2) AS total_profit
FROM supplychain
GROUP BY Product_Name
ORDER BY total_profit DESC
LIMIT 10;