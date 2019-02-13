## Install packages and if they aren't already installed then load the libraries
## General data wrangling packages
## tidyverse
if(!require(tidyverse)) install.packages("tidyverse"); library(tidyverse)
## plyr
if(!require(plyr)) install.packages('dplyr'); library(plyr)
## dplyr
if(!require(dplyr)) install.packages('dplyr'); library(dplyr)
## readr
if(!require(readr)) install.packages('readr'); library(readr)
## reshape2
if(!require(reshape2)) install.packages("reshape2"); library(reshape2)
## ggplot2
if(!require(ggplot2)) install.packages("ggplot2"); library(ggplot2)

## Packages required to connect to SQL Server and utilities used
## RJDBC (linux)
if(.Platform$OS.type != "windows") if(!require(RJDBC)) install.packages("RJDBC"); if(.Platform$OS.type != "windows") library(RJDBC)
## RODBC (windows)
if(.Platform$OS.type == "windows") if(!require(RODBC)) install.packages("RODBC"); if(.Platform$OS.type == "windows") library(RODBC)
## tcltk
if(!require(tcltk)) install.packages("tcltk"); library(tcltk)
## PKI
if(!require(PKI)) install.packages("PKI"); library(PKI)
## getpass
if(!require(getPass)) install.packages("getPass"); library(getPass)

## sqldf and RH2 if we want to query objects using sql syntax
## sqldf
if(!require(sqldf)) install.packages("sqldf"); library(sqldf)
## RH2
if(!require(RH2)) install.packages("RH2"); library(RH2)