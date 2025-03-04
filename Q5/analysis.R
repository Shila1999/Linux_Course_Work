# Load required libraries
library(dplyr)
library(ggplot2)

# Read the CSV file
data <- read.csv("/app/data.csv")

# File to save the results
output_file <- "/app/5_R_output.txt"
writeLines("R Analysis Results:\n", output_file)

# 1️⃣ Group by Species and Calculate Mean Weight
species_mean_weight <- data %>%
  group_by(Species) %>%
  summarise(Mean_Weight = mean(Weight, na.rm = TRUE))

writeLines("1️⃣ Mean Weight by Species:\n", output_file, append = TRUE)
write.table(species_mean_weight, output_file, row.names = FALSE, append = TRUE)

# 2️⃣ Calculate the Total Weight by Species
species_total_weight <- data %>%
  group_by(Species) %>%
  summarise(Total_Weight = sum(Weight, na.rm = TRUE))

writeLines("\n2️⃣ Total Weight by Species:\n", output_file, append = TRUE)
write.table(species_total_weight, output_file, row.names = FALSE, append = TRUE)

# 3️⃣ Count the Number of Males and Females
sex_count <- data %>%
  group_by(Sex) %>%
  summarise(Count = n())

writeLines("\n3️⃣ Count of Males and Females:\n", output_file, append = TRUE)
write.table(sex_count, output_file, row.names = FALSE, append = TRUE)

# 4️⃣ Plotting the Weight Distribution by Sex (Saving Image)
png("/app/weight_distribution.png")
ggplot(data, aes(x = Weight, fill = Sex)) +
  geom_histogram(binwidth = 5, position = "dodge") +
  ggtitle("Weight Distribution by Sex") +
  theme_minimal()
dev.off()

writeLines("\n4️⃣ Saved weight distribution plot as 'weight_distribution.png'\n", output_file, append = TRUE)
