use olist_project;
SELECT COUNT(*) AS total_customer_ids, COUNT(DISTINCT customer_unique_id) AS real_customers FROM customers;
CREATE OR REPLACE VIEW sales_clean AS
SELECT o.order_id, oi.order_item_id, DATE(o.order_purchase_timestamp) AS order_date, o.order_status,
  c.customer_unique_id, c.customer_city, c.customer_state,
  oi.product_id, COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
  oi.seller_id, oi.price, oi.freight_value, (oi.price + oi.freight_value) AS total_value,
  DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp) AS delivery_days,
  CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END AS is_late,
  r.review_score
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN products p ON oi.product_id = p.product_id
LEFT JOIN product_category_translation t ON p.product_category_name = t.product_category_name
LEFT JOIN (SELECT order_id, AVG(review_score) AS review_score FROM order_reviews GROUP BY order_id) r ON o.order_id = r.order_id;
SELECT category, ROUND(SUM(price)) AS revenue FROM sales_clean WHERE order_status = 'delivered' GROUP BY category ORDER BY revenue DESC LIMIT 5;