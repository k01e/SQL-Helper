-- FROM https://www.sqlservercentral.com/scripts/time-hour-dimension

IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[TimeDimension]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	DROP TABLE dbo.TimeDimension
GO

CREATE TABLE [TimeDimension]
(
    TimeID				INT IDENTITY (1, 1) NOT NULL PRIMARY KEY,
	--TheDate			DATETIME NOT NULL,
	TheTime				TIME NOT NULL,
	MilitaryHour		INT NOT NULL,
	StandardHour		INT NOT NULL,
	TheMinute			INT NOT NULL,
	TheSecond			INT NOT NULL,
	TotalSeconds		INT NOT NULL,
	TimePeriod			VARCHAR(2) NOT NULL
)


DECLARE    @startdate  DATETIME
DECLARE    @enddate    DATETIME
DECLARE    @date       DATETIME

SET        @startdate  =    '1/1/2020 12:00:00 AM'   
SET        @enddate    =    '1/1/2020 23:59:59 PM'  
SET        @date       =     @startdate

WHILE    @date <= @enddate
BEGIN
    INSERT INTO    TimeDimension (TheTime, MilitaryHour, StandardHour, TheMinute, TheSecond, TotalSeconds, TimePeriod)
    VALUES (
		--@date,											--TheDate
		CONVERT(NVARCHAR(11), @date, 114),				-- Time format   
		DATEPART(hh, @date),							-- Military Hour
		CONVERT(VARCHAR(2),
			CASE
				WHEN DATEPART([hour], @Date) > 12 THEN CONVERT(VARCHAR(2), (DATEPART([hour], @Date) - 12))
				WHEN DATEPART([hour], @Date) = 0 THEN '12'
				ELSE CONVERT(VARCHAR(2), DATEPART([hour], @Date))
			END),										-- Standard Hour
		DATEPART(MINUTE, @date),						-- Minute
		DATEPART(SECOND, @date),						-- Second 
		DATEDIFF(SECOND, @startdate, @date),			-- TotalSeconds
		CASE WHEN DATEPART(hh, @date) between 0 and 11 THEN 'AM' ELSE 'PM' END   
    )


    SET  @date  = DATEADD(mi, 1, @date) 

END

SELECT * FROM dbo.TimeDimension