CREATE PROCEDURE [dbo].[ParseScheduleXml] 
	@doc xml
AS
BEGIN
	declare @calcId uniqueidentifier = newid()
	declare @startDate datetime = getdate()
	declare @startDate1 datetime = getdate()

	insert into [Log] (Value, CalcId, CalcSeconds) values ('Begin', @calcId, datediff(second, @startDate, getdate()))
	set @startDate = getdate()

	--------------------Создание и заполнение временных таблиц
	declare @tableCity table (id uniqueidentifier, Name varchar(max))
	declare @tableLpu table (id uniqueidentifier, Name varchar(max), CityId uniqueidentifier)
	declare @tableDivLpu table (id uniqueidentifier, Name varchar(max), LpuId uniqueidentifier, Info varchar(max))
	declare @tableSpecialist table (id uniqueidentifier, Name varchar(max), AdditionalText varchar(max), primary key(id))
	declare @tableDoctor table (id uniqueidentifier, FirstName varchar(max), SecondName varchar(max), LastName varchar(max), SpecialityId uniqueidentifier, DivLpuId uniqueidentifier)
	declare @tableArea table (Id uniqueidentifier, Name nvarchar(255), DivLpuId uniqueidentifier)
	declare @tableAreaAddress table (Id uniqueidentifier, [Address] nvarchar(4000), AreaId uniqueidentifier)
	declare @tableAreaDoctor table (AreaId uniqueidentifier, DoctorId uniqueidentifier)
	create table #tableScheduleCell (id uniqueidentifier, StartDate datetime, EndDate datetime, State tinyint, DoctorId uniqueidentifier, primary key(id))

	insert into @tableCity
	select 
		T.c.value('@Id','uniqueidentifier'), 
		T.c.value('@Name','nvarchar(max)')
	from @doc.nodes('/Data/Cities/C') T(c)

	insert into [Log] (Value, CalcId, CalcSeconds) values ('Insert City', @calcId, datediff(second, @startDate, getdate()))
	set @startDate = getdate()

	insert into @tableLpu
	select 
		T.c.value('@Id','uniqueidentifier'), 
		T.c.value('@Name','nvarchar(max)') ,
		T.c.value('@CityId','uniqueidentifier')
	from @doc.nodes('/Data/Lpus/L') T(c)

	insert into [Log] (Value, CalcId, CalcSeconds) values ('Insert Lpu', @calcId, datediff(second, @startDate, getdate()))
	set @startDate = getdate()

	insert into @tableDivLpu
	select
		Id = T.c.value('@Id','uniqueidentifier'),
		T.c.value('@Name','nvarchar(max)'), 
		T.c.value('@LpuId','uniqueidentifier'), 
		T.c.value('@Info','nvarchar(max)')
	from @doc.nodes('/Data/DivLpus/DL') T(c) 
	
	insert into [Log] (Value, CalcId, CalcSeconds) values ('Insert DivLpu', @calcId, datediff(second, @startDate, getdate()))
	set @startDate = getdate()

	insert into @tableSpecialist
	select 
		T.c.value('@Id', 'uniqueidentifier'), 
		T.c.value('@Name', 'nvarchar(max)'),
		T.c.value('@AdditionalText', 'nvarchar(max)')
	from @doc.nodes('/Data/Specialities/SP') T(c)

	insert into [Log] (Value, CalcId, CalcSeconds) values ('Insert Specialist', @calcId, datediff(second, @startDate, getdate()))
	set @startDate = getdate()

	insert into @tableArea
	select
		Id = T.c.value('@Id', 'uniqueidentifier'),
		T.c.value('@Name', 'nvarchar(255)'),
		T.c.value('@DivLpuId', 'uniqueidentifier')
	from @doc.nodes('/Data/Areas/A') T(c);

	insert into [Log] (Value, CalcId, CalcSeconds) values ('Insert Area', @calcId, datediff(second, @startDate, getdate()))
	set @startDate = getdate()

	delete from @tableArea
	where not exists
	(
		select *
		from @tableDivLpu dl
		where dl.id = DivLpuId
	);

	insert into [Log] (Value, CalcId, CalcSeconds) values ('Delete Area', @calcId, datediff(second, @startDate, getdate()))
	set @startDate = getdate()

	insert into @tableAreaAddress
	select
		Id = T.c.value('@Id', 'uniqueidentifier'),
		T.c.value('@Address', 'nvarchar(4000)'),
		T.c.value('@AreaId', 'uniqueidentifier')
	from @doc.nodes('/Data/AreaAddresses/AA') T(c);

	insert into [Log] (Value, CalcId, CalcSeconds) values ('Insert AreaAddress', @calcId, datediff(second, @startDate, getdate()))
	set @startDate = getdate()

	delete from @tableAreaAddress
	where not exists
	(
		select *
		from @tableArea ta
		where ta.Id = AreaId
	);

	insert into [Log] (Value, CalcId, CalcSeconds) values ('Delete AreaAddress', @calcId, datediff(second, @startDate, getdate()))
	set @startDate = getdate()

	insert into @tableDoctor
	select 
		T.c.value('@Id','uniqueidentifier'),
		T.c.value('@FirstName','nvarchar(max)'), 
		T.c.value('@SecondName','nvarchar(max)'), 
		T.c.value('@LastName','nvarchar(max)'), 
		T.c.value('@SpecialityId','uniqueidentifier'),
		T.c.value('@DivLpuId','uniqueidentifier')
	from @doc.nodes('/Data/Doctors/D') T(c)

	insert into [Log] (Value, CalcId, CalcSeconds) values ('Insert Doctor', @calcId, datediff(second, @startDate, getdate()))
	set @startDate = getdate()

	delete from @tableDoctor
	where SpecialityId is null
		or not exists
	(
		select Id
		from @tableSpecialist s
		where s.id = SpecialityId
	);

	insert into [Log] (Value, CalcId, CalcSeconds) values ('Delete Doctor', @calcId, datediff(second, @startDate, getdate()))
	set @startDate = getdate()

	insert into @tableAreaDoctor
	select
		AreaId = T.c.value('@AreaId', 'uniqueidentifier'),
		DoctorId = T.c.value('@DoctorId', 'uniqueidentifier')
	from @doc.nodes('/Data/AreaDoctors/AD') T(c);

	insert into [Log] (Value, CalcId, CalcSeconds) values ('Insert AreaDoctor', @calcId, datediff(second, @startDate, getdate()))
	set @startDate = getdate()

	delete from @tableAreaDoctor
	where not exists
	(
		select *
		from @tableDoctor d
		join @tableArea ta on d.DivLpuId = ta.DivLpuId
		where d.id = DoctorId and ta.Id = AreaId
	);

	insert into [Log] (Value, CalcId, CalcSeconds) values ('Delete AreaDoctor', @calcId, datediff(second, @startDate, getdate()))
	set @startDate = getdate()

	delete from @tableAreaDoctor
	where not exists
	(
		select *
		from @tableDoctor td
		where td.Id = DoctorId
	);

	insert into [Log] (Value, CalcId, CalcSeconds) values ('Delete AreaDoctor', @calcId, datediff(second, @startDate, getdate()))
	set @startDate = getdate()

	insert into #tableScheduleCell
	select 
		T.c.value('@Id','uniqueidentifier'),
		T.c.value('@StartDate','datetime'), 
		T.c.value('@EndDate','datetime'),
		T.c.value('@State','tinyint'),
		T.c.value('@DoctorId','uniqueidentifier')
	from  @doc.nodes('/Data/ScheduleCells/S') T(c);

	insert into [Log] (Value, CalcId, CalcSeconds) values ('Insert ScheduleCell', @calcId, datediff(second, @startDate, getdate()))
	set @startDate = getdate()

	delete from #tableScheduleCell
	where DoctorId is null
		or not exists
	(
		select d.Id
		from @tableDoctor d
		where d.id = DoctorId
	);

	insert into [Log] (Value, CalcId, CalcSeconds) values ('Delete ScheduleCell', @calcId, datediff(second, @startDate, getdate()))
	set @startDate = getdate()

	declare @treatRegistryCellsAsFree bit;
	declare @newId uniqueidentifier;
	set @newId = NEWID();

	declare @divLpuId uniqueidentifier;
	declare @lpuId uniqueidentifier;
	
	select top 1
		@treatRegistryCellsAsFree = TreatRegistryCellsAsFree,
		@divLpuId = DivLpuId
	from ServiceApp
	where ISNULL(DivLpuId, @newId) in (select Id from @tableDivLpu);

	if (@treatRegistryCellsAsFree is null)
	begin
		select top 1
			@treatRegistryCellsAsFree = TreatRegistryCellsAsFree,
			@lpuId = LpuId
		from ServiceApp
		where ISNULL(LpuId, @newId) in (select Id from @tableLpu);
	end;

	if (@treatRegistryCellsAsFree is null)
	begin
		raiserror(N'Не найдена учетная запись организации.', 16, 1);
		return;
	end;

	if (@treatRegistryCellsAsFree = 1)
		update #tableScheduleCell
		set [State] = 0
		where [State] = 2;
	-----------------------------------------------------------------	
	
	insert into [Log] (Value, CalcId, CalcSeconds) values ('Before Transaction', @calcId, datediff(second, @startDate, getdate()))
	set @startDate = getdate()

	begin transaction;
	begin try
		insert into City (Id, Name)
		select Id, Name
		from @tableCity
		where Name not in (select Name from City)

		update tl
		set CityId = c.Id
		from @tableLpu tl
		inner join @tableCity tc on tl.CityId = tc.id
		inner join City c on c.Name = tc.Name
		
		insert into [Log] (Value, CalcId, CalcSeconds) values ('City', @calcId, datediff(second, @startDate, getdate()))
		set @startDate = getdate()

		--Lpu------------------------------
		update Lpu
		set CityId = tc.CityId
		from Lpu l
		inner join @tableLpu tc on l.Id = tc.Id

		insert into Lpu (Id, Name, CityId)
		select Id, Name, CityId
		from @tableLpu
		where Id not in (select Id from Lpu)

		insert into [Log] (Value, CalcId, CalcSeconds) values ('Lpu', @calcId, datediff(second, @startDate, getdate()))
		set @startDate = getdate()

		--DivLpu------------------------------
		update DivLpu
		set LpuId = tc.LpuId
		from DivLpu d
		inner join @tableDivLpu tc
			on d.Id = tc.Id

		insert into DivLpu (Id, Name, LpuId, Info)
		select Id, Name, LpuId, Info
		from @tableDivLpu
		where Id not in (select Id from DivLpu)

		insert into [Log] (Value, CalcId, CalcSeconds) values ('DivLpu', @calcId, datediff(second, @startDate, getdate()))
		set @startDate = getdate()

		--Specialist--------------------------
		update Specialist
		set Name = tc.Name,
			AdditionalText = tc.AdditionalText,
			IsLocal = case when tc.Name like '%участковый%' then 1 else 0 end
		from Specialist s
		inner join @tableSpecialist tc 
			on s.Id = tc.Id
		
		insert into Specialist (Id, Name, AdditionalText, IsLocal)
		select Id, Name, AdditionalText, case when Name like '%участковый%' then 1 else 0 end
		from @tableSpecialist
		where Id not in (select Id from Specialist)

		insert into [Log] (Value, CalcId, CalcSeconds) values ('Specialist', @calcId, datediff(second, @startDate, getdate()))
		set @startDate = getdate()

		--Area------------------------------
		delete from Area
		where DivLpuId in
		(
			select Id
			from @tableDivLpu
		)

		insert into Area (Id, DivLpuId, Name)
		select Id, DivLpuId, Name
		from @tableArea

		--AreaAddress------------------------------
		update AreaAddress
		set [Address] = n.[Address]
		from AreaAddress o
			join @tableAreaAddress n on n.Id = o.Id;

		insert into AreaAddress (Id, AreaId, [Address])
		select Id, AreaId, [Address]
		from @tableAreaAddress
		where Id not in (select Id from AreaAddress);

		insert into [Log] (Value, CalcId, CalcSeconds) values ('Area', @calcId, datediff(second, @startDate, getdate()))
		set @startDate = getdate()

		--Doctor------------------------------
		update Doctor 
		set 
			FirstName = tc.FirstName, 	
			SecondName = tc.SecondName,
			LastName = tc.LastName,
			SpecialityId = tc.SpecialityId,
			Deleted = null
		from Doctor d
		inner join @tableDoctor tc 
			on d.Id = tc.Id

		update Doctor
		set Deleted = GETDATE()
		from Doctor d
			join @tableDivLpu div on div.id = d.DivLpuId
		where d.Id not in 
		(select tc.Id from @tableDoctor tc)

		insert into Doctor(Id,FirstName,SecondName,LastName,SpecialityId,DivLpuId)
		select 
			Id,
			FirstName, 
			SecondName, 
			LastName, 
			SpecialityId,
			DivLpuId
		from @tableDoctor
		where Id not in (select Id from Doctor)

		--AreaDoctor------------------------------
		delete from AreaDoctor
		where DoctorId in
		(
			select doc.Id
			from Doctor doc
				join @tableDivLpu newDivLpu on newDivLpu.id = doc.DivLpuId
		);

		insert into AreaDoctor (AreaId, DoctorId)
		select AreaId, DoctorId
		from @tableAreaDoctor;

		insert into [Log] (Value, CalcId, CalcSeconds) values ('Doctor', @calcId, datediff(second, @startDate, getdate()))
		set @startDate = getdate()

		--App------------------------------
		update Appointment
		set [State] = 9
		where [State] = 0 and CellBegin < getdate()
		--Cell------------------------------
		delete ScheduleCell
		where Id not in (select Id from #tableScheduleCell)
		and DoctorId in (select Id from @tableDoctor)
		and Id not in (select ScheduleCellId from Appointment where [State] = 0 or [State] = 8)

		insert into [Log] (Value, CalcId, CalcSeconds) values ('ScheduleCell1', @calcId, datediff(second, @startDate, getdate()))
		set @startDate = getdate()
		
		--сначала те что не заняты
		update ScheduleCell
		set 
			StartDate = tc.StartDate,
			EndDate = tc.EndDate,
			State = tc.State
		from ScheduleCell sc
		inner join #tableScheduleCell tc 
			on sc.Id = tc.Id

		insert into [Log] (Value, CalcId, CalcSeconds) values ('ScheduleCell2', @calcId, datediff(second, @startDate, getdate()))
		set @startDate = getdate()

		insert into ScheduleCell (Id, StartDate,EndDate,DoctorId,State)
		select 
			Id,
			StartDate, 
			EndDate,
			DoctorId,
			State
		from #tableScheduleCell
		where Id not in (select Id from ScheduleCell)		

		insert into [Log] (Value, CalcId, CalcSeconds) values ('ScheduleCell3', @calcId, datediff(second, @startDate, getdate()))
		set @startDate = getdate()

		update ServiceApp set LastFullSync = getdate(), NeedFullSync = 0
		where (ISNULL(DivLpuId, @newId) in (select Id from @tableDivLpu))or(ISNULL(LpuId, @newId) in (select Id from @tableLpu))
		
		insert into [Log] (Value, CalcId, CalcSeconds) values ('ServiceApp', @calcId, datediff(second, @startDate, getdate()))
		set @startDate = getdate()
	commit transaction;

	end try
	begin catch
		declare @errorMessage	nvarchar(4000);
		declare @errorSeverity	int;
		declare @errorState		int;

		select
			@errorMessage	= ERROR_MESSAGE(),
			@errorSeverity	= ERROR_SEVERITY(),
			@errorState		= ERROR_STATE();

		rollback;

		raiserror(@errorMessage, @errorSeverity, @errorState);
	end catch
	insert into [Log] (Value, CalcId, CalcSeconds) values ('End', @calcId, datediff(second, @startDate1, getdate()))
END
