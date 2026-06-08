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