;WITH cteEvent AS (
SELECT 
	 [EventAttendance].[id]
	,[EventAttendance].[eventId]
	,[EventAttendance].[humanId]
	,[EventAttendance].[checkin]
	,[EventAttendance].[checkout]
	,[EventAttendance].[autonote]
	,[Gender].[genderName]
	,[Participant].[id] AS [Participant_id]
	,CONCAT_WS(' ', [Human].[firstName],[Human].[middleName],[Human].[lastName]) AS [ParticipantName]
	,[Human].[genderId]
	,[Human].[dob]
	,RIGHT([Human].[SSN], 4) as SSN
	,DATEDIFF(year,[Human].[dob],GETDATE()) AS [Age]
	,[CalendarEvents].[calendarId]
	,[CalendarEvents].[name] AS [CalendarEvents_name]
	,[CalendarEvents].[description]
	,[CalendarEvents].[duration]
	,CASE WHEN [Participant].timeRetired IS NULL THEN 1
	ELSE 0 END as isActive
	,(SELECT COUNT(p.[humanId])
	FROM [calendar].[EventAttendance] e
		INNER JOIN [humans].[Human] h ON h.[id] = e.[humanId]
		INNER JOIN [participant].[Participant] p ON p.[humanId] = h.[id]
		where e.eventId =[EventAttendance].[eventId]) AS Attendance
FROM [calendar].[EventAttendance]
	INNER JOIN [humans].[Human] ON [Human].[id] = [EventAttendance].[humanId]
	INNER JOIN [participant].[Participant] ON [Participant].[humanId] = [Human].[id]
	INNER JOIN [humans].[Gender] ON [Gender].[id] = [Human].[genderId]

	LEFT JOIN [calendar].[CalendarEvents] ON [CalendarEvents].[id] = [EventAttendance].[eventId]
)

,cteInOut AS (
SELECT 
	 [id] AS [EventAttendanceId]
	,[eventId]
	,[humanId]
	,[genderId]
	,[dob]
	,SSN
	,[Age]
	,[Participant_id]
	,[checkin] AS [TimeStamp]
	,[ParticipantName]
	,[calendarId]
	,[CalendarEvents_name]
	,1 AS [checkIO]
	,'checkin' AS [CheckInOut]
	,[genderName]
	,isActive
	,[description]
	,[duration]
	
	,[Attendance]
FROM cteEvent
WHERE checkin IS NOT NULL
UNION ALL
SELECT 
	 [id] AS [EventAttendanceId]
	,[eventId]
	,[humanId]
	,[genderId]
	,[dob]
	,SSN
	,[Age]
	,[Participant_id]
	,[checkout] AS [TimeStamp]
	,[ParticipantName]
	,[calendarId]
	,[CalendarEvents_name]
	,0 AS [checkIO]
	,'checkout' AS [CheckInOut]
	,[genderName]
	,isActive
	,[description]
	,[duration]
	
	,[Attendance]
FROM cteEvent
WHERE checkout IS NOT NULL
)

SELECT 
	[Participant_id] AS [id]
	,[ParticipantName] AS [Participant Name]
	,[dob] AS [Birth Date]
	,[genderName] AS [Gender]
	,[CalendarEvents_name]  AS [Event]
	,[CheckInOut] AS [Check In/Out]
	,[TimeStamp] AS [Date]
	,SSN
	,[Age]
	,[EventAttendanceId]
	,[eventId]
	,[checkIO]
	,[humanId]
	,[genderId]
	,[calendarId]
	,isActive
	,[duration] AS [Duration(Hours)]
	,[Attendance]
	,ISNULL([description],'') AS [Description]
	
FROM cteInOut
WHERE [Participant_id] = :participantId
	AND ([calendarId] = :calendarId OR :calendarId IS NULL OR :calendarId = -1)
	AND ([CalendarEvents_name] = :calEventName OR :calEventName IS NULL)
	AND ([TimeStamp] >= :dateFrom OR :dateFrom IS NULL)
	AND ([TimeStamp] <= :dateTo OR :dateTo IS NULL)
	AND (
		:searchText = '' 
		OR :searchText IS NULL 
		OR [description] LIKE CONCAT('%',:searchText,'%') 
		OR [CalendarEvents_name] LIKE CONCAT('%',:searchText,'%') 
		
)