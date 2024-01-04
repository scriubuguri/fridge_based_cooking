#!/bin/bash

input_file="all_ingredients"
json_output="grocery.json"
unsorted_output="unsorted.txt"

declare -A patterns=(
[grains]="wheat|rice|corn|oats|rye|barley|quinoa|millet|buckwheat"
[legumes]="lentils|peas|black beans|kidney beans|chickpeas|soybeans|pinto beans|navy beans"
[dairy]="milk|cheese|yogurt|butter|cream"
[meats]="beef|chicken|pork|lamb|turkey|duck|goose"
[seafoods]="fish|salmon|tuna|shrimp|lobster|crab|oysters|mussels|clams"
[vegetables]="carrot|tomato|onion|garlic|broccoli|spinach|peppers|cucumber|zucchini|eggplant|lettuce|celery|cabbage|kale|potato"
[fruits]="apple|orange|banana|grape|lemon|lime|peach|pear|cherry|strawberry|blueberry|raspberry|watermelon|cantaloupe|pineapple"
[fats]="oil|lard|butter|ghee|coconut oil|olive oil"
[sweeteners]="sugar|honey|maple syrup|agave nectar|molasses"
[seasonings]="salt|pepper|cumin|coriander|paprika|turmeric|ginger|cinnamon|basil|oregano|thyme|rosemary|sage|parsley"
[nuts_seeds]="almonds|peanuts|walnuts|cashews|pistachios|flaxseeds|sunflower seeds|pumpkin seeds|sesame seeds|chia seeds"
[grain_products]="bread|pasta|noodles|cereal|tortillas|crackers"
[beverages]="water|tea|coffee|juice|milk"
)

# Initialize groceries list if json file doesn't exist
if [ -f "$json_output" ]; then
    groceries=$(<"$json_output")
else
    groceries=$(jq -n '{grains: [], legumes: [], dairy: [], meats: [], seafoods: [], vegetables: [], fruits: [], fats: [], sweeteners: [], seasonings: [], nuts_seeds: [], grain_products: [], beverages: []}')
fi

unsorted_items=()

# Read input file and sort items into categories
while IFS= read -r line || [[ -n "$line" ]]; do
    line=${line//[$'\n\r']/}
    matched=false
    for category in "${!patterns[@]}"; do
        pattern=${patterns[$category]}
        if [[ $line =~ $pattern ]]; then
            groceries=$(echo "$groceries" | jq --arg item "$line" --arg cat "$category" '.[$cat] += [$item]')
            matched=true
            break
        fi
    done
    if [ "$matched" = false ]; then
        unsorted_items+=("$line")
    fi
done < "$input_file"

# Save sorted items into JSON
echo "$groceries" | jq '.' > "$json_output"

# Save unsorted items, if any, to a file
if [ ${#unsorted_items[@]} -gt 0 ]; then
    printf '%s\n' "${unsorted_items[@]}" > "$unsorted_output"
fi
