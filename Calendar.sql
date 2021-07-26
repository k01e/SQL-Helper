DROP TABLE [Calendar] 
GO

/****** Object:  Table [dbo].[Calendar]    Script Date: 1/15/02 10:36:43 AM ******/
CREATE TABLE [Calendar] (
	[DateIndex] [int] IDENTITY (1, 1) NOT NULL ,
	[Date] [datetime] NOT NULL ,
	EndDateTime datetime not null,
	[Year] [smallint] NOT NULL ,
	[Quarter] [smallint] NOT NULL ,
	[Period] [smallint] NOT NULL ,
	[MonthName] varchar(10) not null,
	[DayOfWeek] [smallint] NOT NULL ,
	[DayName] [char] (15) NOT NULL,
	[PeriodIndex] [smallint] NOT NULL,
	PYDate datetime not null,
	PYYear int not null,
	NYDate datetime not null,
	NYYear int not null
) ON [PRIMARY]
GO

Declare @date datetime,
	@day int,
	@week int,
	@quarter int,
	@weekInPeriod int,
	@period int,
	@lastPeriod int,
	@month int,
	@maxWeeks int,
	@beginyear int,
	@begindate datetime,
	@weekindex smallint,
	@priorperiod smallint,
	@periodindex int
	
	
--set the first day of the week to the first day of the calendar
Select @day = datepart(dw, @Date), @day = 1, @week=1, @weekInPeriod = 1, @maxWeeks = 52,
	@Period = 1,  @begindate = @date, @weekindex=0

set @date = '1/1/2004'

select @priorperiod = 1, @periodindex = 0

while @date <= '12/31/2006'
Begin
	Select @day = datepart(dw, @Date)
	if datepart(month, @date) <> @priorperiod
		set @periodindex = @periodindex + 1
	set @priorperiod = datepart(month, @date)

	set @quarter = case 
		when @week < 14 then 1
		when @week < 27 then 2
		when @week < 40 then 3
		else 4
		end
		
	Insert into Calendar 
		(date,enddatetime, year,quarter,dayName,dayOfWeek,period,monthname,PeriodIndex,PYDate, PYYear, NYDate, NYYear) 
	Values 
		(@date,
		dateadd(second, -1, dateadd(day, 1, @date)),
		datepart(year, @date),
		@quarter,
		dateName(dw,@date),@day,
		datepart(month, @date), 
		datename(month, @date),
		@periodindex, 
		dateadd(year, -1, @date),
		datepart(year, @date) - 1,
		dateadd(year, 1, @date),
		datepart(year, @date) + 1
		 )
		
	--***************************************************************************************************
	--increment one day at a time
	--***************************************************************************************************
	SELECT @date = DATEADD(day, 1, @date)
END

go

select * from calendar
