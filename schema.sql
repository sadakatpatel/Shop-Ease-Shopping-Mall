CREATE DATABASE IF NOT EXISTS shopease_db;
USE shopease_db;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(80) UNIQUE NOT NULL,
  icon VARCHAR(20) DEFAULT 'fa-box'
);

CREATE TABLE IF NOT EXISTS products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(180) NOT NULL,
  brand VARCHAR(100),
  category VARCHAR(80) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  old_price DECIMAL(10,2) DEFAULT NULL,
  discount INT DEFAULT 0,
  rating DECIMAL(2,1) DEFAULT 4.2,
  reviews INT DEFAULT 0,
  stock INT DEFAULT 50,
  image VARCHAR(500),
  badge VARCHAR(30),
  description TEXT,
  featured TINYINT(1) DEFAULT 0,
  trending TINYINT(1) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  status VARCHAR(40) DEFAULT 'Placed',
  address VARCHAR(255) NOT NULL,
  city VARCHAR(80) NOT NULL,
  state VARCHAR(80) NOT NULL,
  pincode VARCHAR(10) NOT NULL,
  payment_method VARCHAR(40) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS order_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id)
);

INSERT IGNORE INTO categories(name,icon) VALUES
('Men''s Clothing','fa-person'),('Women''s Clothing','fa-person-dress'),('Baby Clothing','fa-baby'),('Kids'' Clothing','fa-child'),('Teen Clothing','fa-user-graduate'),('Ethnic Wear','fa-shirt'),('Korean Fashion','fa-star'),('Western Wear','fa-person-dress'),('Streetwear','fa-shoe-prints');

