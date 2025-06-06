# Load in data and clean data frame
library("tidyverse")

df_raw <- read_csv("activities_12_28_2024.csv")
df_clean <- df_raw |> 
  select(date = "Activity Date",
         name = "Activity Name",
         type = "Activity Type",
         description = "Activity Description",
         total_time = "Elapsed Time...6",
         time = "Moving Time",
         distance = "Distance...7",
         elevation = "Elevation Gain") |>
  mutate(distance = distance * .621,
         total_time = total_time / 60,
         time = time / 60,
         pace = time / distance,
         elevation = if_else(is.na(elevation), 0, elevation),
         elevation = elevation * 3.281)

print(df_clean)

# Total Statistics:
total_summary <- df_clean |>
  summarize(
    total_activities = n(),
    total_miles = sum(distance),
    total_hours = sum(time),
    total_elevation = sum(elevation)) |>
  mutate(total_hours = total_hours / 60)

print(total_summary)

# Run histogram:
run_histogram <- df_clean |>
  ggplot(aes(x = distance)) + 
  geom_histogram(color = "black", fill = "lightblue",binwidth = 1) + 
  labs(x = "Distance (miles)",
       y = "Number of runs",
       title = "Number of runs at each distance")

print(run_histogram)

# Pace histogram:
pace_histogram <- df_clean |>
  ggplot(aes(x = pace)) + 
  geom_histogram(color = "black", fill = "lightblue", binwidth = 1) +
  labs(x = "Pace (min/mile)",
       y = "Number of runs",
       title = "Pace distribution") +
  scale_x_continuous(breaks = seq(floor(min(df_clean$pace)), 
                                  ceiling(max(df_clean$pace)), by = 1))

print(pace_histogram)

# Adding month and year columns
df_dates <- df_clean |>
  mutate(
    year = case_when(
      grepl(2021, date) ~ 2021,
      grepl(2022, date) ~ 2022,
      grepl(2023, date) ~ 2023,
      grepl(2024, date) ~ 2024),
    month = case_when(
      grepl("Jan", date) ~ "Jan",
      grepl("Feb", date) ~ "Feb",
      grepl("Mar", date) ~ "Mar",
      grepl("Apr", date) ~ "Apr",
      grepl("May", date) ~ "May",
      grepl("Jun", date) ~ "Jun",
      grepl("Jul", date) ~ "Jul",
      grepl("Aug", date) ~ "Aug",
      grepl("Sep", date) ~ "Sep",
      grepl("Oct", date) ~ "Oct",
      grepl("Nov", date) ~ "Nov",
      grepl("Dec", date) ~ "Dec",
    )) |>
  select(date, year, month, everything())

# Yearly Summaries
yearly_summaries <- df_dates |>
  group_by(year) |>
  summarize(
    total_activities = n(),
    total_miles = sum(distance),
    total_hours = sum(time),
    total_elevation_feet = sum(elevation)) |>
  mutate(total_hours = total_hours / 60)

print(yearly_summaries)

# Number of runs in each month
monthly_runs <- df_dates |>
  group_by(year) |>
  ggplot(aes(x = month)) +
  geom_bar(color = "black", fill = "lightblue") + 
  labs(x = "Month",
       y = "Number of runs",
       title = "Number of runs each month across all years")

print(monthly_runs)

# Pie Chart
distance_pie <- df_clean |>
  mutate(distance_class = case_when(
    distance >= 0 & distance <= 2 ~ "<2",
    distance > 2 & distance <= 4 ~ "2-4",
    distance > 4 & distance <= 6 ~ "4-6",
    distance > 6 & distance <= 8 ~ "6-8",
    distance > 8 ~ ">8"
  )) |>
  group_by(distance_class) |>
  summarize(count = n()) |>
  
  ggplot(aes(x = "", y = count, fill = distance_class)) +
    geom_bar(stat = "identity") + 
    geom_text(aes(label = count),
              position = position_stack(vjust = 0.5)) +
    coord_polar(theta = "y") + 
    theme_void() + 
    labs(title = "Number of runs in each distance class")

print(distance_pie)