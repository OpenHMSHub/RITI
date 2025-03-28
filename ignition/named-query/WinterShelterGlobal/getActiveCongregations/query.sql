SELECT
	cong.id AS 'congregationId',
	prov.providerName AS 'congregationName',
	cong.breezeId AS 'breezeId' 
FROM
	shelter.Location loc
LEFT JOIN
	organization.Congregation cong ON loc.congregationId = cong.Id
LEFT JOIN 
	organization.Provider prov ON cong.providerId = prov.id
WHERE
	cong.timeRetired is NULL
