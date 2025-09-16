

install.packages("readxl")
install.packages("ggplot")


library(readxl)
library(readr)
library(ggplot2)

myfiles <- list.files(path = "./Mestrado/Classes/produc_repro_880AU/my_project3/Producibility_Repro_test/00_rawdata/", pattern = "*.xlsx", full.names = TRUE)

spreadsheet_data <- read_xlsx(myfiles)


library(palmerpenguins)

raw_data <-penguins_raw
# Export the data frame to a CSV file
write.csv("raw_data", "./")

ggplot_build(plot, )
