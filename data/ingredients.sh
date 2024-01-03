#!/bin/sh

# Define the pattern to match the ingredients section
start_pattern="^## Ingredients"
end_pattern="#"

# Flag to track if we're within the ingredients section
in_ingredients=0

# Process each file
for file in content/*.md; do
  # Read the file line by line
  while IFS= read -r line; do
    # Check if we hit the start of the ingredients section
    if echo "$line" | grep -q "$start_pattern"; then
      in_ingredients=1
      continue
    fi
    # Check if we've reached the end of the ingredients section
    if echo "$line" | grep -qE "$end_pattern"; then
      if [ "$in_ingredients" -eq 1 ]; then
        # We've hit the metric or directions section, print a separator and reset the flag
        echo "//"
        in_ingredients=0
      fi
      continue
    fi
    # If we're within the ingredients section, print the line
    if [ "$in_ingredients" -eq 1 ]; then
      # if the line starts with - or * then it's an ingredient
      if echo "$line" | grep -qE "^[*-]"; then
        echo "$line" >> ingredients.txt
      fi 
    fi
  done < "$file"
done
