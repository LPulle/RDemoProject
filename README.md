# RDemoProject
You will need a file called "Localized.txt" in the same folder containing 4 items without a header:
1) SQL Server - the Server Name
2) SQL Server - the name of the instance on the SQL Server
3) SQL Server - the name of the database you are connecting to
4) Domain - name of the windows domain the SQL Server is on

eg.\
MySQLServer\
MyInstance\
MyDatabase\
Domain

This will be used to populate the objects in main.R before executing the connect script
Alternatively, you can amend the relevant sections in the SQLServerConnect part
If you do this comment this section out:

```R
Localized <- read.csv("Localized.txt", colClasses = "character", header=F)
GetSQLServer <- Localized$V1[1] #Enter the servername here
GetSQLInstance <- Localized$V1[2] #Enter the SQL Instance name here
GetSQLDatabase <- Localized$V1[3] #Enter the SQL Database name here
GetDomainName <- Localized$V1[4] #Enter Windows Domain name here
```
