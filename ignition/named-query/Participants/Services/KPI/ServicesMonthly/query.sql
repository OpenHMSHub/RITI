---Participants/Services/ServicesDashboardSelect---
DECLARE @activity_range AS INT = :activity_range;
--Calculate the begin and end activity dates
DECLARE	@activity_start AS DATE = DATEADD(day, (-1 * @activity_range), getdate())
	,@activity_end AS DATE = DATEADD(day,1,getdate());

SELECT COUNT(service_month) as totalParticipants, service_month
FROM
(
SELECT
	MONTH(s.serviceDate) as service_month

FROM
	participant.ServicesDashboard s
	LEFT JOIN
		(select id, veteranId, veteran from participant.Dashboard) p ON s.participantId = p.id

WHERE
 	s.serviceDate between @activity_start and @activity_end AND
 	
 	{serviceDate} AND
 	{HMIS} AND
 	{employeeId} AND
 	{programId} AND
 	{serviceId} AND
 	{firstName} AND
 	{middleName} AND
 	{lastName} AND
 	{nickName} AND
 	{search} AND
 	{serviceLocation} AND
 	{veteran} AND
 	{genderId}
)allData
GROUP BY service_month