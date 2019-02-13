## Set scipen to 999 so numbers are not treated as scientific as that's more user friendly
options(scipen=999)

## Create Connection String from parameters and connect to database
GetConnectionString <- paste("driver={SQL Server};server=", paste(GetSQLServer, GetSQLInstance, sep="\\"), paste(";database=", GetSQLDatabase, ";trusted_connection=true", sep=""),sep="")
dbhandle <- odbcDriverConnect(GetConnectionString)

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

SystemInfo <- sqlQuery(dbhandle, sqlText)

close(dbhandle)

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