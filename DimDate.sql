-- From https://www.mssqltips.com/sqlservertip/4054/creating-a-date-dimension-or-calendar-table-in-sql-server/

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[DateDimension]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE dbo.DateDimension
GO

DECLARE @StartDate  date = '20180101';

DECLARE @CutoffDate date = DATEADD(DAY, -1, DATEADD(YEAR, 11, @StartDate));

;WITH seq(n) AS 
(
  SELECT 0 UNION ALL SELECT n + 1 FROM seq
  WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate)
),
d(d) AS 
(
  SELECT DATEADD(DAY, n, @StartDate) FROM seq
),
src AS
(
  SELECT
    TheDate         = CONVERT(date, d),
    TheDay          = DATEPART(DAY, d),
    TheDayName      = DATENAME(WEEKDAY, d),
    TheWeek         = DATEPART(WEEK, d),
    --TheISOWeek      = DATEPART(ISO_WEEK, d),
    TheDayOfWeek    = DATEPART(WEEKDAY, d),
	TheBitDayOfWeek	= POWER(2, CAST(DATEPART(WEEKDAY, d) AS INT) - 1),
    TheMonth        = DATEPART(MONTH, d),
    TheMonthName    = DATENAME(MONTH, d),
    --TheQuarter      = DATEPART(Quarter, d),
    TheYear         = DATEPART(YEAR, d),
    --TheFirstOfMonth = DATEFROMPARTS(YEAR(d), MONTH(d), 1),
    --TheLastOfYear   = DATEFROMPARTS(YEAR(d), 12, 31),
    TheDayOfYear    = DATEPART(DAYOFYEAR, d)

  FROM d
),
dim AS
(
 SELECT *,
  TheWeekOfMonth    = CONVERT(tinyint, DENSE_RANK() OVER 
                            (PARTITION BY TheYear, TheMonth ORDER BY TheWeek)),

  IsLastOfMonth		= CAST(CASE WHEN DENSE_RANK() OVER (PARTITION BY TheYear, TheMonth ORDER BY TheDay DESC) < 8 THEN 1 ELSE 0 END AS BIT)

   FROM src
)
SELECT * 
  INTO dbo.DateDimension
  FROM dim
  ORDER BY TheDate
  OPTION (MAXRECURSION 0);


CREATE UNIQUE CLUSTERED INDEX PK_DateDimension ON dbo.DateDimension(TheDate);

SELECT * FROM dbo.DateDimension