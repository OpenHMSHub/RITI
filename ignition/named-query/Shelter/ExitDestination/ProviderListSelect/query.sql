---Participants/DrugScreen/ProviderListSelect--- 
SELECT
	id,providerName
FROM
	organization.Provider
WHERE
	[organization].[Provider].providerTypeId NOT IN (1,4,8)
ORDER BY providerName