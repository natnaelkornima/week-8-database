-- =====================================================
-- E-COMMERCE DATABASE MANAGEMENT SYSTEM
-- =====================================================
-- This database manages an online retail store with:
-- - Customer management
-- - Product catalog with categories
-- - Shopping cart functionality
-- - Order processing and tracking
-- - Payment records
-- - Product reviews
-- - Shipping information
-- =====================================================

-- Drop database if exists (for clean installation)
DROP DATABASE IF EXISTS ecommerce_db;

-- Create the database
CREATE DATABASE ecommerce_db;

-- Use the database
USE ecommerce_db;

-- =====================================================
-- TABLE: customers
-- Purpose: Store customer account information
-- =====================================================
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    INDEX idx_email (email),
    INDEX idx_last_name (last_name)
);

-- =====================================================
-- TABLE: addresses
-- Purpose: Store customer shipping/billing addresses
-- Relationship: One-to-Many with customers
-- =====================================================
CREATE TABLE addresses (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    address_type ENUM('shipping', 'billing', 'both') NOT NULL,
    street_address VARCHAR(200) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(50) NOT NULL DEFAULT 'USA',
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    INDEX idx_customer (customer_id)
);

-- =====================================================
-- TABLE: categories
-- Purpose: Product categorization hierarchy
-- =====================================================
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    parent_category_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,
    INDEX idx_parent (parent_category_id)
);

-- =====================================================
-- TABLE: products
-- Purpose: Store product catalog information
-- Relationship: Many-to-One with categories
-- =====================================================
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    cost_price DECIMAL(10, 2),
    stock_quantity INT NOT NULL DEFAULT 0,
    sku VARCHAR(50) NOT NULL UNIQUE,
    weight DECIMAL(8, 2),
    dimensions VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CHECK (price >= 0),
    CHECK (stock_quantity >= 0),
    INDEX idx_category (category_id),
    INDEX idx_sku (sku),
    INDEX idx_active (is_active)
);

-- =====================================================
-- TABLE: product_images
-- Purpose: Store multiple images per product
-- Relationship: One-to-Many with products
-- =====================================================
CREATE TABLE product_images (
    image_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    INDEX idx_product (product_id)
);

-- =====================================================
-- TABLE: carts
-- Purpose: Shopping cart session management
-- Relationship: One-to-One with customers (active cart)
-- =====================================================
CREATE TABLE carts (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    session_id VARCHAR(100) UNIQUE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    INDEX idx_customer (customer_id),
    INDEX idx_session (session_id)
);

-- =====================================================
-- TABLE: cart_items
-- Purpose: Items in shopping carts
-- Relationship: Many-to-Many between carts and products
-- =====================================================
CREATE TABLE cart_items (
    cart_item_id INT AUTO_INCREMENT PRIMARY KEY,
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cart_id) REFERENCES carts(cart_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CHECK (quantity > 0),
    UNIQUE KEY unique_cart_product (cart_id, product_id),
    INDEX idx_cart (cart_id),
    INDEX idx_product (product_id)
);

-- =====================================================
-- TABLE: orders
-- Purpose: Customer order records
-- Relationship: One-to-Many with customers
-- =====================================================
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') 
        DEFAULT 'pending',
    subtotal DECIMAL(10, 2) NOT NULL,
    tax_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    shipping_cost DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(10, 2) NOT NULL,
    shipping_address_id INT NOT NULL,
    billing_address_id INT NOT NULL,
    notes TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    FOREIGN KEY (shipping_address_id) REFERENCES addresses(address_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    FOREIGN KEY (billing_address_id) REFERENCES addresses(address_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CHECK (subtotal >= 0),
    CHECK (total_amount >= 0),
    INDEX idx_customer (customer_id),
    INDEX idx_order_number (order_number),
    INDEX idx_status (status),
    INDEX idx_order_date (order_date)
);

-- =====================================================
-- TABLE: order_items
-- Purpose: Products within each order
-- Relationship: Many-to-Many between orders and products
-- =====================================================
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CHECK (quantity > 0),
    CHECK (unit_price >= 0),
    INDEX idx_order (order_id),
    INDEX idx_product (product_id)
);

