#!/bin/bash

# Define paths
CSV_FILE=$1  # CSV file is passed as an argument
LOG_FILE="flower_processing.log"
VENV_DIR="/root/flower_env"  # Virtual environment outside the repository
PYTHON_SCRIPT="improved_plant.py"  # Python script to execute

# Logging function to write everything to the log file
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Ensure CSV file is provided
if [ -z "$CSV_FILE" ]; then
    log "ERROR: No CSV file provided. Usage: ./process_flowers.sh <csv_file_path>"
    exit 1
fi

# Function to check if a virtual environment is active
is_venv_active() {
    if [ -n "$VIRTUAL_ENV" ]; then
        return 0  # Virtual environment is active
    else
        return 1  # No active virtual environment
    fi
}

# Check if a virtual environment is already active
if is_venv_active; then
    log "An active virtual environment is detected: $VIRTUAL_ENV"
else
    # If no active venv, check if one exists, otherwise create it
    if [ -d "$VENV_DIR" ]; then
        log "Using existing virtual environment at $VENV_DIR"
    else
        log "Virtual environment not found. Creating one at $VENV_DIR..."
        python3 -m venv "$VENV_DIR"
    fi
    # Activate the virtual environment
    log "Activating virtual environment..."
    source "$VENV_DIR/bin/activate"
fi

# Function to check if a Python package is installed
is_package_installed() {
    python -c "import $1" &> /dev/null
    return $?
}

# Ensure required Python packages are installed
log "Checking and installing required Python packages..."
for pkg in matplotlib; do
    if is_package_installed "$pkg"; then
        log "Package '$pkg' is already installed."
    else
        log "Installing package: $pkg"
        pip install "$pkg"
    fi
done

# Read CSV file and process each flower
log "Reading CSV file: $CSV_FILE"
tail -n +2 "$CSV_FILE" | while IFS=, read -r Plant Height Leaf_Count Dry_Weight
do
    # Trim spaces
    Plant=$(echo "$Plant" | xargs)
    Height=$(echo "$Height" | xargs)
    Leaf_Count=$(echo "$Leaf_Count" | xargs)
    Dry_Weight=$(echo "$Dry_Weight" | xargs)

    # Create directory inside the current location (NO EXTRA Q4/)
    OUTPUT_DIR="./$Plant"
    mkdir -p "$OUTPUT_DIR"
    
    # Construct and run Python command (WRAPPED ARGUMENTS IN QUOTES)
    CMD="python3 $PYTHON_SCRIPT --plant \"$Plant\" --height \"$Height\" --leaf_count \"$Leaf_Count\" --dry_weight \"$Dry_Weight\""
    log "Running: $CMD"
    
    if eval $CMD; then
        log "SUCCESS: Processing for $Plant completed successfully."
        
        # Move generated images into the plant's directory
        mv "$Plant"_scatter.png "$Plant"_histogram.png "$Plant"_line_plot.png "$OUTPUT_DIR/"
        log "Images saved in $OUTPUT_DIR/"
    else
        log "ERROR: Processing for $Plant failed!"
    fi
done

# Deactivate virtual environment if it was not already active
if ! is_venv_active; then
    deactivate
    log "Processing completed. Virtual environment deactivated."
else
    log "Keeping the existing virtual environment active."
fi
