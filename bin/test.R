#!/usr/bin/env Rscript

print("the test.R script has been loaded")


tryCatch({
  source("tools.R")
},
error=function(cond) {
  path <- Sys.getenv('PATH')
  bin_dir <- unlist(strsplit(x = path, split = ':'))[1]
  source(file.path(bin_dir, "tools.R"))
})

print(foo)