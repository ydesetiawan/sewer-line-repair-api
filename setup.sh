#!/bin/bash

echo "🚀 Sewer Line Repair API - Quick Start"
echo "======================================"
echo ""

# Check if Ruby is installed
if ! command -v ruby &> /dev/null; then
    echo "❌ Ruby is not installed. Please install Ruby 3.4.7 or later."
    exit 1
fi

echo "✅ Ruby version: $(ruby --version)"

# Check if Bundler is installed
if ! command -v bundle &> /dev/null; then
    echo "📦 Installing Bundler..."
    gem install bundler
fi

# Check if PostgreSQL is running
if ! pg_isready &> /dev/null; then
    echo "⚠️  PostgreSQL is not running. Please start PostgreSQL first."
    echo "   On macOS with Homebrew: brew services start postgresql"
    exit 1
fi

echo "✅ PostgreSQL is running"

# Install dependencies
echo ""
echo "📦 Installing dependencies..."
bundle install

# Setup database
echo ""
echo "🗄️  Setting up database..."
bundle exec rails db:create
bundle exec rails db:migrate

# Check if db setup was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Database setup complete!"
else
    echo ""
    echo "❌ Database setup failed. Please check your PostgreSQL configuration."
    exit 1
fi

echo ""
echo "======================================"
echo "✅ Setup complete!"
echo ""
echo "To start the server, run:"
echo "  rails server"
echo ""
echo "The API will be available at: http://localhost:3000"
echo "Health check endpoint: http://localhost:3000/up"
echo ""
echo "📚 Documentation:"
echo "  - README.md - Project overview"
echo "  - DEVELOPMENT.md - Development guide"
echo "  - API_DOCUMENTATION.md - API documentation"
echo ""

