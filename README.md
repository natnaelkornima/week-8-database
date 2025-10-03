# E-commerce Database Management System

A complete relational database system for managing an online retail store, built with MySQL.

## 📋 Table of Contents

- [Features](#features)
- [Database Schema](#database-schema)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Running the Project](#running-the-project)
- [Database Structure](#database-structure)
- [API Endpoints Documentation](#api-endpoints-documentation)
- [Sample Queries](#sample-queries)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)

## ✨ Features

- **Customer Management**: User registration, authentication, and profile management
- **Product Catalog**: Hierarchical categories, product listings with multiple images
- **Shopping Cart**: Session-based cart management
- **Order Processing**: Complete order lifecycle from creation to delivery
- **Payment Integration**: Multiple payment methods with transaction tracking
- **Shipping & Tracking**: Real-time shipment status and tracking
- **Reviews & Ratings**: Customer feedback system with verified purchases
- **Wishlist**: Save products for later
- **Coupon System**: Promotional discounts and offers

## 🗄️ Database Schema

The database consists of 15 interconnected tables:

| Table | Purpose | Relationships |
|-------|---------|---------------|
| `customers` | User accounts | One-to-Many with addresses, orders, carts |
| `addresses` | Shipping/billing addresses | Many-to-One with customers |
| `categories` | Product categories | Self-referential, One-to-Many with products |
| `products` | Product catalog | Many-to-One with categories |
| `product_images` | Product photos | Many-to-One with products |
| `carts` | Shopping carts | One-to-One with customers |
| `cart_items` | Items in cart | Many-to-Many (carts ↔ products) |
| `orders` | Customer orders | Many-to-One with customers |
| `order_items` | Products in orders | Many-to-Many (orders ↔ products) |
| `payments` | Payment transactions | Many-to-One with orders |
| `shipments` | Shipping info | One-to-One with orders |
| `reviews` | Product reviews | Many-to-Many (customers ↔ products) |
| `wishlist` | Saved products | Many-to-Many (customers ↔ products) |
| `coupons` | Discount codes | Many-to-Many with orders |
| `order_coupons` | Applied coupons | Junction table |

## 📦 Prerequisites

Before you begin, ensure you have the following installed:

- **MySQL Server** (version 5.7 or higher)
  - Download: https://dev.mysql.com/downloads/mysql/
- **MySQL Workbench** (optional, for GUI management)
  - Download: https://dev.mysql.com/downloads/workbench/
- **Command Line Access** (Terminal/Command Prompt)

### Verify MySQL Installation

```bash
mysql --version
```

You should see output like: `mysql Ver 8.0.x`

## 🚀 Installation

### Step 1: Clone or Download the SQL File

Save the `ecommerce_db.sql` file to your local machine.

### Step 2: Start MySQL Server

**On Windows:**
```bash
net start MySQL80
```

**On macOS (via Homebrew):**
```bash
brew services start mysql
```

**On Linux:**
```bash
sudo systemctl start mysql
```

### Step 3: Login to MySQL

```bash
mysql -u root -p
```

Enter your MySQL root password when prompted.

## 🏃 Running the Project

### Method 1: Using MySQL Command Line

```bash
# Navigate to the directory containing ecommerce_db.sql
cd /path/to/sql/file

# Execute the SQL file
mysql -u root -p < ecommerce_db.sql
```

### Method 2: From MySQL Shell

```sql
-- Login to MySQL first
mysql -u root -p

-- Then execute the file
source /path/to/ecommerce_db.sql;

-- Or use the USE command
USE ecommerce_db;
```

### Method 3: Using MySQL Workbench

1. Open MySQL Workbench
2. Connect to your MySQL server
3. Go to **File → Open SQL Script**
4. Select `ecommerce_db.sql`
5. Click the **Execute** (⚡) button

### Verify Installation

```sql
-- Show all databases
SHOW DATABASES;

-- Use the database
USE ecommerce_db;

-- Show all tables
SHOW TABLES;

-- Describe a table structure
DESCRIBE customers;
```

You should see 15 tables listed.

## 📊 Database Structure

### Entity Relationship Diagram (Conceptual)

```
customers (1) ──→ (*) addresses
    |
    ├──→ (*) orders ──→ (1) shipments
    |         |
    |         └──→ (*) order_items ──→ (*) products
    |
    ├──→ (1) carts ──→ (*) cart_items ──→ (*) products
    |
    ├──→ (*) reviews ──→ (*) products
    |
    └──→ (*) wishlist ──→ (*) products

categories (1) ──→ (*) products ──→ (*) product_images

orders (*) ──→ (*) payments
orders (*) ──→ (*) order_coupons ──→ (*) coupons
```

### Key Constraints

- **Primary Keys**: All tables have auto-incrementing primary keys
- **Foreign Keys**: Referential integrity with CASCADE and RESTRICT policies
- **Unique Constraints**: Email, SKU, order numbers, tracking numbers
- **Check Constraints**: Data validation (prices ≥ 0, ratings 1-5)
- **Indexes**: Optimized for common queries

## 🔌 API Endpoints Documentation

Below is the complete API specification that would be built on top of this database.

### Authentication

| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| POST | `/api/auth/register` | Register new customer | `{ email, password, first_name, last_name }` | `{ customer_id, token }` |
| POST | `/api/auth/login` | Customer login | `{ email, password }` | `{ customer_id, token }` |
| POST | `/api/auth/logout` | Customer logout | - | `{ message }` |
| GET | `/api/auth/me` | Get current user | - | `{ customer data }` |

### Customers

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/customers/:id` | Get customer profile | Yes |
| PUT | `/api/customers/:id` | Update customer profile | Yes |
| DELETE | `/api/customers/:id` | Delete customer account | Yes |
| GET | `/api/customers/:id/orders` | Get customer order history | Yes |

### Addresses

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/addresses` | Get all customer addresses | Yes |
| POST | `/api/addresses` | Add new address | Yes |
| PUT | `/api/addresses/:id` | Update address | Yes |
| DELETE | `/api/addresses/:id` | Delete address | Yes |
| PUT | `/api/addresses/:id/default` | Set default address | Yes |

### Categories

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/categories` | Get all categories | No |
| GET | `/api/categories/:id` | Get category details | No |
| GET | `/api/categories/:id/products` | Get products in category | No |
| GET | `/api/categories/:id/subcategories` | Get child categories | No |

### Products

| Method | Endpoint | Description | Query Parameters |
|--------|----------|-------------|------------------|
| GET | `/api/products` | Get all products | `?page=1&limit=20&category=1&search=keyword&sort=price_asc` |
| GET | `/api/products/:id` | Get product details | - |
| GET | `/api/products/:id/images` | Get product images | - |
| GET | `/api/products/:id/reviews` | Get product reviews | `?page=1&limit=10` |
| GET | `/api/products/search` | Search products | `?q=keyword&category=1&min_price=10&max_price=100` |

**Example Request:**
```http
GET /api/products?category=5&sort=price_asc&limit=20
```

**Example Response:**
```json
{
  "products": [
    {
      "product_id": 1,
      "product_name": "Wireless Mouse",
      "price": 29.99,
      "stock_quantity": 150,
      "rating": 4.5,
      "image_url": "https://example.com/images/mouse.jpg"
    }
  ],
  "total": 45,
  "page": 1,
  "pages": 3
}
```

### Shopping Cart

| Method | Endpoint | Description | Request Body |
|--------|----------|-------------|--------------|
| GET | `/api/cart` | Get current cart | - |
| POST | `/api/cart/items` | Add item to cart | `{ product_id, quantity }` |
| PUT | `/api/cart/items/:id` | Update cart item quantity | `{ quantity }` |
| DELETE | `/api/cart/items/:id` | Remove item from cart | - |
| DELETE | `/api/cart` | Clear entire cart | - |

**Example Response:**
```json
{
  "cart_id": 123,
  "items": [
    {
      "cart_item_id": 1,
      "product_id": 45,
      "product_name": "Laptop Stand",
      "quantity": 2,
      "unit_price": 39.99,
      "subtotal": 79.98
    }
  ],
  "total": 79.98
}
```

### Orders

| Method | Endpoint | Description | Request Body |
|--------|----------|-------------|--------------|
| POST | `/api/orders` | Create new order | `{ shipping_address_id, billing_address_id, payment_method, coupon_code? }` |
| GET | `/api/orders/:id` | Get order details | - |
| GET | `/api/orders` | Get customer orders | - |
| PUT | `/api/orders/:id/cancel` | Cancel order | - |
| GET | `/api/orders/:id/track` | Track shipment | - |

**Create Order Request:**
```json
{
  "shipping_address_id": 5,
  "billing_address_id": 5,
  "payment_method": "credit_card",
  "coupon_code": "SAVE20"
}
```

**Order Response:**
```json
{
  "order_id": 1001,
  "order_number": "ORD-2025-001001",
  "status": "pending",
  "subtotal": 149.97,
  "tax_amount": 12.00,
  "shipping_cost": 9.99,
  "discount": 30.00,
  "total_amount": 141.96,
  "items": [
    {
      "product_name": "Wireless Keyboard",
      "quantity": 1,
      "unit_price": 79.99
    }
  ],
  "created_at": "2025-10-03T14:30:00Z"
}
```

### Payments

| Method | Endpoint | Description | Request Body |
|--------|----------|-------------|--------------|
| POST | `/api/payments` | Process payment | `{ order_id, payment_method, amount, card_details }` |
| GET | `/api/payments/:id` | Get payment details | - |
| POST | `/api/payments/:id/refund` | Refund payment | `{ amount, reason }` |

### Reviews

| Method | Endpoint | Description | Request Body |
|--------|----------|-------------|--------------|
| POST | `/api/reviews` | Create review | `{ product_id, rating, title, comment }` |
| PUT | `/api/reviews/:id` | Update review | `{ rating, title, comment }` |
| DELETE | `/api/reviews/:id` | Delete review | - |
| GET | `/api/products/:id/reviews` | Get product reviews | - |

**Create Review Request:**
```json
{
  "product_id": 45,
  "rating": 5,
  "title": "Excellent product!",
  "comment": "Works perfectly, highly recommend."
}
```

### Wishlist

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/wishlist` | Get wishlist items | Yes |
| POST | `/api/wishlist` | Add to wishlist | Yes |
| DELETE | `/api/wishlist/:product_id` | Remove from wishlist | Yes |

### Coupons

| Method | Endpoint | Description | Query Parameters |
|--------|----------|-------------|------------------|
| POST | `/api/coupons/validate` | Validate coupon code | `{ coupon_code, cart_total }` |
| GET | `/api/coupons/active` | Get active coupons | - |

**Validate Coupon Response:**
```json
{
  "valid": true,
  "coupon_code": "SAVE20",
  "discount_type": "percentage",
  "discount_value": 20.00,
  "discount_amount": 29.99,
  "min_purchase_amount": 50.00
}
```

## 📝 Sample Queries

### 1. Get All Products with Category Names

```sql
SELECT 
    p.product_id,
    p.product_name,
    p.price,
    p.stock_quantity,
    c.category_name
FROM products p
INNER JOIN categories c ON p.category_id = c.category_id
WHERE p.is_active = TRUE
ORDER BY p.product_name;
```

### 2. Get Customer Order History with Total

```sql
SELECT 
    o.order_number,
    o.order_date,
    o.status,
    o.total_amount,
    COUNT(oi.order_item_id) AS total_items
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.customer_id = 1
GROUP BY o.order_id
ORDER BY o.order_date DESC;
```

### 3. Get Product Average Rating

```sql
SELECT 
    p.product_name,
    AVG(r.rating) AS avg_rating,
    COUNT(r.review_id) AS review_count
FROM products p
LEFT JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id
HAVING review_count > 0
ORDER BY avg_rating DESC;
```

### 4. Get Top Selling Products

```sql
SELECT 
    p.product_name,
    SUM(oi.quantity) AS total_sold,
    SUM(oi.subtotal) AS total_revenue
FROM products p
INNER JOIN order_items oi ON p.product_id = oi.product_id
INNER JOIN orders o ON oi.order_id = o.order_id
WHERE o.status NOT IN ('cancelled')
GROUP BY p.product_id
ORDER BY total_sold DESC
LIMIT 10;
```

### 5. Get Customer Cart with Product Details

```sql
SELECT 
    ci.cart_item_id,
    p.product_name,
    p.price,
    ci.quantity,
    (p.price * ci.quantity) AS subtotal
FROM cart_items ci
INNER JOIN products p ON ci.product_id = p.product_id
INNER JOIN carts c ON ci.cart_id = c.cart_id
WHERE c.customer_id = 1;
```

### 6. Get Orders with Shipment Tracking

```sql
SELECT 
    o.order_number,
    o.order_date,
    o.status AS order_status,
    s.carrier,
    s.tracking_number,
    s.status AS shipment_status,
    s.estimated_delivery
FROM orders o
LEFT JOIN shipments s ON o.order_id = s.order_id
WHERE o.customer_id = 1
ORDER BY o.order_date DESC;
```

## 🧪 Testing

### Insert Sample Data

```sql
-- Insert sample customer
INSERT INTO customers (email, password_hash, first_name, last_name, phone) 
VALUES ('john.doe@example.com', 'hashed_password_here', 'John', 'Doe', '555-0123');

-- Insert sample category
INSERT INTO categories (category_name, description) 
VALUES ('Electronics', 'Electronic devices and accessories');

-- Insert sample product
INSERT INTO products (category_id, product_name, description, price, stock_quantity, sku) 
VALUES (1, 'Wireless Mouse', 'Ergonomic wireless mouse', 29.99, 100, 'MOUSE-001');

-- Verify insertion
SELECT * FROM customers WHERE email = 'john.doe@example.com';
SELECT * FROM products WHERE sku = 'MOUSE-001';
```

### Test Relationships

```sql
-- Test foreign key constraint (should fail)
INSERT INTO products (category_id, product_name, price, sku) 
VALUES (999, 'Test Product', 19.99, 'TEST-001');
-- Error: Cannot add or update a child row: a foreign key constraint fails

-- Test cascade delete
DELETE FROM customers WHERE customer_id = 1;
-- This should also delete related addresses, orders, reviews, etc.
```

## 🔧 Troubleshooting

### Common Issues

**1. "Access denied for user 'root'@'localhost'"**
```bash
# Reset MySQL root password
mysql -u root
ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_password';
FLUSH PRIVILEGES;
```

**2. "Database already exists"**
```sql
-- Drop existing database
DROP DATABASE IF EXISTS ecommerce_db;
-- Then run the script again
```

**3. "Cannot delete or update a parent row"**
- This is due to foreign key constraints
- Delete child records first, or modify ON DELETE behavior in schema

**4. Check constraints not working (MySQL < 8.0.16)**
```sql
-- Use triggers instead of CHECK constraints for older versions
-- Or upgrade to MySQL 8.0.16+
```

### Logging

Enable query logging for debugging:

```sql
SET GLOBAL general_log = 'ON';
SET GLOBAL log_output = 'TABLE';

-- View logs
SELECT * FROM mysql.general_log;
```

## 🔐 Security Recommendations

- **Never store plain text passwords** - Always use bcrypt, Argon2, or similar hashing
- **Use prepared statements** - Prevent SQL injection in application code
- **Implement rate limiting** - Protect against brute force attacks
- **Use HTTPS** - Encrypt data in transit
- **Regular backups** - Schedule daily database backups
- **Audit logging** - Track all data modifications

## 📈 Performance Optimization

```sql
-- Analyze table statistics
ANALYZE TABLE products;

-- Check index usage
SHOW INDEX FROM products;

-- Optimize tables
OPTIMIZE TABLE orders;

-- Monitor slow queries
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;
```

## 📄 License

This database schema is provided as-is for educational and commercial use.

## 👥 Contributors

- Database Design: Aura
- Version: 1.0.0
- Last Updated: October 3, 2025

## 📞 Support

For issues or questions:
- Open an issue on GitHub
- Email: natnaelkornima78@gmail.com

---

**Happy Coding! 🚀**