INSERT INTO products(name,brand,category,price,old_price,discount,rating,reviews,stock,image,badge,description,featured,trending) VALUES
('Men''s Classic Oxford Shirt','Urban Thread','Men''s Clothing',1199,1599,25,4.4,320,45,'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?auto=format&fit=crop&w=700&q=80','Everyday Style','A comfortable classic-fit Oxford shirt for workdays and weekends.',1,1),
('Women''s Floral Midi Dress','StyleHub','Women''s Clothing',1499,1999,25,4.6,410,35,'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=700&q=80','New Season','A breezy floral midi dress made for sunny days and easy outings.',1,1),
('Men''s Slim Fit Jeans','Denim Co.','Men''s Clothing',1799,2499,28,4.3,275,50,'https://images.unsplash.com/photo-1542272604-787c3835535d?auto=format&fit=crop&w=700&q=80','Best Seller','Stretch denim jeans with a clean slim fit for everyday wear.',1,1),
('Women''s Everyday Kurti','Aarvi','Ethnic Wear',999,1399,29,4.5,360,40,'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=700&q=80','Popular','An easy-to-style everyday kurti with a comfortable silhouette.',1,1),
('Men''s Cotton T-Shirt','North Lane','Men''s Clothing',599,799,25,4.2,190,70,'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=700&q=80','Deal','Soft breathable cotton T-shirt for daily comfort.',1,1),
('Men''s Casual Hoodie','Urban Thread','Men''s Clothing',1599,2199,27,4.5,230,28,'https://images.unsplash.com/photo-1556821840-3a63f95609a7?auto=format&fit=crop&w=700&q=80','Trending','A cosy pullover hoodie for cool mornings and relaxed evenings.',0,1),
('Women''s Straight Fit Jeans','StyleHub','Women''s Clothing',1699,2299,26,4.4,305,38,'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?auto=format&fit=crop&w=700&q=80','Deal','Versatile straight-fit denim designed for everyday outfits.',0,1),
('Kids'' Graphic T-Shirt','Little Loom','Kids'' Clothing',499,699,29,4.3,145,55,'https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?auto=format&fit=crop&w=700&q=80','Kids Favourite','A soft playful graphic tee made for all-day movement.',0,1),
('Women''s Casual Top','StyleHub','Women''s Clothing',899,1199,25,4.3,215,42,'https://images.unsplash.com/photo-1551163943-3f6a855d1153?auto=format&fit=crop&w=700&q=80','New Arrival','A versatile casual top that pairs easily with jeans or skirts.',0,1),
('Kids'' Everyday Dress','Little Loom','Kids'' Clothing',799,1099,27,4.5,175,30,'https://images.unsplash.com/photo-1503919005314-30d93d07d823?auto=format&fit=crop&w=700&q=80','Deal','A comfortable everyday dress for playtime and family outings.',0,1),
('Baby Cotton Onesie Set','Tiny Steps','Baby Clothing',699,999,30,4.7,88,35,'https://images.unsplash.com/photo-1519689680058-324335c77eba?auto=format&fit=crop&w=700&q=80','Soft Cotton','A gentle cotton onesie set for everyday baby comfort.',0,1),
('Baby Printed Romper','Tiny Steps','Baby Clothing',549,799,31,4.5,64,28,'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=700&q=80','Cute Pick','An easy-change printed romper for little ones.',0,1),
('Baby Cozy Sleepsuit','Little Cloud','Baby Clothing',799,1099,27,4.6,73,22,'https://images.unsplash.com/photo-1519689680058-324335c77eba?auto=format&fit=crop&w=700&q=80','Cozy','A soft full-length sleepsuit made for cozy naps and nights.',0,1),
('Baby Everyday Dress','Tiny Steps','Baby Clothing',649,899,28,4.4,52,26,'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=700&q=80','New','A lightweight everyday dress for baby girls.',0,1),
('Kids Colorblock Hoodie','Little Loom','Kids'' Clothing',899,1299,31,4.5,94,32,'https://images.unsplash.com/photo-1556821840-3a63f95609a7?auto=format&fit=crop&w=700&q=80','Play Ready','A warm colorblock hoodie for school days and weekends.',0,1),
('Kids Denim Dungarees','Little Loom','Kids'' Clothing',1099,1499,27,4.4,82,24,'https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?auto=format&fit=crop&w=700&q=80','Everyday','Easy-to-layer denim dungarees for active little explorers.',0,1),
('Kids Cotton Kurta Set','Aarvi Junior','Kids'' Clothing',999,1399,29,4.6,105,20,'https://images.unsplash.com/photo-1503919005314-30d93d07d823?auto=format&fit=crop&w=700&q=80','Festive','A comfortable kurta set for celebrations and family occasions.',0,1),
('Kids Printed Pajama Set','Little Loom','Kids'' Clothing',749,999,25,4.3,67,30,'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=700&q=80','Soft Cotton','A soft printed pajama set for a relaxed bedtime.',0,1),
('Teens Graphic Oversized Tee','Next Wave','Teen Clothing',699,999,30,4.4,128,40,'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=700&q=80','Trending','An oversized graphic tee for an easy streetwear look.',0,1),
('Teens Straight Fit Jeans','Next Wave','Teen Clothing',1499,1999,25,4.3,116,34,'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?auto=format&fit=crop&w=700&q=80','Best Seller','Classic straight-fit jeans made for everyday outfits.',0,1),
('Teens Zip Hoodie','Next Wave','Teen Clothing',1299,1799,28,4.5,92,27,'https://images.unsplash.com/photo-1556821840-3a63f95609a7?auto=format&fit=crop&w=700&q=80','Cozy','A relaxed zip hoodie for layering through the seasons.',0,1),
('Teens Casual Dress','StyleHub','Teen Clothing',1199,1599,25,4.4,79,23,'https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=700&q=80','New Season','A versatile casual dress for school breaks and outings.',0,1),
('Men''s Checked Casual Shirt','Urban Thread','Men''s Clothing',1099,1499,27,4.3,154,36,'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?auto=format&fit=crop&w=700&q=80','Smart Casual','A versatile checked shirt that works from weekdays to weekends.',0,1),
('Men''s Everyday Joggers','North Lane','Men''s Clothing',899,1299,31,4.2,121,42,'https://images.unsplash.com/photo-1552902865-b72c031ac5ea?auto=format&fit=crop&w=700&q=80','Comfort Fit','Comfortable joggers with an easy fit for travel and downtime.',0,1),
('Men''s Lightweight Jacket','Urban Thread','Men''s Clothing',2199,2999,27,4.5,98,18,'https://images.unsplash.com/photo-1551028719-00167b16eac5?auto=format&fit=crop&w=700&q=80','Layer Up','A lightweight layer for cool evenings and everyday commutes.',0,1),
('Women''s Ribbed Top','StyleHub','Women''s Clothing',749,999,25,4.3,183,44,'https://images.unsplash.com/photo-1551163943-3f6a855d1153?auto=format&fit=crop&w=700&q=80','Everyday','A soft ribbed top that pairs easily with denim and skirts.',0,1),
('Women''s Wide Leg Trousers','StyleHub','Women''s Clothing',1399,1899,26,4.4,142,31,'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=700&q=80','New Arrival','Easy wide-leg trousers for a polished everyday look.',0,1),
('Women''s Lightweight Cardigan','Aarvi','Women''s Clothing',1599,2199,27,4.5,108,21,'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?auto=format&fit=crop&w=700&q=80','Layer Up','A soft lightweight cardigan for comfortable layering.',0,1),
('Women''s Festive Suit Set','Aarvi','Ethnic Wear',1899,2599,27,4.6,197,25,'https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=700&q=80','Festive','A graceful suit set for celebrations and special occasions.',0,1),
('Men''s Kurta Set','Aarav','Ethnic Wear',1699,2299,26,4.5,163,24,'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&w=700&q=80','Festive','A classic kurta set for family gatherings and festivities.',0,1)
ON DUPLICATE KEY UPDATE name=VALUES(name);

