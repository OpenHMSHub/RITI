SELECT TOP 1
	*
FROM participant.MedicationBinsLog 
	

WHERE
	id = :id

ORDER BY
	-- TODO: Check if this should be sorting on createdOn or startOn
	createdOn DESC