#!/bin/bash

# Fix unintended HTML in doc comments by escaping angle brackets with backticks

set -e

echo "Fixing HTML in doc comments..."

# Get all files with unintended_html_in_doc_comment issues
files=$(flutter analyze lib/ 2>&1 | grep "unintended_html_in_doc_comment" | grep -oE 'lib/[^:]+' | sort -u)

count=0
for file in $files; do
  if [ -f "$file" ]; then
    echo "Processing: $file"

    # Fix common patterns:
    # 1. AsyncValue<Type> -> AsyncValue`<Type>`
    # 2. List<Type> -> List`<Type>`
    # 3. Map<K, V> -> Map`<K, V>`
    # 4. Future<Type> -> Future`<Type>`
    # 5. Stream<Type> -> Stream`<Type>`
    # 6. FutureOr<Type> -> FutureOr`<Type>`

    sed -i '' \
      -e 's/AsyncValue<\([^>]*\)>/AsyncValue`<\1>`/g' \
      -e 's/List<\([^>]*\)>/List`<\1>`/g' \
      -e 's/Map<\([^>]*\)>/Map`<\1>`/g' \
      -e 's/Future<\([^>]*\)>/Future`<\1>`/g' \
      -e 's/Stream<\([^>]*\)>/Stream`<\1>`/g' \
      -e 's/FutureOr<\([^>]*\)>/FutureOr`<\1>`/g' \
      -e 's/StateNotifier<\([^>]*\)>/StateNotifier`<\1>`/g' \
      -e 's/Provider<\([^>]*\)>/Provider`<\1>`/g' \
      -e 's/Either<\([^>]*\)>/Either`<\1>`/g' \
      -e 's/Option<\([^>]*\)>/Option`<\1>`/g' \
      "$file"

    ((count++))
  fi
done

echo "✅ Fixed HTML in doc comments in $count files"
