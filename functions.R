get_names <- function(){
  # Getting the star wars data ready.  
  names <- starwars
  names <- separate(names, name, into = c("names1", "names2"), sep = " ", fill = "right", remove = TRUE)
  
  # The columns that matter are: names1,names2,homeworld,  species
  
  name_list <- c()
  for(columnus in c(names$names1, names$names2, names$homeworld)){
    columnus <- tolower(columnus)
    # removing punctuation
    columnus <- removePunctuation(columnus)
    # stemming
    columnus <- stemDocument(columnus)
    name_list <- append(name_list, columnus)
  }
  
  name_list <- append(name_list, c("artoo", "kylo", "chewi", "chancellor", "threepio", "aayla", "padm", "rose", "ren", "ewok", "hux", "huldo", "hoth", "zorii", "jannah", "exegol", "holdo", "babu", "amilyn", "enric", "queen", "wayfind", "snoke", "capt", "grunt", "skiff", "oscil", "armitag", "starkil", "beed", "chirp", "feder", "canadi", "castl", "maz", "obi", "wan", "peavy", "rogu", "kitster", "falcon", "gungan", "peavey", "espa", "ochi", "fode", "contd", "frik", "kijimi","beaumont","eirta","piett", "oli","millennium","snowspeed", "bunker", "sub","wesa","rathtar","rieekan", "talli", "unkar","massassi","tipoca","mos", "threepio", "cpo", "s"))
  return(name_list)
}

# Removing bad characters
toSpace <- content_transformer(function(x, pattern) gsub(pattern, "[^a-zA-Z0-9]", x))


clean_text <- function(combined, name_list){
  cleaned <- tm_map(combined, toSpace, "/|@|\\|")
  
  # make lowercase
  cleaned <- tm_map(cleaned, content_transformer(tolower))
  
  
  # removing stop words and a couplt of stage directions
  cleaned <- tm_map(cleaned, removeWords, c(stopwords("english"), c("int", "ext", "get", "continu", "around", "can", "t", "like", "make", "away")))
  
  # removing punctuation
  cleaned <- tm_map(cleaned, removePunctuation)
  

  
  
  
  
  
  # removing numbers
  cleaned <- tm_map(cleaned, removeNumbers)
  
  # trimming whitespace
  cleaned <- tm_map(cleaned, stripWhitespace)
  
  # stemming
  cleaned <- tm_map(cleaned, stemDocument)
  
  # removing names
  cleaned <- tm_map(cleaned, removeWords, name_list)
  return(cleaned)
}



get_dtm <- function(cleaned_corpus){
  # Making a dtm
  dtm <- cleaned_corpus %>% DocumentTermMatrix()
  # Removing rare words
  dtm <- removeSparseTerms(dtm, 0.85)
  return(dtm)
}


get_tokens <- function(cleaned_corpus){
  # Splitted the words
  word_l <- strsplit(unlist(sapply(cleaned_corpus, '[', "content")), "[^A-Za-z']+")
  # Making a tibble
  tibble_total <- tibble(id = names(word_l), text=unlist(sapply(cleaned, '[', "content")))
  # Getting the tokens from the tibble
  tokenized <- tibble_total %>% unnest_tokens(word, text)
  return(tokenized)
}

sentiment_grabber <- function(tidy_frame){
  bing_words <- tidy_frame %>% inner_join(get_sentiments("bing"), by = c(term = "word"))
  sentiments <- aggregate(bing_words$count, by = list(Category = bing_words$sentiment), FUN = sum)
  return(sentiments)
}

