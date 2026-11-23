-- Step 1: Install SQL Server and SSMS

-- Step 2: Get Stack Overfloe database "StackOverflow2010 version: a 1 GB 7-Zip file that expands to about 10 GB, with data from 2008–2010"

CREATE DATABASE StackOverflow2010
ON (FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\StackOverflow2010.mdf'),
	(FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\StackOverflow2010_log.ldf')
FOR ATTACH;


-- Step 3: Configure the instance
-- Leave memory for Windows: about half your RAM (here: 16 GB laptop → 8 GB)
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
EXEC sp_configure 'max server memory (MB)', 8192; RECONFIGURE;

-- Common starting value; stops tiny queries going parallel
EXEC sp_configure 'cost threshold for parallelism', 50; RECONFIGURE;

-- Use the newest query optimizer behaviour your server supports
ALTER DATABASE StackOverflow2010 SET COMPATIBILITY_LEVEL = 160; -- 2022 = 160, 2025 = 170


USE StackOverflow2010;

-- Step 4: Explore the schema
-- Row counts and sizes of every table
SELECT 
	t.name AS table_name,
	SUM(p.rows) AS row_count,
	SUM(a.total_pages) * 8 / 1024 AS size_mb
FROM sys.tables t
JOIN sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0, 1)
JOIN sys.allocation_units a ON a.container_id = p.partition_id
GROUP BY t.name 
ORDER BY size_mb DESC;


-- Step 5: Install the free tools
-- First Responder kit: sp_Blitz , sp_BlitzIndex , sp_BlitzCache , sp_BlitzFirst , sp_BlitzWho and sp_BlitzLock
-- sp_WhoIsActive
-- Plan Explorer (SolarWinds)
-- Statistics Parser


-- Step 6: Take a baseline backup
BACKUP DATABASE StackOverflow2010
TO DISK = 'StackOverflow2010_baseline.bak'
WITH COMPRESSION, CHECKSUM, STATS = 10;
