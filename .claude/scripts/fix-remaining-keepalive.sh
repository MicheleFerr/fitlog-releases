#!/bin/bash
# Fix keepAlive() nei rimanenti Provider<Service> senza autoDispose
# Generato da Claude - richiede review manuale dopo l'esecuzione

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=============================================="
echo " Fix keepAlive() Batch"
echo "=============================================="
echo ""

FIXED=0

# Lista provider che potrebbero aver bisogno di keepAlive
# (solo Provider<Service>, non FutureProvider/StreamProvider)
FILES=(
  "lib/features/notifications/presentation/providers/notification_provider.dart"
  "lib/features/streak/presentation/providers/streak_provider.dart"
  "lib/features/body_measurements/data/repositories/measurement_repository_provider.dart"
  "lib/features/body_measurements/data/repositories/consent_repository_provider.dart"
)

for file in "${FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo -e "${RED}✗ File not found: $file${NC}"
    continue
  fi

  echo "Checking: $file"

  # Cerca Provider<...>((ref) senza FutureProvider/StreamProvider
  PROVIDERS=$(grep -n "^final .* = Provider<.*>((ref)" "$file" | grep -v "Future\|Stream" || true)

  if [ -z "$PROVIDERS" ]; then
    echo -e "${YELLOW}  ⊘ No Provider<Service> found${NC}"
    continue
  fi

  while IFS=: read -r LINE_NUM LINE_CONTENT; do
    # Check se già ha keepAlive nelle successive 3 righe
    HAS_KEEPALIVE=$(sed -n "$((LINE_NUM+1)),$((LINE_NUM+3))p" "$file" | grep -c "keepAlive" || true)

    if [ "$HAS_KEEPALIVE" -eq 0 ]; then
      echo -e "${GREEN}  ✓ Adding keepAlive() at line $LINE_NUM${NC}"
      # Aggiungi keepAlive sulla riga successiva
      sed -i '' "${LINE_NUM}a\\
  ref.keepAlive(); // FIX: previene ricreazione service/repository con stato
" "$file"
      ((FIXED++))
    else
      echo -e "${YELLOW}  ⊘ Already has keepAlive() at line $LINE_NUM${NC}"
    fi
  done <<< "$PROVIDERS"
done

echo ""
echo "=============================================="
echo -e "${GREEN}Fixed $FIXED provider(s)${NC}"
echo "=============================================="
echo ""
echo "⚠️  IMPORTANTE: Esegui flutter analyze per verificare"
exit 0
