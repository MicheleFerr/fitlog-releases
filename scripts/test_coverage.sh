#!/bin/bash

# Script per generare report di coverage

echo "🧪 Generando test coverage report..."

# Esegui test con coverage
flutter test --coverage

# Genera report HTML (richiede lcov installato: brew install lcov)
if command -v genhtml &> /dev/null; then
  genhtml coverage/lcov.info -o coverage/html
  echo "✅ Report generato in: coverage/html/index.html"
  echo "   Aprilo con: open coverage/html/index.html"
else
  echo "⚠️  lcov non installato. Installa con: brew install lcov"
fi

# Mostra statistiche
echo ""
echo "📊 Coverage Summary:"
lcov --summary coverage/lcov.info 2>/dev/null || echo "Installa lcov per vedere summary"
