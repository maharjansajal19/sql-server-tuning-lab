USE StackOverflow2010;
SET STATISTICS IO, TIME ON;


-- Q1
SELECT Id, DisplayName, Reputation, Location
FROM dbo.Users
WHERE DisplayName = N'Jon Skeet';

-- Q2
SELECT TOP 10 Id, Title, Score, CreationDate
FROM dbo.Posts
WHERE OwnerUserId = 22656
ORDER BY Score DESC;

-- Q3 
SELECT YEAR(CreationDate) AS yr, COUNT(*) AS posts
FROM dbo.Posts
GROUP BY YEAR(CreationDate)
ORDER BY yr;

-- Q4
SELECT U.DisplayName AS 'user_name', B.Name 'badge_name', U.Location 
FROM dbo.Users U
INNER JOIN dbo.Badges B
ON U.Id = B.UserId;

-- Q5
SELECT TOP 100
	P.Title,
	P.Body,
	PT.Type,
	C.Text AS 'Comments',
	P.CreationDate
FROM dbo.Posts P
INNER JOIN dbo.PostTypes PT
ON P.PostTypeId = PT.Id
INNER JOIN dbo.Comments C
ON P.Id = C.PostId
WHERE CONVERT(DATE, P.CreationDate) BETWEEN '2009-01-01' AND '2012-12-31'
ORDER BY P.CreationDate;

-- Q6
SELECT 
	COUNT(*) AS no_of_same_username,
	DisplayName
FROM dbo.Users
GROUP BY DisplayName
HAVING COUNT(*) > 1
ORDER BY no_of_same_username DESC;

-- Q7
SELECT 
	P.Body AS Post,
	PT.Type AS Post_Type,
	VT.Name AS Vote_Type,
	P.ViewCount AS View_Count
FROM dbo.Posts P
INNER JOIN dbo.PostTypes PT 
ON P.PostTypeId = PT.Id
INNER JOIN dbo.Votes V
ON V.PostId = P.Id
INNER JOIN dbo.VoteTypes VT 
ON V.VoteTypeId = VT.Id
WHERE PT.Type = 'Question' AND P.ViewCount > 10000;

-- Q8
SELECT DISTINCT Name
FROM dbo.Badges;

-- Q9 
SELECT 
	U.DisplayName,
	ISNULL(P.Title, 'NO TITLE') AS PostTitle,
	C.Text AS Comment,
	P.LastEditDate,
	ISNULL(P.LastEditorDisplayName, 'NOT AVAILABLE')
FROM dbo.Users U
INNER JOIN dbo.Comments C
ON U.Id = C.UserId
INNER JOIN dbo.Posts P
ON C.PostId = P.Id
WHERE P.LastEditDate > '2015-12-31'
ORDER BY P.LastEditDate DESC

-- Q10
WITH CTE AS (
	SELECT 
		U.DisplayName,
		P.Title,
		ROW_NUMBER() OVER(PARTITION BY U.Id ORDER BY P.LastEditDate DESC) AS rn,
		P.LastEditDate
	FROM dbo.Users U 
	INNER JOIN dbo.Posts P
	ON U.Id = P.OwnerUserId
)
SELECT
	DisplayName,
	Title,
	LastEditDate
FROM CTE
WHERE rn = 1
ORDER BY LastEditDate DESC;

-- Cold vs Warm cache experiment
-- Never run this in production server 
CHECKPOINT;
DBCC DROPCLEANBUFFERS; -- empties the buffer cache

-- rerun this query twice 
SELECT TOP 10 Id, Title, Score, CreationDate
FROM dbo.Posts
WHERE OwnerUserId = 22656
ORDER BY Score DESC;
