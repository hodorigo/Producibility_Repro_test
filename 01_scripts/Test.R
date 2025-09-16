

install.packages("readxl")

library(readxl)

myfiles <- list.files(path = "./Mestrado/Classes/produc_repro_880AU/my_project3/Producibility_Repro_test/00_rawdata/", pattern = "*.xlsx", full.names = TRUE)

spreadsheet_data <- read_xlsx(myfiles)