-- =====================================================
-- TABLE: payments
-- Purpose: Payment transaction records
-- Relationship: One-to-Many with orders
-- =====================================================
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_method ENUM('credit_card', 'debit_card', 'paypal', 'bank_transfer') 
        NOT NULL,
    payment_status ENUM('pending', 'completed', 'failed', 'refunded') 
        DEFAULT 'pending',
    amount DECIMAL(10, 2) NOT NULL,
    transaction_id VARCHAR(100) UNIQUE,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CHECK (amount >= 0),
    INDEX idx_order (order_id),
    INDEX idx_transaction (transaction_id),
    INDEX idx_status (payment_status)
);

-- =====================================================
-- TABLE: shipments
-- Purpose: Shipping and tracking information
-- Relationship: One-to-One with orders
-- =====================================================
CREATE TABLE shipments (
    shipment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    carrier VARCHAR(100) NOT NULL,
    tracking_number VARCHAR(100) UNIQUE,
    shipped_date TIMESTAMP NULL,
    estimated_delivery DATE,
    actual_delivery_date TIMESTAMP NULL,
    status ENUM('preparing', 'shipped', 'in_transit', 'out_for_delivery', 'delivered') 
        DEFAULT 'preparing',
    FOREIGN KEY (order_id) REFERENCES orders(order_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    INDEX idx_tracking (tracking_number),
    INDEX idx_status (status)
);

-- =====================================================
-- TABLE: reviews
-- Purpose: Product reviews and ratings
-- Relationship: Many-to-Many between customers and products
-- =====================================================
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating INT NOT NULL,
    title VARCHAR(200),
    comment TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CHECK (rating BETWEEN 1 AND 5),
    UNIQUE KEY unique_customer_product_review (customer_id, product_id),
    INDEX idx_product (product_id),
    INDEX idx_customer (customer_id),
    INDEX idx_rating (rating)
);

-- =====================================================
-- TABLE: wishlist
-- Purpose: Customer product wishlists
-- Relationship: Many-to-Many between customers and products
-- =====================================================
CREATE TABLE wishlist (
    wishlist_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    UNIQUE KEY unique_customer_product (customer_id, product_id),
    INDEX idx_customer (customer_id),
    INDEX idx_product (product_id)
);

-- =====================================================
-- TABLE: coupons
-- Purpose: Promotional discount codes
-- =====================================================
CREATE TABLE coupons (
    coupon_id INT AUTO_INCREMENT PRIMARY KEY,
    coupon_code VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(200),
    discount_type ENUM('percentage', 'fixed_amount') NOT NULL,
    discount_value DECIMAL(10, 2) NOT NULL,
    min_purchase_amount DECIMAL(10, 2) DEFAULT 0.00,
    max_uses INT,
    times_used INT DEFAULT 0,
    valid_from DATE NOT NULL,
    valid_until DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    CHECK (discount_value > 0),
    CHECK (times_used <= max_uses OR max_uses IS NULL),
    INDEX idx_code (coupon_code),
    INDEX idx_active (is_active)
);

-- =====================================================
-- TABLE: order_coupons
-- Purpose: Track coupon usage in orders
-- Relationship: Many-to-Many between orders and coupons
-- =====================================================
CREATE TABLE order_coupons (
    order_coupon_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    coupon_id INT NOT NULL,
    discount_applied DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (coupon_id) REFERENCES coupons(coupon_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    INDEX idx_order (order_id),
    INDEX idx_coupon (coupon_id)
);

-- =====================================================
-- SUMMARY OF RELATIONSHIPS
-- =====================================================
-- One-to-Many:
--   - customers → addresses
--   - customers → orders
--   - categories → products (with self-referential hierarchy)
--   - products → product_images
--   - orders → order_items
--   - orders → payments
--
-- One-to-One:
--   - orders ↔ shipments
--   - customers ↔ carts (active cart)
--
-- Many-to-Many:
--   - customers ↔ products (through reviews)
--   - customers ↔ products (through wishlist)
--   - carts ↔ products (through cart_items)
--   - orders ↔ products (through order_items)
--   - orders ↔ coupons (through order_coupons)
-- =====================================================