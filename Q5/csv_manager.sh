#!/bin/bash

CSV_DIR="/app/output"  # Ensure all files are stored in /app/output
LOG_FILE="$CSV_DIR/q5_log.txt"
OUTPUT_FILE="$CSV_DIR/q5_output.txt"
CSV_FILE=""

# Function to log actions
log_action() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to append output actions
append_output() {
    echo -e "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$OUTPUT_FILE"
}

# Ensure output directory exists
mkdir -p "$CSV_DIR"

# Function to create a new CSV file
create_csv() {
    read -p "Enter the name of the CSV file (without extension): " filename
    CSV_FILE="$CSV_DIR/${filename}.csv"  # Save CSV inside /app/output
    echo "Date collected,Species,Sex,Weight" > "$CSV_FILE"
    log_action "Created new CSV file: $CSV_FILE"
}

# Function to display CSV content with row index
display_csv() {
    if [[ ! -f "$CSV_FILE" ]]; then
        log_action "ERROR: No CSV file found!"
        return
    fi
    append_output "Displaying CSV Data with Row Index:"
    awk 'NR==1{print "Index," $0} NR>1{print NR-1 "," $0}' "$CSV_FILE" | tee -a "$OUTPUT_FILE"
    log_action "Displayed CSV data with row index."
}

# Function to add a new row to the CSV
add_row() {
    if [[ ! -f "$CSV_FILE" ]]; then
        log_action "ERROR: No CSV file found!"
        return
    fi
    read -p "Enter Date collected: " date
    read -p "Enter Species: " species
    read -p "Enter Sex (M/F): " sex
    read -p "Enter Weight: " weight

    # Validate input
    if [[ -z "$date" || -z "$species" || ! "$sex" =~ ^(M|F)$ || ! "$weight" =~ ^[0-9]+$ ]]; then
        log_action "ERROR: Invalid input. Please enter correct values."
        return
    fi

    echo "$date,$species,$sex,$weight" >> "$CSV_FILE"
    log_action "Added row: $date, $species, $sex, $weight"
}

# Function to filter by species and calculate average weight
filter_species() {
    read -p "Enter Species to search (e.g., OT): " search_species
    if [[ ! -f "$CSV_FILE" ]]; then
        log_action "ERROR: No CSV file found!"
        return
    fi
    append_output "Filtering by Species: $search_species"
    awk -F, -v species="$search_species" '
        BEGIN {total=0; count=0}
        NR==1 {print; next}
        NR>1 && $2 == species {print; total+=$4; count++}
        END {if(count>0) print "Average weight for", species, ":", total/count}
    ' "$CSV_FILE" | tee -a "$OUTPUT_FILE"
    log_action "Filtered by species: $search_species"
}

# Function to filter by species and sex
filter_sex() {
    read -p "Enter Species Sex (M/F): " search_sex
    if [[ ! -f "$CSV_FILE" ]]; then
        log_action "ERROR: No CSV file found!"
        return
    fi
    append_output "Filtering by Sex: $search_sex"
    awk -F, -v sex="$search_sex" '
        NR==1 {print; next}
        NR>1 && $3 == sex {print}
    ' "$CSV_FILE" | tee -a "$OUTPUT_FILE"
    log_action "Filtered by sex: $search_sex"
}

# Function to save last output to new CSV file
save_output() {
    read -p "Enter name for new CSV file (without extension): " output_csv
    cp "$OUTPUT_FILE" "$CSV_DIR/${output_csv}.csv"
    log_action "Saved last output to file: $CSV_DIR/${output_csv}.csv"
}

# Function to delete row by index
delete_row() {
    if [[ ! -f "$CSV_FILE" ]]; then
        log_action "ERROR: No CSV file found!"
        return
    fi
    read -p "Enter row index to delete: " row
    if [[ ! "$row" =~ ^[0-9]+$ ]]; then
        log_action "ERROR: Invalid row index!"
        return
    fi
    awk -v del="$row" 'NR!=del+1' "$CSV_FILE" > "$CSV_DIR/temp.csv" && mv "$CSV_DIR/temp.csv" "$CSV_FILE"
    log_action "Deleted row $row from CSV"
}

# Function to update weight by row index
update_weight() {
    if [[ ! -f "$CSV_FILE" ]]; then
        log_action "ERROR: No CSV file found!"
        return
    fi
    read -p "Enter row index to update weight: " row
    read -p "Enter new weight: " new_weight
    if [[ ! "$row" =~ ^[0-9]+$ || ! "$new_weight" =~ ^[0-9]+$ ]]; then
        log_action "ERROR: Invalid input!"
        return
    fi
    awk -F, -v rownum="$row" -v new_w="$new_weight" 'NR==1 {print; next} NR==rownum+1 {$4=new_w} {print}' OFS=, "$CSV_FILE" > "$CSV_DIR/temp.csv" && mv "$CSV_DIR/temp.csv" "$CSV_FILE"
    log_action "Updated weight in row $row to $new_weight"
}

# Function to display menu
menu() {
    while true; do
        echo -e "\n📌 CSV MANAGEMENT MENU"
        echo "1. Create CSV"
        echo "2. Display all CSV Data"
        echo "3. Add new row"
        echo "4. Filter by Species and show AVG weight"
        echo "5. Filter by Species Sex"
        echo "6. Save last output to new CSV"
        echo "7. Delete row by index"
        echo "8. Update weight by row index"
        echo "9. Exit"
        
        read -p "Choose an option: " choice
        case $choice in
            1) create_csv ;;
            2) display_csv ;;
            3) add_row ;;
            4) filter_species ;;
            5) filter_sex ;;
            6) save_output ;;
            7) delete_row ;;
            8) update_weight ;;
            9) log_action "Exited the program."; exit 0 ;;
            *) echo "Invalid option. Please choose again." ;;
        esac
    done
}

# Start the menu
menu
