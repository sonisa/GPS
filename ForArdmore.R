## EXAMPLE: QUERY BANK DATA IN AN ORACLE DATABASE
install.packages("magrittr") 
library(DBI)
library(dplyr)
library(magrittr)

## ----setup, echo = FALSE, message = FALSE--------------------------------
knitr::opts_chunk$set(collapse = T, comment = "#>")
options(tibble.print_min = 4L, tibble.print_max = 4L)
con<- dbConnect(RSQLite::SQLite(),":memory:")
dbListTables(con)
dbWriteTable(con,"mtcars",mtcars)
dbReadTable(con,"mtcars")

dbGetQuery(con,'
  select "mpg", "hp", "wt",
           sum(case when "vs" = 1 then 1.0 else 0.0 end) as subscribe,
           count(*) as total
           from "mtcars"
           group by "am", "gear", "carb"
           ')
## Database queries in R

dir.create("data", showWarnings = FALSE)
download.file(url = "https://ndownloader.figshare.com/files/2292171",
              destfile = "data/portal_mammals.sqlite", mode = "wb")

#Instead, it merely instructs R to connect to the SQLite database contained in the portal_mammals.sqlite file.
mammals <- DBI::dbConnect(RSQLite::SQLite(), "data/portal_mammals.sqlite")
#src_dbi(mammals)
# To connect to tables within a database, you can use the tbl() function from dplyr
tbl(mammals, sql("SELECT year, species_id, plot_id FROM surveys"))
surveys <- tbl(mammals, "surveys")
surveys %>%
    select(year, species_id, plot_id)
head(surveys, n = 10)
surveys %>%
    filter(weight < 5) %>%
    select(species_id, sex, weight)


data_subset <- surveys %>%
    filter(weight < 5) %>%
    select(species_id, sex, weight)

data_subset %>%
    select(-sex)

#To instruct R to stop being lazy, e.g. to retrieve all of the query results from the database, we add the  collect() command to our pipe.
data_subset <- surveys %>%
    filter(weight < 5) %>%
    select(species_id, sex, weight) %>%
    collect()

plots <- tbl(mammals, "plots")
plots

plots %>%
    filter(plot_id == 1) %>%
    inner_join(surveys) %>%
    collect()

# Write a query that returns the number of rodents observed in each plot in each year.

species <- tbl(mammals, "species")

left_join(surveys, species) %>%
    filter(taxa == "Rodent") %>%
    group_by(taxa, year) %>%
    tally %>%
    collect()

## with SQL syntax
query <- paste("
               SELECT a.year, b.taxa,count(*) as count
               FROM surveys a
               JOIN species b
               ON a.species_id = b.species_id
               AND b.taxa = 'Rodent'
               GROUP BY a.year, b.taxa",
               sep = "" )

tbl(mammals, sql(query))

# Write a query that returns the total number of rodents in each genus caught in the different plot types.

species <- tbl(mammals, "species")
genus_counts <- left_join(surveys, plots) %>%
    left_join(species) %>%
    filter(taxa == "Rodent") %>%
    group_by(plot_type, genus) %>%
    tally %>%
    collect()

## we were interested in the number of genera found in each plot type?
# Using  tally() gives the number of individuals, instead we need to use n_distinct() 
# to count the number of unique values found in a column.

species <- tbl(mammals, "species")
unique_genera <- left_join(surveys, plots) %>%
    left_join(species) %>%
    group_by(plot_type) %>%
    summarize(
        n_genera = n_distinct(genus)
    ) %>%
    collect()

install.packages("RMySQL")
#Connecting R to MySql


con<- dbConnect(RSQLite::SQLite(),":memory:")
dbListTables(con)
dbWriteTable(con,"mtcars",mtcars)
dbReadTable(con,"mtcars")

# List the tables available in this database.
dbListTables(con)

# Query the "actor" tables to get all the rows.
result = dbSendQuery(con, "select * from mtcars")

# Store the result in a R data frame object. n = 5 is used to fetch first 5 rows.
data.frame = fetch(result, n = 5)
print(data.frame)

result = dbSendQuery(con, "select * from mtcars where cyl = 6")

# Fetch all the records(with n = -1) and store it as a data frame.
data.frame = fetch(result, n = -1)
print(data)


res<-dbSendQuery(con,"SELECT * FROM mtcars WHERE cyl = 4")
dbClearResult(res)

##

library(sqldf)

df = data.frame(x=c(1,2,3,4,5),y=c(2,2,3,3,3))
my_query = 'SELECT DISTINCT
      y FROM
      df
      where x>3'

df2 <- sqldf(my_query)


## 

library(dbplyr)
library(odbc)
con <- dbConnect(odbc::odbc(), "Oracle DB")


