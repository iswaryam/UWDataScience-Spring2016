############################################################################################################### 
# Read README.md for documentation.
# AUTHOR: Iswarya Murali
# PURPOSE : Main Entry Point File. Reads the text of the 7 books and loops through all functions for analysis.
# Refer to README.md for more details.
##############################################################################################################

rm(list=ls())
cat("\014")

########## IMPORTANT TO SET WORKING DIRECTORY, AND THAT ALL FOLDERS (Books, Lexicon) ARE IN PLACE! ###########
#setwd("C:\Users\Documents")

#Create a directory for the results (if exists, recreate)
unlink("./Results", recursive = TRUE)
dir.create("./Results", showWarnings = FALSE, recursive = FALSE, mode = "0777")

source("hp_helper.R")
source("hp_unit_tests.R")
source("hp_global_vars.R")


if (interactive())
{
  files <- sort (GLOBAL.hp_files)
  wc_sent_analysis = data.frame(raw_word_count=as.numeric(), negative_count=as.numeric(), positive_count=as.numeric())

  pdf(GLOBAL.plots_file, onefile=TRUE)
  
  for (i in 1:length(files)) 
  { 
    # Read the text from the books
    filename <- files[i]
    setwd("./Books/");hp_text <- readChar(filename, file.info (filename)$size);setwd("../")
    
    # Normalize text
    hp_text <- normalize_text (hp_text)
  
    #Now that we read the contents of the file, lets remove the ".txt", since we can use File name as Graph Titles
    filename <- gsub("Harry Potter and the ", "", gsub(".txt" , "", filename))
    
    ## 1 : Social Network for Characters.
    hp_graph <- plot_social_network(hp_text, graph_title = filename, ignore_disconnected_vertices=TRUE)
    
    ## 1 b: Social Network for Characters and Test for Power Law Fit
    graph_analyze(hp_graph, title=filename)
    
    ## 2 : House Popularity and Chi Squared Testing
    plot_houses(hp_text, graph_title=filename)
    
    ## 3: Word Cloud
    plot_word_cloud(hp_text,graph_title=filename)
    
    ## 4: Sentiment Analysis
    wc_sent_analysis <- rbind(wc_sent_analysis, sentiment_analysis (hp_text))
    
    ## 5: Plot Spells
    plot_spells(hp_text, graph_title=filename)
  } 
   
  plot_sentiment_analysis(wc_sent_analysis)
  
  dev.off()
  # RUN UNIT TESTS
  hp_run_all_unit_tests()

}
  