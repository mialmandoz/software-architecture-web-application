#!/bin/bash

# Database Setup Script for WebApplication
# This script creates, migrates, and seeds the database

echo "🚀 Setting up the database..."

echo "📦 Creating database..."
mix ecto.create

if [ $? -eq 0 ]; then
    echo "✅ Database created successfully"
else
    echo "❌ Failed to create database"
    exit 1
fi

echo "🔄 Running migrations..."
mix ecto.migrate

if [ $? -eq 0 ]; then
    echo "✅ Migrations completed successfully"
else
    echo "❌ Failed to run migrations"
    exit 1
fi

echo "🌱 Seeding database..."
mix run priv/repo/seeds.exs

if [ $? -eq 0 ]; then
    echo "✅ Database seeded successfully"
    echo "🎉 Database setup complete! You can now run 'mix phx.server'"
else
    echo "❌ Failed to seed database"
    exit 1
fi
