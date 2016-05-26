######################################################################################################
# AUTHOR: Iswarya Murali
# PURPOSE: This file defines helper functions required for the analysis.
######################################################################################################

rm(list=ls())
cat("\014")

library(stringr)
library(igraph)
library(wordcloud)
library(logging)
source("hp_global_vars.R")


# SET LOGGING
logReset()
basicConfig(level='INFO')
addHandler(writeToFile, logger="hp_logger", file="./Results/harrypotterlog.log", level="INFO")

#####################################################################################################
# Function: remove_stopwords 
# Args: hp_text
# Purpose: Removes stopwords from hp_text
# Returns: hp_text <string>
######################################################################################################
remove_stopwords = function (hp_text)
{
 hp_text <- paste(setdiff(unlist(strsplit(hp_text," ")),GLOBAL.stopWords), collapse=' ')
 return (hp_text)
}

#####################################################################################################
# Function: remove_punctuation
# Args: hp_text
# Purpose: Removes punctuation and non alpha numeric characters from hp_text
# Returns: hp_text <string>
######################################################################################################
remove_punctuation = function (hp_text)
{
  # Removing non-ascii characters
  hp_text <- str_replace_all(hp_text,"[^a-zA-Z.'\\s]", " ")
  # Replacing line break characters with a simple space
  hp_text <- str_replace_all(hp_text,"[\\s]+", " ")
  # Cleaning double spaces
  hp_text <- str_replace_all(hp_text,"  ", " ")
  return (hp_text)
}

#####################################################################################################
# Function: replace_alternate_nicknames
# Args: hp_text
# Purpose: Replaces instances of GLOBAL.name_map$values with the respective GLOBAL.name_map$key in hp_text
# Returns: hp_text <string>
######################################################################################################
replace_alternate_nicknames = function (hp_text)
{
  # Replacing Characters with their key
  for (i in 1:nrow(GLOBAL.name_map))
    {hp_text <- gsub(paste0('\\b', GLOBAL.name_map$values[i], '\\b'), GLOBAL.name_map$key[i],hp_text)}
  return (hp_text)
}

#####################################################################################################
# Function: normalize_text
# Args: hp_text
# Purpose: Normalizing the text - calls the above three functions in sequence
# Returns: hp_text <string>
######################################################################################################
normalize_text = function(hp_text)
{
  start <- Sys.time()
  hp_text <- remove_stopwords(hp_text)
  loginfo(paste("remove_stopwords Processing Time :", Sys.time() - start), logger="hp_logger")
  start <- Sys.time()
  hp_text <- remove_punctuation (hp_text)
  loginfo(paste("remove_punctuation Processing Time :", Sys.time() - start), logger="hp_logger")
  start <- Sys.time()
  hp_text <- replace_alternate_nicknames (hp_text)
  loginfo(paste("replace_alternate_nicknames Processing Time :", Sys.time() - start), logger="hp_logger")
  return (hp_text)
}

#####################################################################################################
# Function: get_character_positions
# Args: hp_text
# Purpose: Parses hp_text for occurrencess of each of GLOBAL.characters and returns their position relative to the text.
# Returns: character_positions. Data Frame consisting of each time the character occurec with their position
# Example: 
#           CHARACTER   POSITION
#           Harry       2000
#           Ron         2314
#           Harry       2317........
######################################################################################################
get_character_positions = function (hp_text)
{
  start <- Sys.time()
  hp_words_vector <- unlist(strsplit(hp_text, " "))
  index <- 1
  characters <- NA; position <- NA
  for (i in 1:length(hp_words_vector)) 
  {
    if (hp_words_vector[i] %in% GLOBAL.characters)
    {
      # If the text matches a character GLOBAL.character, we add it to our array.
      characters[index] = hp_words_vector[i]
      position[index] = i
      index = index + 1
    }
  }
  character_positions <- data.frame(characters=characters,position=position, stringsAsFactors = FALSE)
  loginfo(paste("get_character_positions Processing Time :", Sys.time() - start), logger="hp_logger")
  return (character_positions)
}

