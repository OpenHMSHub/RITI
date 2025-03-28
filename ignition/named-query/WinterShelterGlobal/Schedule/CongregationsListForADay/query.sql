SELECT
	l.id as 'locationId',
	s.id as 'scheduleId',
	l.locationName,
	s.totalBeds,
	CASE WHEN g.genderAccepted = 'Men Only' THEN 'Male'
	WHEN g.genderAccepted = 'Women Only' THEN 'Female'
	WHEN g.genderAccepted = 'Men or Women on Different Nights' THEN 'Male or Female'
	WHEN g.genderAccepted = 'Men & Women Together' THEN 'Male and Female' END AS gender,
	(SELECT CASE WHEN COUNT(participantId) > 0 THEN 'Checked-In'
	ELSE 'Scheduled' END AS status
	 FROM shelter.ScheduleParticipant 
	 WHERE scheduleId = s.id and locationId = l.id AND timeRetired IS NULL) as status, s.dayOfYear,
	 (SELECT ht.HostLocationType FROM shelter.LocationSeasonal sl , shelter.HostLocationType ht WHERE sl.hostLocationTypeId =  ht.id and sl.locationId = l.id and sl.seasonId = :seasonId ) as hostLocation
FROM shelter.Location l, shelter.Schedule s, shelter.Gender g
WHERE l.timeRetired is NULL AND s.dayOfYear =  :dayOfYear AND s.seasonId =  :seasonId 
AND l.id = s.locationId AND g.id = s.genderId AND s.timeCancelled is NULL
