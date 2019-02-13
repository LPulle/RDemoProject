#############################################################
## Demo SQL Server database connection
## This R script runs on a linux installation of RStudio
## It is used to connect to a SQL Server Database on Windows
## using domain name active directory authentication
## You will need the jtds software and install it here:
## /usr/local/etc/jtds-1.3.1/jtds-1.3.1.jar
## Download it from here:
## https://sourceforge.net/projects/jtds/files/jtds/1.3.1/
## Note it's a bit of an old driver (2013)
## So may not work in the future
#############################################################

## jtds uses java to connect but the defaults mean it runs out of memory easily
## Set the memory to 200GB - this is a large value to make it run
## Also set scipen to 999 so numbers are not treated as scientific as that's more user friendly
options(java.parameters = "-Xmx200g")
options(scipen=999)

## use jdbc from rjdbc library calling the jtds driver from /etc/jtds-1.3.1
## this gets us a connection that can be authenticated with kerberos
drv <- JDBC('net.sourceforge.jtds.jdbc.Driver', "/usr/local/etc/jtds-1.3.1/jtds-1.3.1.jar")

## Get username and ask user for password (mask it and encrypt it for security)
## This needs to be the login used to connect to the SQL Server
username <- Sys.getenv("LOGNAME"); #Default: linux login name - change if it needs to be different
key <- PKI.genRSAkey(2048)
password <- PKI.encrypt(charToRaw(getPass::getPass("Enter your windows password: ")), key)

## Assemble components for dbConnect string using username, password and the SQL Server connection details
jtds <- "drv, \"jdbc:jtds:sqlserver://"
winLogin <- "\",domain=GetDomainName,user=username,password=rawToChar(PKI.decrypt(password, key))"
SQLServer <- paste(GetSQLServer, ":1433/", GetSQLDatabase, sep="")
SQLInstance <-paste(";instance=", GetSQLInstance, sep="") 
SQLServer <- paste(SQLServer,SQLInstance, sep="")
conn <- eval(parse(text=paste("dbConnect(", paste(jtds, SQLServer, winLogin, sep=""), ")", sep="")))

## Delete all the component objects now that the connection has been established
rm(username); rm(password); rm(GetDomainName); rm(SQLInstance); rm(winLogin); rm(drv); rm(jtds); 

## List all objects and garbage collect
ls()
gc()

sqlText <- "SELECT
o.object_id, s.name AS SchemaName, o.name AS ObjectName, o.type_desc, 
m.definition,p.data_compression_desc,p.partition_number,a.total_pages,
o.create_date, o.modify_date FROM
sys.objects AS o 
LEFT JOIN sys.sql_modules AS m 
ON m.object_id = o.object_id
INNER JOIN sys.schemas  s
ON o.schema_id = s.schema_id
LEFT JOIN sys.partitions AS p
ON o.object_id = p.object_id
LEFT JOIN sys.allocation_units a
ON p.partition_id = a.container_id
WHERE 
o.type_desc NOT LIKE '%CONSTRAINT%' AND s.name <> 'sys' AND o.is_ms_shipped = 0
ORDER BY SchemaName, ObjectName"

SystemInfo <- dbGetQuery(conn, sqlText)
dbDisconnect(conn)

## Check data types
class(SystemInfo) #data.frame

## Output results
summary(SystemInfo)
nrow(SystemInfo)
head(SystemInfo)
str(SystemInfo)

## Reformat Dates
SystemInfo$create_date <- as.POSIXlt(SystemInfo$create_date, "%Y-%m-%d %H:%M:%S", tz="GMT")
SystemInfo$modify_date <- as.POSIXlt(SystemInfo$modify_date, "%Y-%m-%d %H:%M:%S", tz="GMT")

## Factors
SystemInfo$SchemaName <- as.factor(SystemInfo$SchemaName)
SystemInfo$ObjectName <- as.factor(SystemInfo$ObjectName)
SystemInfo$type_desc <- as.factor(SystemInfo$type_desc)
SystemInfo$partition_number <- as.factor(SystemInfo$partition_number)
SystemInfo$total_pages <- as.factor(SystemInfo$total_pages)

## Check structure
str(SystemInfo)
colnames(SystemInfo)

## Count objects by schema
as.data.frame(table(SystemInfo$SchemaName))

## But there are duplicates because of the total_pages field
SystemInfo2 <- unique(SystemInfo[,c(1:4, 6)])

## Bar chart of the count by schema
## Simple barplot
barplot(table(SystemInfo2$SchemaName), xlab="Schema")

## ggplot2
p <- ggplot(as.data.frame(table(SystemInfo2$SchemaName)), aes(x=Var1, y=Freq)) + 
  geom_bar(stat="identity", color="#FF6666", fill="#FF6666", position=position_dodge())
p+labs(title="Objects per schema", y="Objects", x="Schema", caption=GetSQLServer) +theme(axis.text.x = element_text(angle = 90, hjust=1))


SystemInfoPages <- aggregate(as.numeric(SystemInfo$total_pages), 
                    by=list(ObjectName=paste(SystemInfo$SchemaName, ".", SystemInfo$ObjectName, sep="")),
                    FUN=sum, na.rm=T)
SystemInfoPages$TotalSpaceMB <- SystemInfoPages$x*8/1024
SystemInfo2$TotalSpaceMB <- SystemInfoPages$TotalSpaceMB[match(paste(SystemInfo2$SchemaName, ".",SystemInfo2$ObjectName, sep=""),
                                  SystemInfoPages$ObjectName)]
SystemInfoSize <- aggregate(SystemInfo2$TotalSpaceMB, by=list(SchemaName=SystemInfo2$SchemaName),FUN=sum, na.rm=T)
p2 <- ggplot(SystemInfoSize, aes(x=SchemaName, y=x)) + 
  geom_bar(stat="identity", color="#FF6666", fill="#FF6666", position=position_dodge())
p2+labs(title="Memory used per schema", y="Objects", x="Schema", caption=GetSQLServer) +theme(axis.text.x = element_text(angle = 90, hjust=1))