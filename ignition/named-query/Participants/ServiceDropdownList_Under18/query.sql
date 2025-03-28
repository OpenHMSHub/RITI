---Participants/ServiceDropdownList---
SELECT
	[interaction].[Service].id,[interaction].[Service].serviceName as 'service_name'
FROM
	[interaction].[Service]
	INNER JOIN [interaction].[ProgramService]
	ON [interaction].[ProgramService].serviceId = [interaction].[Service].id
WHERE
	[interaction].[ProgramService].programId =  :program_id 

	AND
	[interaction].[Service].allowUnder18 = 1
	AND 
	[interaction].[Service].timeRetired IS NULL
ORDER BY service_name