#####################################################################################################
# Function: create_characters_matrix
# Args: character_positions <see get_character_positions function>
# Purpose: Constructs an adjacency matrix that defines "interactions" between the characters. If two characters
#          have their immediate positions within the GLOBAL.threshold, we count that as one interaction (ie edge)
# Returns: Adjacency Matrix consisting of each of the characters and relative weighted edge based on their "interactions"
#          This matrix is symmetrical.
# Example:          
#                       Harry     Ron    Hermoine
#             Harry      0        500     200
#             Ron        500      0       250
#             Hermoine   200      250     0
######################################################################################################
create_characters_matrix = function (character_positions)
{
  start <- Sys.time()
  characters_matrix <- matrix(0,nrow=length(GLOBAL.characters), ncol=length(GLOBAL.characters), 
                              dimnames = list(GLOBAL.characters,GLOBAL.characters))
  for (i in 1:(nrow(character_positions)-1)) 
  {
    first_char <- character_positions$characters[i]
    second_char <- character_positions$characters[i+1]
    first_pos <- character_positions$position[i]
    second_pos <- character_positions$position[i+1]
    # Add one edge each time the difference between the positions is less than threshold
    if ((first_char != second_char) & (second_pos - first_pos<=GLOBAL.word_diff_threshold))  
    {
      # We need to fill both sides of the matrix
      characters_matrix[first_char, second_char] <- characters_matrix[first_char, second_char] + 1
      characters_matrix[second_char, first_char] <- characters_matrix[second_char, first_char] + 1
    }
  }
  loginfo(paste("create_characters_matrix Processing Time :", Sys.time() - start), logger="hp_logger")
  return(characters_matrix)
}


#####################################################################################################
# Function: plot_social_network
# Args: hp_text, graph_title
# Purpose: Constructs a igraph from the result of create_character_matrix(), plots this graph 
#          and saves the plot as jpeg.
# Returns: hp_graph <igraph graph object>
######################################################################################################
plot_social_network = function (hp_text, graph_title='Harry Potter', ignore_disconnected_vertices=TRUE)
{
  character_positions <- get_character_positions (hp_text)
  characters_matrix <- create_characters_matrix (character_positions)
  hp_graph <- graph.adjacency(characters_matrix,mode="undirected",weighted=TRUE,diag=FALSE) 
  # Flag to show or hide vertices that aren't connected to any other node
  if (ignore_disconnected_vertices)
    {hp_graph <- delete.vertices(hp_graph, which(degree(hp_graph)==0))}
  
  plot.igraph(hp_graph,vertex.label=V(hp_graph)$name,layout=layout.fruchterman.reingold(hp_graph), 
              edge.color="lightblue",edge.width=E(hp_graph)$weight/50,
              vertex.label.font=2, vertex.label.color='Dark Green', 
              vertex.label.cex=0.85,
              vertex.label.family='sans', vertex.color=NA, vertex.frame.color=NA, 
              main=paste("Social Network", graph_title))
  return (hp_graph)
}

#####################################################################################################
# Function: plot_houses
# Args: hp_text, graph_title
# Purpose: Counts occurrences of GLOBAL.houses in hp_text, plots a pie graph and performs Chi Squared test.
# Returns: hp_graph <igraph graph object>
######################################################################################################
plot_houses = function(hp_text, graph_title='Harry Potter')
{
  start <- Sys.time()
  houses <- data.frame(name=GLOBAL.houses, mentions=0, stringsAsFactors = FALSE)
  houses$mentions <- str_count(hp_text, GLOBAL.houses)
  # Chi Squared Goodness of Fit Test to se eif all Houses are represented equally (ie) probability of 25%
  chi_pval <- chisq.test(houses$mentions, p=c(0.25,0.25,0.25,0.25))$p.value
  if (chi_pval < 0.05) 
    {chi_hyp <- "Reject Null Hypothesis; the Houses are not equally represented."
    } else
    {chi_hyp <- "Failed to Reject Null Hypothesis; the Houses are equally represented."} 
  
  write(paste("\n\t HYPOTHESIS - ARE THE 4 HOUSES REPRESENTED EQUALLY PER CHI SQUARED GOODNESS OF FIT TEST?\n\t",   
              "P-Value for Chi Squared Test:", chi_pval, ".", chi_hyp, "\n\t",
              "*****END OF ANALYSIS*****\n"),GLOBAL.graph_result_file, append=TRUE)
  
  pie(houses$mentions, labels=houses$name, col=c('Red', 'DarkGreen', 'Yellow2', 'DodgerBlue'),
      main = paste("House Popularity:", graph_title), family='sans', cex=0.85)
  loginfo(paste("plot_houses Processing Time :", Sys.time() - start), logger="hp_logger")
}


#####################################################################################################
# Function: plot_word_cloud
# Args: hp_text
# Purpose: Generates a wordcloud of hp_text.
# Returns: hp_graph <igraph graph object>
######################################################################################################
plot_word_cloud = function(hp_text,graph_title="Harry Potter")
{
  start <- Sys.time()
  wordcloud(hp_text, scale=c(4,1.25),rot.per = 0.25, max.words=100, 
            random.color=T, random.order=F, colors = brewer.pal(8, 'Dark2'))
  loginfo(paste("plot_word_cloud Processing Time :", Sys.time() - start), logger="hp_logger")
}

