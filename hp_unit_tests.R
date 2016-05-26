######################################################################################################
# AUTHOR: Iswarya Murali
# PURPOSE: Unit Tests for hp_helper functions.
######################################################################################################

source("hp_helper.R")

test_remove_stopwords = function(logger="hp_logger")
{
  test_value <- trimws(remove_stopwords('Hamlet said To be or not to be that is the question'))
  expected_value <- 'Hamlet question'
  stopifnot(test_value == expected_value)
  log_unit_tests(test_name='test_remove_stopword', test_value, expected_value)
}
######################################################################################################
test_remove_punctuation = function(logger="hp_logger")
{
  test_value <- trimws(remove_punctuation('All the world\'s a stage; and all the men and women - merely players!'))
  expected_value <- 'All the world\'s a stage and all the men and women merely players'
  stopifnot(test_value == expected_value)
  log_unit_tests(test_name ='test_remove_punctuation', test_value=test_value, expected_value=expected_value)
}
######################################################################################################
test_replace_alternate_nicknames = function(logger="hp_logger")
{
  test_value <- replace_alternate_nicknames(hp_text = 'Harry Potter and The Dark Lord.')
  expected_value <- 'Harry and Voldemort.'
  stopifnot(test_value == expected_value)
  log_unit_tests(test_name ='test_replace_alternate_nicknames', test_value, expected_value)
}
######################################################################################################
log_unit_tests = function(test_name, test_value, expected_value, logger="hp_logger")
{
  loginfo(paste("Starting test...", test_name,'\nExpected Value:', expected_value, '\nTest Returned:', test_value), logger="hp_logger")
  if (test_value == expected_value) 
    {loginfo(paste(test_name, 'unit test passed!'), logger=logger)}
  else 
    {logerror(paste(test_name, 'unit test failed!'), logger=logger)}
}
######################################################################################################
hp_run_all_unit_tests = function ()
{
  test_remove_stopwords()
  test_remove_punctuation()
  test_replace_alternate_nicknames()
}
######################################################################################################