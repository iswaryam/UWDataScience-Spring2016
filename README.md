###COURSE###
DATASCI 350 DS: Methods for Data Analysis

###AUTHOR###
Iswarya Murali

###PROJECT OBJECTIVE###
Text Analysis of the Harry Potter books.

###DATA SOURCES###
  - .\Books\*.txt
  - .\Lexicon\positive-words.txt and .\Lexicon\negative-words.txt (taken from https://www.cs.uic.edu/~liub/FBS/sentiment-analysis.html#lexicon)
  - http://harrypotter.answers.wikia.com/wiki/Top_200_most_named_harry_potter_characters_s
  - https://en.wikipedia.org/wiki/List_of_spells_in_Harry_Potter

###DATA PREPARATION AND CLEANING###
  1. Read the books in text file format
  2. **Normalization**: Clean Up non-ascii, non-alphabet/non-numeric characters, remove all quotes and other extraneous punctuation except period.
  3. **Tokenization**: Replace alternate nicknames for characters. 
  4. Remove stop words

###HYPOTHESIS TESTING AND ANALYSIS###
For each book:
  1. **Social Network Analysis**:     
      1. Generate a graph of the top 25 characters, per book. If 2 characters occur within a set 
       threshold (15 non stopwords) of each other, count as 1 edge between them.   
      2. Analyze the graph object:        
           - Node with Highest degree centrality, eigenvector centrality and betweenness centrality   
           (https://en.wikipedia.org/wiki/Centrality)    
           - Mean Degree      
           - Pair of nodes with highest weighted edge (strongest relationship)  
      3. **Hypothesis Testing**: Do the Edge Weights of the graph follow ***Power Law fit***?  
  2. **House Popularity**
      1. Plot mentions of the 4 houses, per book
      2. **Hypothesis Testing**: Are the Houses equally represented per ***Chi-Squared Goodness of Fit Test***?
  3. **Word Cloud**: Generate a word cloud per book
  4. **Spell popularity**: Plot mentions of the occurrence of spells (scraped from Wikipedia), per book
  5. **Sentiment Analysis**: Check occurrences of negative words and psoitive words, as a progression between book 1 and book 7
  
All the results (plots/hypothesis tests) are saved as pdf/txt file in the Results folder.

###R FILES###

1. **HarryPotter-Analysis.R** : Main Entry Point File. Reads the text of the 7 books and loops through all functions
2. **hp_helper.R** : Helper file with all functions required to perform analysis.
3. **hp_unit_tests.R** : Unit Tests for helper functions. 
4. **hp_global_vars.R** : File that defines some global variables that are used for the analysis.

###RESULTS###
All Results are stored in the "Results" folder.

1. HarryPotter_Plots.pdf
2. HarryPotter_GraphAnalysis_HypothesisTesting.txt
3. Log File: harrypotterlog.log
