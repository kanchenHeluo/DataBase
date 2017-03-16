
--sql server 2008
declare @index int
declare @pageSize int

set @index = 3
set @pageSize = 5
;WITH tbRN AS (SELECT Id, RN=ROW_NUMBER() OVER (ORDER BY Id DESC) FROM dbo.EfileHistory)

SELECT e.*
FROM tbRN 
INNER JOIN dbo.EfileHistory e
ON tbRN.Id = e.Id
WHERE tbRN.RN > (@index -1)*@pageSize AND tbRN.RN <= @index*@pageSize
ORDER BY Id DESC

--sql server 2012
declare @index int
declare @pageSize int

set @index = 2
set @pageSize = 5
;WITH tbRN AS 
(
	SELECT Id FROM dbo.EfileHistory ORDER BY Id DESC
	OFFSET @pageSize*(@index-1) ROWS
	FETCH NEXT @PageSize ROWS ONLY
)

SELECT e.*
FROM tbRN 
INNER JOIN dbo.EfileHistory e
ON tbRN.Id = e.Id
ORDER BY Id DESC