INSERT INTO products
(name,brand,category,price,old_price,discount,rating,reviews,stock,image,badge,description,featured,trending)
SELECT p.name,p.brand,p.category,p.price,p.old_price,p.discount,p.rating,p.reviews,p.stock,p.image,p.badge,p.description,p.featured,p.trending
FROM (
  SELECT 'Baby Fleece Hoodie' AS name,'Tiny Steps' AS brand,'Baby Clothing' AS category,749 AS price,999 AS old_price,25 AS discount,4.5 AS rating,61 AS reviews,24 AS stock,'https://images.unsplash.com/photo-1519689680058-324335c77eba?auto=format&fit=crop&w=700&q=80' AS image,'Cozy Pick' AS badge,'A soft fleece hoodie for keeping little ones warm.' AS description,0 AS featured,1 AS trending
  UNION ALL SELECT 'Baby Cotton Pajama Set','Little Cloud','Baby Clothing',599,849,29,4.6,49,30,'https://images.unsplash.com/photo-1516627145497-ae6968895b74?auto=format&fit=crop&w=700&q=80','Soft Cotton','A gentle cotton pajama set for comfortable sleep.',0,1
  UNION ALL SELECT 'Kids Striped Polo Shirt','Little Loom','Kids'' Clothing',649,899,28,4.3,73,34,'https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?auto=format&fit=crop&w=700&q=80','Everyday','A smart-casual striped polo shirt for kids.',0,1
  UNION ALL SELECT 'Kids Denim Jeans','Little Loom','Kids'' Clothing',899,1199,25,4.4,85,28,'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?auto=format&fit=crop&w=700&q=80','Best Seller','Comfort-fit denim jeans made for active kids.',0,1
  UNION ALL SELECT 'Kids Floral Dress','Little Loom','Kids'' Clothing',849,1149,26,4.5,91,25,'https://images.unsplash.com/photo-1503919005314-30d93d07d823?auto=format&fit=crop&w=700&q=80','New Style','A cheerful floral dress for parties and family days.',0,1
  UNION ALL SELECT 'Teens Classic Denim Jacket','Next Wave','Teen Clothing',1799,2399,25,4.5,87,20,'https://images.unsplash.com/photo-1543076447-215ad9ba6923?auto=format&fit=crop&w=700&q=80','Trending','A classic denim jacket for easy everyday layering.',0,1
  UNION ALL SELECT 'Teens Cotton Cargo Pants','Next Wave','Teen Clothing',1399,1899,26,4.3,69,26,'https://images.unsplash.com/photo-1517445312882-bc9910d016b7?auto=format&fit=crop&w=700&q=80','Street Style','Relaxed cargo pants with useful pockets and a comfortable fit.',0,1
  UNION ALL SELECT 'Men''s Denim Jacket','Urban Thread','Men''s Clothing',2299,3099,26,4.5,112,19,'https://images.unsplash.com/photo-1516257984-b1b4d707412e?auto=format&fit=crop&w=700&q=80','Layer Up','A timeless denim jacket for everyday outfits.',0,1
  UNION ALL SELECT 'Men''s Regular Fit Jeans','Denim Co.','Men''s Clothing',1599,2199,27,4.4,188,37,'https://images.unsplash.com/photo-1542272604-787c3835535d?auto=format&fit=crop&w=700&q=80','Best Seller','Everyday regular-fit jeans in durable stretch denim.',0,1
  UNION ALL SELECT 'Men''s Striped Polo T-Shirt','North Lane','Men''s Clothing',799,1099,27,4.3,103,41,'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=700&q=80','Smart Casual','A breathable striped polo T-shirt for a relaxed smart look.',0,1
  UNION ALL SELECT 'Women''s Denim Jacket','StyleHub','Women''s Clothing',1899,2599,27,4.5,137,22,'https://images.unsplash.com/photo-1543076447-215ad9ba6923?auto=format&fit=crop&w=700&q=80','Layer Up','A versatile denim jacket to finish casual outfits.',0,1
  UNION ALL SELECT 'Women''s Floral Maxi Dress','StyleHub','Women''s Clothing',1699,2299,26,4.6,204,29,'https://images.unsplash.com/photo-1495385794356-15371f348c31?auto=format&fit=crop&w=700&q=80','Popular','A flowing floral maxi dress for outings and celebrations.',0,1
  UNION ALL SELECT 'Women''s High Rise Jeans','StyleHub','Women''s Clothing',1599,2199,27,4.4,176,33,'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?auto=format&fit=crop&w=700&q=80','Everyday','Comfortable high-rise jeans with a versatile straight fit.',0,1
  UNION ALL SELECT 'Women''s Cotton Kurta Set','Aarvi','Ethnic Wear',1499,1999,25,4.5,158,27,'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&w=700&q=80','Festive','A breathable cotton kurta set for everyday ethnic style.',0,1
  UNION ALL SELECT 'Men''s Cotton Kurta','Aarav','Ethnic Wear',1199,1599,25,4.4,124,31,'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&w=700&q=80','Classic','A comfortable cotton kurta for festive and casual wear.',0,1
) AS p
LEFT JOIN products existing ON existing.name=p.name
WHERE existing.id IS NULL;