#####################################################################################################
# Function: plot_spells
# Args: hp_text, graph_title
# Purpose: Plots occurrences of GLOBAL.spells in hp_text
# Returns: hp_graph <igraph graph object>
######################################################################################################
plot_spells = function(hp_text, graph_title='Harry Potter')
{
  start <- Sys.time()
  spell_wc <- (str_count(hp_text, GLOBAL.spells))
  names <- GLOBAL.spells[which(spell_wc > 0)]
  count <- spell_wc[which(spell_wc > 0)]
  par(mar=c(4,8,4,1))
  barplot(count, names.arg = names, horiz=TRUE, las=1, cex.names = 0.65, col = brewer.pal(8, 'Accent'),
          xlab = "#Occurrences", ylab="Spell", main=paste("Spell Popularity:", graph_title))
  loginfo(paste("plot_spells Processing Time :", Sys.time() - start), logger="hp_logger")
}


#####################################################################################################
# Function: sentiment_analysis
# Args: hp_text
# Purpose: Counts #occurrences of negative/positive words as defined in GLOBAL.negatives and GLOBAl.positives
# Returns: 3 values - raw_word_count, negative_count, positive_count
######################################################################################################
sentiment_analysis = function (hp_text)
{
  hp_words_vector <- unlist(strsplit(hp_text, " "))
  negative_count <- sum(!is.na(match(hp_words_vector, GLOBAL.negatives)))
  positive_count <- sum(!is.na(match(hp_words_vector, GLOBAL.positives)))
  raw_word_count <- length(hp_words_vector)
  return (cbind(raw_word_count, negative_count, positive_count))
}

#####################################################################################################
# Function: plot_sentiment_analysis
# Args: wc-sent_analysis <data.frame of raw_word_count, negative_count, positive_count per book.
# Purpose: Plots % of positive and negative words a progression across the 7 books
######################################################################################################
plot_sentiment_analysis = function(wc_sent_analysis)
{
  plot(x = 1:7, y=wc_sent_analysis$negative_count/wc_sent_analysis$raw_word_count*100,
       xlab = 'Book Number', ylab = '% of total words', col='red', type='l', lwd=2,
       main='% of Positive vs Negative Words per Book')
  par(new=TRUE)
  plot(x = 1:7, y=wc_sent_analysis$positive_count/wc_sent_analysis$raw_word_count*100,
       xlab = 'Book Number', ylab = '% of total words', col='forestgreen', type='l', lwd=2, yaxt='n')
}

#####################################################################################################
# Function: graph_analyze
# Args: hp_graph <igraph graph object>, graph_title
# Purpose: Does some analysis on the igraph object and logs the results.
#          - Mean Degree
#          - Degree Centrality
#          - Strongest relationship (pair of nodes with the highest weighted edge)
#          - EigenVector Centrality
#          - Betweenness Centrality
######################################################################################################
graph_analyze = function(hp_graph, title)
{
degree_max <- V(hp_graph)[which.max(degree(hp_graph))]$name
max_edge <- c(get.edgelist(hp_graph)[which.max(E(hp_graph)$weight),1], 
              get.edgelist(hp_graph)[which.max(E(hp_graph)$weight),2])
eigen_max <- V(hp_graph)[which.max(evcent(hp_graph)$vector)]$name
btwn_max <- V(hp_graph)[which.max(betweenness(hp_graph))]$name
weighted_edges <- E(hp_graph)$weight
hist(weighted_edges, main=paste("Edges :", filename))
# Power Law Fit for the Edges
pow_fit_pval <- power.law.fit(weighted_edges)$KS.p
if (pow_fit_pval < 0.05) 
  {pow_fit_hyp <- "Reject Null Hypothesis; Edge Weights do not fit Power Law."
  } else
    {pow_fit_hyp <- "Failed to Reject Null Hypothesis; Edge Weights fit Power Law."} 

write(paste("\n\t *********",title, "*********\n\t",
      "GRAPH ANALYSIS", "\n\t", 
      "Mean Degree:",  mean(degree(hp_graph)),  "\n\t",
      "Highest Degree Centrality:",degree_max, "\n\t",
      "Strongest Relationship:",max_edge[1], "and", max_edge[2], "\n\t",
      "Highest EigenVector Centrality:", eigen_max, "\n\t",
      "Highest Betweennes Centrality:",   btwn_max, "\n\n\t",
      "HYPOTHESIS - DO THE EDGE WEIGHTS FOLLOW POWER LAW?\n\t",   
      "P-Value for Power Law Fit", pow_fit_pval, ".", pow_fit_hyp),
      GLOBAL.graph_result_file, append=TRUE)
}




