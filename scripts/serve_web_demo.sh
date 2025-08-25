#!/bin/bash

# Script to serve the Network Ninja web demo locally

echo "🚀 Starting Network Ninja Web Demo Server..."
echo "📍 Local URL: http://localhost:8000"
echo "🌐 Public URL: https://bluematterin.github.io/network_ninja/"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Check if Python 3 is available
if command -v python3 &> /dev/null; then
    python3 -m http.server 8000 --directory docs
elif command -v python &> /dev/null; then
    python -m http.server 8000 --directory docs
else
    echo "❌ Python not found. Please install Python or use another HTTP server."
    echo "Alternative: cd docs && npx serve ."
    exit 1
fi
