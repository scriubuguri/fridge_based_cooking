#!/bin/bash

input_file="all_ingredients"
json_output="grocery.json"
unsorted_output="unsorted.txt"

declare -A patterns=(
[grains]="flour|wheat|rice|corn|oats|rye|barley|quinoa|millet|buckwheat|couscous"
[legumes]="lentils|peas|black beans|kidney beans|chickpeas|soybeans|pinto beans|navy beans|beans|bean"
[dairy]="milk|cheese|yogurt|butter|cream|mozzarella|cheddar|parmesan|sour cream|feta|kefir|eggs|whey|tofu|rennet|quark|pecorino"
[meats]="beef|chicken|pork|lamb|turkey|duck|goose|veal|bacon|andouille|chuck roast|chouriço negro|ground meat|liver|pancetta|salami|taco-meat|salsiccia|prosciutto|mutton|ham|guanciale|gelatin"
[seafoods]="fish|salmon|tuna|shrimp|lobster|crab|oysters|mussels|clams|mackerel|cod|octopus|squid|seafood|seaweed|shallots|anchovies"
[vegetables]="carrot|onion|garlic|broccoli|spinach|peppers|cucumber|zucchini|eggplant|lettuce|celery|cabbage|kale|potato|potatoes|olives|mushrooms|arugula|asparagus|aubergine|avocado|parsley|turnips|beetroots|radishes|horseradish|pickles|daikon|parsnips|lovage|loorber|leeks|jalepenos|edamame|fenugreek leaves|fennel|epazote|dill|chives|coleslaw|celeriac|cauliflower|capsicum|capers"
[fruits]="apple|orange|banana|grape|lemon|lime|peach|pear|cherry|strawberry|blueberry|raspberry|watermelon|cantaloupe|pineapple|coconut|tomato|raisins|berries|prunes|apricots|cranberries|clementine"
[fats]="oil|lard|butter|ghee|coconut oil|olive oil|yeast|margarine"
[sweeteners]="sugar|honey|maple syrup|agave nectar|molasses|jam|sprinkles|agave|chocolate"
[seasonings]="salt|pepper|cumin|coriander|paprika|turmeric|ginger|cinnamon|basil|oregano|thyme|rosemary|sage|chilli|vinegar|vanilla|mint|powder|mace|cardamom|curry|curcuma|ammonium|za'atar|spice|tahini|sweet relish|star anise|sriacha|saffron|nutmeg|nuez moscada|moroccan|miso|majoran|sumac|cloves|caraway|garam masala|tarragon|cilantro|cajun|baking soda"
[nuts_seeds]="almonds|peanuts|walnuts|cashews|pistachios|flaxseeds|sunflower seeds|pumpkin seeds|sesame seeds|chia seeds|seeds|seed|hazelnuts|nuts|pecans|chia|nut"
[sauces]="sauce|mayonnaise|ketchup|salsa|mustard|dijon|broth|tabasco|tamari|falukorv|chorizo|harissa"
[grain_products]="bread|pasta|noodles|cereal|tortillas|crackers|flakes|vermicelli|spaghetti|maya|tortellini|puff pastry|penne|mostaccioli|maya|macaroni|linguine|fettucine|croutons|biscuit|baguette|cookies"
[beverages]="water|tea|coffee|juice|milk|wine|nectar|beer|stout|rum|sake|liquid|kombucha|kirsch|whiskey|giner|cognac|champagne"
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
