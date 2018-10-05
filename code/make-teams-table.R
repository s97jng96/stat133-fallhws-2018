# Title - nba2018 teams 
# Description - this script creates a CSV file containing data about NBA teams 
# Inputs -
# Outputs - CSV file 

library(readr)

nba2018 <- read_csv("./data/nba2018.csv")

# Replace occurence of "R" with 0 in experience and convert into integers:
nba2018$experience[nba2018$experience == "R"] = 0
nba2018$experience <- as.numeric(nba2018$experience)

# Transforming salary into millions:
nba2018$salary = nba2018$salary/1000000
summary(nba2018$salary)

# Transforming position into a factor with 5 levels: 
nba2018$position <- factor(nba2018$position,
                           levels <- c('C','PF','PG','SF','SG'),
                           labels <- c("center","power_fwd","point_guard","small_fwd","shoot_guard"))

# Adding new variables 
missed_fg <- nba2018$field_goals_atts - nba2018$field_goals
missed_ft <- nba2018$points1_atts - nba2018$points1
rebounds <- nba2018$off_rebounds + nba2018$def_rebounds
efficiency <- (nba2018$points + rebounds + nba2018$assists + nba2018$steals + nba2018$blocks - missed_fg - missed_ft - nba2018$turnovers)/
  nba2018$games
  
nba2018 <- mutate(nba2018,missed_fg,missed_ft,rebounds,efficiency)

sink(file = "../output/efficiency-summary.txt")
summary(efficiency)
sink()

# Creating nba2018-teams.csv
teams <- summarise((group_by(nba2018,team)),
                    experience = round(sum(experience),2),
                    salary = round(sum(salary),2),
                    points3 = sum(points3),
                    points2 = sum(points2),
                    points1 = sum(points1),
                    points = sum(points),
                    off_rebounds = sum(off_rebounds),
                    def_rebounds = sum(def_rebounds),
                    assists = sum(assists),
                    steals = sum(steals),
                    blocks = sum(blocks),
                    turnovers = sum(turnovers),
                    fouls = sum(fouls),
                    efficiency = sum(efficiency))

sink(file = "../data/teams-summary.txt")
summary(teams)
sink()

write.csv(teams, file = "../data/nba2018-teams.csv",row.names = FALSE)
