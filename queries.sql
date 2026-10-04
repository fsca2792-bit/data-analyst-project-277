-- Cuenta el número total de clientes en la tabla customers
SELECT COUNT(*) AS customers_count
FROM customers;

-- Reporte 1: Top 10 vendedores con mayor ingreso total
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    COUNT(s.sales_id) AS operations,
    FLOOR(SUM(p.price * s.quantity)) AS income
FROM employees e
JOIN sales s ON e.employee_id = s.sales_person_id
JOIN products p ON s.product_id = p.product_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY income DESC
LIMIT 10;

-- Reporte 2: Vendedores con ingreso promedio por venta menor al promedio general
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    FLOOR(AVG(p.price * s.quantity)) AS average_income
FROM employees e
JOIN sales s ON e.employee_id = s.sales_person_id
JOIN products p ON s.product_id = p.product_id
GROUP BY e.employee_id, e.first_name, e.last_name
HAVING AVG(p.price * s.quantity) < (
    SELECT AVG(p2.price * s2.quantity) 
    FROM sales s2 
    JOIN products p2 ON s2.product_id = p2.product_id
)
ORDER BY average_income ASC;

-- Reporte 3: Ingresos totales por día de la semana para cada vendedor
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS seller,
    TRIM(LOWER(TO_CHAR(s.sale_date, 'Day'))) AS day_of_week,
    FLOOR(SUM(p.price * s.quantity)) AS income
FROM employees e
JOIN sales s ON e.employee_id = s.sales_person_id
JOIN products p ON s.product_id = p.product_id
GROUP BY e.employee_id, e.first_name, e.last_name, EXTRACT(DOW FROM s.sale_date), TRIM(LOWER(TO_CHAR(s.sale_date, 'Day')))
ORDER BY EXTRACT(DOW FROM s.sale_date) ASC, seller ASC;

-- Reporte 4: Conteo de clientes divididos por rango de edad
SELECT 
    CASE 
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+'
    END AS age_category,
    COUNT(*) AS age_count
FROM customers
GROUP BY age_category
ORDER BY age_category ASC;

-- Reporte 5: Clientes únicos e ingresos totales agrupados por año y mes
SELECT 
    TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    FLOOR(SUM(p.price * s.quantity)) AS income
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM')
ORDER BY selling_month ASC;

-- Reporte 6: Clientes cuya primera compra tuvo precio igual a 0 (oferta especial)
WITH first_sales AS (
    SELECT 
        s.customer_id,
        s.sale_date,
        s.sales_person_id,
        p.price,
        ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.sale_date ASC, s.sales_id ASC) AS rn
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
)
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    fs.sale_date,
    CONCAT(e.first_name, ' ', e.last_name) AS seller
FROM first_sales fs
JOIN customers c ON fs.customer_id = c.customer_id
JOIN employees e ON fs.sales_person_id = e.employee_id
WHERE fs.rn = 1 AND fs.price = 0
ORDER BY fs.customer_id ASC;
