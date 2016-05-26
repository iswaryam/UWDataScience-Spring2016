######################################################################################################
# AUTHOR: Iswarya Murali
# PURPOSE: This file defines some global variables required for the analysis.
######################################################################################################

library(rvest)
library(tm)

## 1) GLOBAL.spells : List of all Spells in Harry Potter universe 
## Source: Web scraping Wikipedia 
spells_wiki <- read_html("https://en.wikipedia.org/wiki/List_of_spells_in_Harry_Potter")
spells <- spells_wiki %>% html_nodes("h3") %>% html_text()
spells <- spells[1:137]
spells <- str_replace_all(spells, "\\s*\\([^\\)]+\\)", "")  
GLOBAL.spells <- spells[spells!=""]

## 2) List of characters and their "alternate" names/nicknames 
## Source (for key): http://harrypotter.answers.wikia.com/wiki/Top_200_most_named_harry_potter_characters_s 
## Alternate Nickname manually provided
## GLOBAL.characters is just the unique list of characters
GLOBAL.name_map <- data.frame (values = c("Harry Potter", "Potter", "You-Know-Who", "Tom Riddle", "Tom Marvolo Riddle", "He-Who-Must-Not-Be-Named", "The Dark Lord", 
                                      "Ron Weasley", "Ronald Weasley", "Hermione Granger", "Professor Snape", "Severus Snape", "Severus", 
                                      "Draco", "Draco Malfoy", "Neville Longbottom", "Longbottom","Albus Dumbledore", "Professor Dumbledore", "Albus",
                                      "Professor McGonagall", "Minerva", "Minerva McGonagall","Mrs. Weasley", "Molly Weasley", "Arthur Weasley", "Mr. Weasley", 
                                      "Sirius Black", "Remus Lupin", "Professor Lupin", "Remus","Ginny Weasley","Fred Weasley", "George Weasley", "Percy Weasley", "Rubeus Hagrid", "Rubeus", 
                                      "Dolores Umbridge", "Professor Umbridge", "Dolores","Alastor Moody", "Mad-Eye Moody", "Professor Moody", "Alastor", "Dobby"), 
                           
                           key = c("Harry", "Harry", "Voldemort", "Voldemort","Voldemort","Voldemort","Voldemort","Ron", "Ron", "Hermione", "Snape", "Snape", "Snape", 
                                   "Malfoy", "Malfoy", "Neville", "Neville","Dumbledore", "Dumbledore","Dumbledore", "McGonagall", "McGonagall", "McGonagall","Molly", "Molly", "Arthur", "Arthur", 
                                   "Sirius", "Lupin", "Lupin", "Lupin", "Ginny","Fred", "George", "Percy", "Hagrid", "Hagrid",
                                   "Umbridge", "Umbridge", "Umbridge","Moody", "Moody", "Moody", "Moody", "Dobby"
                           ), stringsAsFactors = FALSE)

GLOBAL.characters <- unique(GLOBAL.name_map$key)


## 3) Source : tm.stopwords - use the English and the SMART dataset (http://jmlr.csail.mit.edu/papers/volume5/lewis04a/a11-smart-stop-list/english.stop)
##    In addition, also add our own stop words like school, witch, wizard, etc. We also want to look for all cases.
stopword <- unique(c(stopwords("en"), stopwords("SMART"), c("said", "told", "asked", "seemed", "thought", "school", "Hogwarts", "witch", "wizard")))
GLOBAL.stopWords <- unique(c(stopword, toupper(stopword),paste(toupper(substr(stopword, 1, 1)), substr(stopword, 2, nchar(stopword)), sep="")))
      
#paste(toupper(substr(name, 1, 1)), substr(name, 2, nchar(name)), sep="")

## 4) Threshold that defines an "interaction" between characters with their relative positions. 
GLOBAL.word_diff_threshold <- 15

## 5) List of the 4 Houses in Harry Potter
GLOBAL.houses <- c('Gryffindor', 'Slytherin', 'Hufflepuff', 'Ravenclaw')

## 6) List of "negative" and "positive" connotation words
# SOURCE: Files downloaded from https://www.cs.uic.edu/~liub/FBS/sentiment-analysis.html#lexicon
GLOBAL.negatives <- readLines("./Lexicon/negative-words.txt")
GLOBAL.positives <- readLines("./Lexicon/positive-words.txt")

## 7) Txt files of the books themselves
setwd("./Books/")
GLOBAL.hp_files <- list.files(pattern = "[0-9] - (Harry Potter)[A-Z a-z - ]*.(txt)")
setwd("../")

## 8) File to store the results of hypothesis tests and graph analysis
GLOBAL.graph_result_file <- "./Results/HarryPotter_GraphAnalysis_HypothesisTesting.txt"
GLOBAL.plots_file <- "./Results/HarryPotter_Plots.pdf"
