##Challenge lesson 3  
##This script performs Quality Control checks on 
## two character columns and three numeric variables from 
## the messy BWG dataset, specificaly bromeliads_messy dataset. 
## I choose to use the columns dataset_name, species, max_water, num_leaf, longest_leaf


##Installing Packages

#install.packages("readr")
#install.packages("dplyr")
#install.packages("assertr")
#install.packages("devtools")


##did not worked, even downdoading a non stable verison of R
##devtools::install_github("drostlab/myTAI")
##devtools::install_github("HajkD/myTAI")


#load library
library(readr)
library(dplyr)
library(assertr)
library(devtools)
library(stringr)
#library(myTAI)


## files
my_files <- list.files(path = "./data/", pattern = "*.csv", full.names = TRUE)


##import 
list2env(
  lapply(setNames(my_files, make.names(gsub(".*1_", "", 
  tools::file_path_sans_ext(my_files)))), read.csv), envir = .GlobalEnv)

##Rename
bm <- read.csv("data/bwgv1_bromeliads_messy.csv")

##Check the dataset
head(bm)

##New dataset with just the columns that I choose to work with
bromeliads_set_columns <- bm %>% 
  select(dataset_name, species, 
         max_water, num_leaf, longest_leaf)

##Check the dataset
head(bromeliads_set_columns)

##From here the goal is to FIND numeric mistakes (Negative values)

bromeliads_set_columns %>% 
  assert(within_bounds(0, Inf ), max_water, num_leaf, longest_leaf)

##Negative values aren't possible due nature of the measurement,
##this is a measurement of how much water was found at the plants leaf base
##to fix the negative values that I believe is just a typo

## Replace negative values with their absolute values

bromeliads_posit_num <- bromeliads_set_columns %>% 
  mutate(longest_leaf = ifelse(longest_leaf < 0, -longest_leaf, longest_leaf) 
         ,max_water = ifelse(max_water < 0, -max_water, max_water) 
         ,num_leaf = ifelse(num_leaf < 0, -num_leaf, num_leaf))

##to test if is there any negative still, 
##if there is no "Error: assert stopped execution" we did fixed the negative values
bromeliads_posit_num %>% 
  assert(within_bounds(0, Inf), max_water, num_leaf, longest_leaf)

##At the column "species" there is different ways of writing the name of the specie, here we can check the typos

unique(bromeliads_posit_num$species)

##In order to fix and standardize the names, I choose to remove any extra characters, but keeping "_" to be friendlier ro R
##For "$species"

bromeliads_char_swipe <- bromeliads_posit_num %>%
  mutate(species = species %>%
           str_replace_all("\\.", "") %>%      
           str_replace_all(" ", "_") %>%       
           str_to_title()) %>% 
  mutate(species= case_when(str_count(species, "_") == 0 ~ paste0(species, "_sp"), TRUE ~ species))

##For "$dataset_name"

bromeliads_char_swipe2 <- bromeliads_char_swipe %>%           
  mutate(dataset_name = dataset_name %>% 
           str_remove("\\.$") %>% 
           str_replace_all("\\.", "") %>% 
           str_replace_all(" ", "_") %>% 
           str_replace_all("(?<=[a-z])(?=[0-9])", "_") %>%
           str_remove("_$") %>%
           str_to_title()) %>% 
  mutate(dataset_name = if_else(str_length(dataset_name) <= 4 & 
                                  dataset_name == "Past","Pasture", dataset_name))




##Test to check if changed the sequence of the arguments gets me an different outcome,
##I'm exploring the assert function, I'm having trouble with the assert "Error"
##df<- data.frame(x = c(10,12,100,15),y=c(1,2,3,4))
##df_checked <- df %>%
##insist(within_n_mads(2),x,error_fun = error_append)
##attributes(df_checked)$assertr_errors

## It did, now I will apply to the dataframe 

### This is the working script to pontit out the potential outliers within 5mads,
##I could find reference stating that a large bromiliad could eventualy hold 4000ml
##of water in their leaves base, so I choose to excludes this value and replace it with NA

#sd(bromeliads_posit_num$max_water, na.rm = TRUE)

#sds_check <- bromeliads_posit_num %>%
  #insist(within_n_sds(0.01), max_water, error_fun = success_continue)

#outliers <- attributes(sds_check)$assertr_errors[[1]][["error_df"]][["value"]]

##Using mutate to change a cell with outliers
#bromeliads_posit_num2 <- bromeliads_posit_num %>%
##  mutate(max_water = ifelse(max_water %in% outliers, NA, max_water))

###test for different ways of writing

#unique(test$species)


##test <- sds_check %>%
 # mutate(new_col = "Im new") %>%
 # mutate(guzmania = ifelse(species == "Guzmania_sp", 1, 0)) %>%
  #group_by(species) %>%
  #mutate(avg_size = mean(num_leaf, na.rm = T)) %>%
  #mutate(avg_size_correct = avg_size - 1)

#unique(test$species)

##-------------##
##Looking for the outliers using a standart deviation 

#rte <- bromeliads_posit_num %>% 
  #insist(success_fun = success_append, error_fun = error_report, within_n_mads(5), c(num_leaf, max_water, longest_leaf))
#summary(rt)
#attributes(rt)

#success_report(bromeliads_posit_num$max_water)


#rt <- bromeliads_posit_num %>% 
  #insist(error_fun = error_report, within_n_mads(5), c(num_leaf, max_water, longest_leaf))
#summary(rt)
#help("success_and_error_functions")

#within_n_mads(1)(bromeliads_posit_num$max_water)



##Another try

#maha_dist(bromeliads_posit_num, keep.NA = FALSE)
## median distance
#sqrt((bromeliads_posit_num$num_leaf - median(bromeliads_posit_num$num_leaf, na.rm = TRUE))^2)



col_sd_add <- cbind(bromeliads_posit_num,maha_dist(bromeliads_posit_num, keep.NA = FALSE))

##to see the column

col_sd_add

##to rename te column

colnames(col_sd_add)[6] = "maha"

##remover the outlier CELL  

##I'm using the method of boxplot to identify outliers 
##I'm using the indexation method to locate a cell with the outlier and replacing it for NA,
##I choose NA so the column is still a vector 
##This way I dont' loose important information that isn't false that are in other columns

col_sd_add [which(col_sd_add$maha %in% boxplot.stats(col_sd_add$maha)$out),"max_water"] <- NA

bromeliads_messy_final_version <- col_sd_add

  
##To check for the outlier row

##bromeliads_posit_num$num_leaf

##Standart deviation 

#brom_sd_free2 <- col_sd_add %>% 
  #ifelse(boxplot.stats(maha)$out)
#outliers <- boxplot.stats(col_sd_add$maha)$out
  
##After running a SDS(2) of with keeps 95% of the mesuraments
##I'm getting a dataset without the "outliers"
##so I can get a mean and judge the outliers better
  

##From here the goal is to FIND mistakes with the names (numbers)


## A way to prevent this mistake to happen will be "To fix" the entries possibilities


