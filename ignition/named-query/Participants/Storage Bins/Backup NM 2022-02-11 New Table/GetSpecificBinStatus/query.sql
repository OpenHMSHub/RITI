SELECT TOP 1
	*

FROM
	participant.vwStorageBinsLogDetails

WHERE
	col = :col
		AND
	bin = :bin

ORDER BY
	-- TODO: Check if this should be sorting on createdOn or startOn
	createdOn DESC