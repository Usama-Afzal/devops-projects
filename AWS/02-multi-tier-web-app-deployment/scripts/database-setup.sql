-- Database Setup Script
-- Run this after connecting to RDS MySQL

-- Create database
CREATE DATABASE IF NOT EXISTS myapp;

-- Use the database
USE myapp;

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO users (name, email) VALUES
    ('John Doe', 'john.doe@example.com'),
    ('Jane Smith', 'jane.smith@example.com'),
    ('Bob Johnson', 'bob.johnson@example.com'),
    ('Alice Williams', 'alice.williams@example.com'),
    ('Charlie Brown', 'charlie.brown@example.com');

-- Create products table (optional)
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample products
INSERT INTO products (name, description, price, stock) VALUES
    ('Laptop', 'High-performance laptop', 999.99, 50),
    ('Mouse', 'Wireless mouse', 29.99, 200),
    ('Keyboard', 'Mechanical keyboard', 79.99, 150),
    ('Monitor', '27-inch 4K monitor', 399.99, 75),
    ('Headphones', 'Noise-cancelling headphones', 199.99, 100);

-- Create a view for active users
CREATE OR REPLACE VIEW active_users AS
SELECT id, name, email, created_at
FROM users
ORDER BY created_at DESC;

-- Show tables
SHOW TABLES;

-- Display user data
SELECT * FROM users;

-- Display product data
SELECT * FROM products;

-- Success message
SELECT 'Database setup completed successfully!' AS Status;