INSERT INTO products
(name,brand,category,price,old_price,discount,rating,reviews,stock,image,badge,description,featured,trending)
SELECT p.name,p.brand,p.category,p.price,p.old_price,p.discount,p.rating,p.reviews,p.stock,p.image,p.badge,p.description,p.featured,p.trending
FROM (
  SELECT 'Korean Oversized Oxford Shirt' AS name,'Seoul Edit' AS brand,'Korean Fashion' AS category,1199 AS price,1599 AS old_price,25 AS discount,4.5 AS rating,83 AS reviews,32 AS stock,'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?auto=format&fit=crop&w=700&q=80' AS image,'K-Style' AS badge,'A relaxed oversized shirt inspired by easy Seoul street style.' AS description,1 AS featured,1 AS trending
  UNION ALL SELECT 'Korean Soft Knit Cardigan','Seoul Edit','Korean Fashion',1499,1999,25,4.6,96,24,'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?auto=format&fit=crop&w=700&q=80','K-Style','A soft button-front knit cardigan for effortless layering.',0,1
  UNION ALL SELECT 'Korean Pleated Tennis Skirt','Seoul Edit','Korean Fashion',999,1399,29,4.4,72,28,'https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?auto=format&fit=crop&w=700&q=80','Trending','A pleated skirt for a playful Korean-inspired everyday outfit.',0,1
  UNION ALL SELECT 'Korean Wide Leg Trousers','Seoul Edit','Korean Fashion',1399,1899,26,4.5,91,26,'https://images.unsplash.com/photo-1509631179647-0177331693ae?auto=format&fit=crop&w=700&q=80','K-Style','Comfort-fit wide leg trousers with a clean minimal silhouette.',0,1
  UNION ALL SELECT 'Korean Cropped Hoodie','Seoul Edit','Korean Fashion',1299,1799,28,4.4,68,22,'https://images.unsplash.com/photo-1556821840-3a63f95609a7?auto=format&fit=crop&w=700&q=80','New Style','A relaxed cropped hoodie inspired by casual Seoul looks.',0,1
  UNION ALL SELECT 'Korean Layered Knit Sweater','Seoul Edit','Korean Fashion',1699,2299,26,4.6,77,19,'https://images.unsplash.com/photo-1576566588028-4147f3842f27?auto=format&fit=crop&w=700&q=80','Cozy','A lightweight knit sweater made for easy layered outfits.',0,1
  UNION ALL SELECT 'Women''s Western Wrap Dress','West & Co.','Western Wear',1599,2199,27,4.5,114,25,'https://images.unsplash.com/photo-1495385794356-15371f348c31?auto=format&fit=crop&w=700&q=80','New Arrival','A flattering wrap dress for brunches, outings and celebrations.',0,1
  UNION ALL SELECT 'Women''s Western Denim Skirt','West & Co.','Western Wear',1199,1599,25,4.3,89,30,'https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?auto=format&fit=crop&w=700&q=80','Everyday','A versatile denim skirt that pairs with tees and shirts.',0,1
  UNION ALL SELECT 'Men''s Western Check Shirt','West & Co.','Western Wear',1099,1499,27,4.4,102,34,'https://images.unsplash.com/photo-1598033129183-c4f50c736f10?auto=format&fit=crop&w=700&q=80','Smart Casual','A soft checked shirt for casual days and weekend plans.',0,1
  UNION ALL SELECT 'Women''s Western Knit Top','West & Co.','Western Wear',899,1199,25,4.4,93,29,'https://images.unsplash.com/photo-1551163943-3f6a855d1153?auto=format&fit=crop&w=700&q=80','Easy Style','A comfortable knit top for simple everyday styling.',0,1
  UNION ALL SELECT 'Streetwear Graphic Oversized Tee','Block 9','Streetwear',799,1099,27,4.5,136,38,'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=700&q=80','Street Style','A bold oversized graphic tee for relaxed streetwear looks.',0,1
  UNION ALL SELECT 'Streetwear Cargo Pants','Block 9','Streetwear',1499,1999,25,4.4,108,27,'https://images.unsplash.com/photo-1517445312882-bc9910d016b7?auto=format&fit=crop&w=700&q=80','Trending','Relaxed cargo pants with utility pockets and a modern fit.',0,1
  UNION ALL SELECT 'Streetwear Zip Hoodie','Block 9','Streetwear',1599,2199,27,4.5,97,23,'https://images.unsplash.com/photo-1556821840-3a63f95609a7?auto=format&fit=crop&w=700&q=80','Layer Up','A versatile zip hoodie for everyday streetwear layering.',0,1
  UNION ALL SELECT 'Streetwear Denim Jacket','Block 9','Streetwear',2199,2999,27,4.5,88,18,'https://images.unsplash.com/photo-1516257984-b1b4d707412e?auto=format&fit=crop&w=700&q=80','Best Seller','A sturdy denim jacket for completing casual streetwear outfits.',0,1
) AS p
LEFT JOIN products existing ON existing.name=p.name
WHERE existing.id IS NULL;
