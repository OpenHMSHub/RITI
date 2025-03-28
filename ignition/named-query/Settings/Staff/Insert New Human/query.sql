Insert into [humans].Human (
	firstName,
	middleName,
	lastName, 
	suffix,
	dob,
	dobQualityId,
	SSN,
	ssnQualityId,
	genderId,
	raceId,
	ethnicityId,
	veteranStatusId,
	phone,
	altPhone,
	email,
	timeCreated
)
Values (
	:firstName,
	:middleName,
	:lastName,
	:suffix,
	:dob,
	6,
	'123456789', 
	6,
	:genderId,
	8,
	4,
	4,
	:phone,
	:altPhone,
	:email,
	GetDate()
)