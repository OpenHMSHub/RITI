--DECLARE 
--	 @dateRangeFrom datetime = ?
--	,@dateRangeTo datetime = ?
	
;WITH TableResidents as (SELECT f.id as facilityId, f.facilityName, f.allResidential as allResidential, concat (p.firstName , ' ', p.middleName , ' ' , p.lastName) as name, p.BirthDate, bl.eventStart, bl.eventEnd,
b.bedName, bl.participantId, bl.id as bedLogId, r.id as roomId, r.roomName, b.id as bedId, p.isActive, p.veteranId ,p.veteran,
CASE WHEN bl.exitDestinationId IS NULL THEN '' ELSE (SELECT destinationName FROM [lodging].[ExitDestination] where timeRetired is NULL 
AND id = bl.exitDestinationId) END AS ExitDestination,
COALESCE(bl.exitDestinationId, -1) AS exitDestinationId,
(SELECT RIGHT(hh.SSN, 4) FROM [participant].[Participant] pp, [humans].[Human] hh WHERE pp.id = p.[ID] AND pp.humanId = hh.id) as SSN,
p.gender, p.race, CAST((DATEDIFF(day, BirthDate, GetDate()))/365.25 as INT) as age
from
lodging.BedLog bl, lodging.Bed b, lodging.Room r, lodging.Facility f, participant.HistoryDashboard p
where f.timeRetired is null 
and b.timeRetired is null
and r.timeRetired is null
and bl.bedId = b.id 
and b.roomId = r.id and r.facilityId = f.id and bl.participantId = p.id
and (
(
(bl.eventStart >= :dateRangeFrom and bl.eventStart <= :dateRangeTo) or 
(bl.eventEnd >= :dateRangeFrom and bl.eventEnd <= :dateRangeTo)) or 
((bl.eventEnd is null or bl.eventEnd = '') and bl.eventStart <= :dateRangeTo)
OR  (bl.eventStart <= :dateRangeTo and bl.eventEnd >= :dateRangeTo))
) ,
TableAssociatedPrograms as (SELECT bl.id, COALESCE(b.ProgramName , '') AS AssociatedPrograms,
CONCAT(staffH.firstName, ' ', staffH.lastName) as staffName
FROM lodging.BedLog bl LEFT JOIN lodging.Reservation r
ON bl.reservationId = r.id
LEFT JOIN interaction.Program b
ON r.programId = b.id
LEFT JOIN participant.ProgramsHistory ph ON (
r.programId = ph.ProgramID 
and ph.ParticipantID = bl.participantId
  		and 
  		(((bl.eventStart >= ph.EntryDate and bl.eventStart <= ph.ExitDate) or
  		(bl.eventEnd >= ph.EntryDate and bl.eventEnd <= ph.ExitDate)) or 
  		((bl.eventEnd is null or bl.eventEnd = '') and bl.eventStart <= ph.ExitDate) or
  		((ph.ExitDate is NULL ) and bl.eventStart >= ph.EntryDate)))
LEFT JOIN staff.Employee staff ON ph.assignedStaffId = staff.id
LEFT JOIN humans.Human staffH ON staff.humanId = staffH.id
),
TableJoin as (
select distinct [TableResidents].facilityId, 
[TableResidents].isActive,
	[TableResidents].name, 
	[TableResidents].BirthDate,
	[TableResidents].eventStart, 
	[TableResidents].eventEnd,
	[TableResidents].ExitDestination,
	[TableResidents].exitDestinationId,
	[TableResidents].gender, 
	[TableResidents].race,
	[TableResidents].age,
	[TableResidents].SSN,
	[TableResidents].veteranId,
	[TableResidents].veteran,
	
	[TableAssociatedPrograms].AssociatedPrograms as associatedProgram,
	[TableResidents].facilityName, 
	[TableResidents].roomName,
	[TableResidents].bedName, 
	[TableResidents].participantId, 
	[TableResidents].bedLogId, 
	[TableResidents].roomId,  
	[TableResidents].bedId,
	[TableAssociatedPrograms].staffName as staffName
	from [TableResidents]
	JOIN
	[TableAssociatedPrograms] ON [TableAssociatedPrograms].id = [TableResidents].bedLogId
	)
select DISTINCT [TableJoin].facilityId,
	[TableJoin].isActive, 
	[TableJoin].name, 
	[TableJoin].BirthDate,
	[TableJoin].eventStart, 
	[TableJoin].eventEnd,
	[TableJoin].ExitDestination,
	[TableJoin].exitDestinationId,
	[TableJoin].gender, 
	[TableJoin].race, 
	[TableJoin].age,
	[TableJoin].associatedProgram,
	[TableJoin].facilityName,
	[TableJoin].roomName,
	[TableJoin].bedName, 
	[TableJoin].participantId, 
	[TableJoin].bedLogId, 
	[TableJoin].roomId,  
	[TableJoin].bedId,
	[TableJoin].SSN,
	[TableJoin].veteranId,
	[TableJoin].veteran,
	[TableJoin].staffName
	from [TableJoin]
	WHERE (1=1) 
AND TableJoin.[facilityName] in {shelter}
	AND TableJoin.[associatedProgram] in {program}
	AND ( TableJoin.[exitDestinationId] = :exitDestinationId OR :exitDestinationId IS NULL)
	AND ( TableJoin.[gender] = :gender OR :gender IS NULL)
	AND ( TableJoin.[race] = :race OR :race IS NULL)
	AND ( TableJoin.[age] >= :minAge OR :minAge IS NULL)
	AND ( TableJoin.[age] <= :maxAge OR :maxAge IS NULL)
	AND ( TableJoin.[veteranId] = :veteranId OR :veteranId IS NULL)
AND (
	:search_text = '' 
	OR [TableJoin].[name] LIKE CONCAT('%',:search_text,'%') 
	OR [TableJoin].[ExitDestination] LIKE CONCAT('%',:search_text,'%') 
	OR [TableJoin].[facilityName] LIKE CONCAT('%',:search_text,'%') 
	OR CAST([TableJoin].[age] AS VARCHAR(20))  LIKE CONCAT('%',:search_text,'%') 
	OR CONVERT(VARCHAR(10),[TableJoin].[eventStart],101) LIKE CONCAT('%',:search_text,'%') 
	OR CONVERT(VARCHAR(10),[TableJoin].[eventEnd],101) LIKE CONCAT('%',:search_text,'%')
	OR [TableJoin].[associatedProgram] LIKE CONCAT('%',:search_text,'%')
	OR [TableJoin].[roomName] LIKE CONCAT('%',:search_text,'%')
	OR [TableJoin].[bedName] LIKE CONCAT('%',:search_text,'%')
	OR [TableJoin].[race] LIKE CONCAT('%',:search_text,'%')
	OR [TableJoin].[gender] LIKE CONCAT('%',:search_text,'%')
	OR [TableJoin].[SSN] LIKE CONCAT(:search_text,'%')
)
ORDER BY [TableJoin].[facilityName]