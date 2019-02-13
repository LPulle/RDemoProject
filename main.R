## Set Working Directory
if(.Platform$OS.type == "windows") setwd(paste(Sys.getenv("R_USER"), "\\", "GitHub\\RDemoProject", sep=""))
if(.Platform$OS.type != "windows") setwd("~/GitHub/RDemoProject")
#getwd()

## Clear Existing Objects
## This is lazy but ensures everything is clear when we run
rm(list=ls(all=TRUE))

## Clear any charts/plots
if(!is.null(dev.list()["RStudioGD"])) dev.off()

## Check which OS we are running
os <- .Platform$OS.type

## Install (if needed) and Load Packages we may need
source("LoadPackages.R")

## Put parameters for database connection here
## These will be read when connecting to the SQL Database
Localized <- read.csv("Localized.txt", colClasses = "character", header=F)
GetSQLServer <- Localized$V1[1] #Enter the servername here
GetSQLInstance <- Localized$V1[2] #Enter the SQL Instance name here
GetSQLDatabase <- Localized$V1[3] #Enter the SQL Database name here
GetDomainName <- Localized$V1[4] #Enter Windows Domain name here

## Decide which to run based on OS
if(.Platform$OS.type=="windows") SQLServerConnect <- "SQLServerConnectWindows.R"
if(.Platform$OS.type!="windows") SQLServerConnect <- "SQLServerConnect.R"

## R files we want to run here
source(SQLServerConnect)


