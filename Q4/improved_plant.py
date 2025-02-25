import argparse
import matplotlib.pyplot as plt

# Set up argument parsing
parser = argparse.ArgumentParser(description="Generate plant growth plots based on input data.")
parser.add_argument("--plant", type=str, required=True, help="Name of the plant")
parser.add_argument("--height", type=str, required=True, help="Quoted space-separated list of heights over time (in cm)")
parser.add_argument("--leaf_count", type=str, required=True, help="Quoted space-separated list of leaf counts over time")
parser.add_argument("--dry_weight", type=str, required=True, help="Quoted space-separated list of dry weights over time (in grams)")

# Parse the arguments
args = parser.parse_args()

# Convert space-separated strings into lists of numbers
plant = args.plant
height_data = [float(h) for h in args.height.split()]
leaf_count_data = [int(l) for l in args.leaf_count.split()]
dry_weight_data = [float(d) for d in args.dry_weight.split()]

# Hardcoded weeks array (matches the length of height_data)
weeks = [f"Week {i+1}" for i in range(len(height_data))]

# Print out the plant data
print(f"Plant: {plant}")
print(f"Height data: {height_data} cm")
print(f"Leaf count data: {leaf_count_data}")
print(f"Dry weight data: {dry_weight_data} g")

# Scatter Plot - Height vs Leaf Count
plt.figure(figsize=(10, 6))
plt.scatter(height_data, leaf_count_data, color='b')
plt.title(f'Height vs Leaf Count for {plant}')
plt.xlabel('Height (cm)')
plt.ylabel('Leaf Count')
plt.grid(True)
plt.savefig(f"{plant}_scatter.png")
plt.close()

# Histogram - Distribution of Dry Weight
plt.figure(figsize=(10, 6))
plt.hist(dry_weight_data, bins=len(dry_weight_data), color='g', edgecolor='black')
plt.title(f'Histogram of Dry Weight for {plant}')
plt.xlabel('Dry Weight (g)')
plt.ylabel('Frequency')
plt.grid(True)
plt.savefig(f"{plant}_histogram.png")
plt.close()

# Line Plot - Plant Height Over Time
plt.figure(figsize=(10, 6))
plt.plot(weeks, height_data, marker='o', color='r')
plt.title(f'{plant} Height Over Time')
plt.xlabel('Week')
plt.ylabel('Height (cm)')
plt.grid(True)
plt.savefig(f"{plant}_line_plot.png")
plt.close()

# Output confirmation
print(f"Generated plots for {plant}")
print(f"Scatter plot saved as {plant}_scatter.png")
print(f"Histogram saved as {plant}_histogram.png")
print(f"Line plot saved as {plant}_line_plot.png")
