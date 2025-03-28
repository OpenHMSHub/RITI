SELECT is_manual as edit, id , parameter_display_value , parameter , july_value, aug_value, 
sept_value, oct_value, nov_value, dec_value,  jan_value, feb_value,   march_value ,  april_value, may_value , june_value,
COALESCE(july_value,0) + 
COALESCE(aug_value ,0) + 
COALESCE(sept_value,0) + 
COALESCE(oct_value,0) + 
COALESCE(nov_value,0) + 
COALESCE(dec_value,0) + 
COALESCE(jan_value,0) + 
COALESCE(feb_value,0) + 
COALESCE(march_value,0) + 
COALESCE(april_value,0) + 
COALESCE(may_value,0) + 
COALESCE(june_value,0) as totalValue
FROM    participant.ResidentialDashboard 
where fiscal_year =  :fiscalYear and parameter in

('Recuperative Care Referrals Received',
'Recuperative Care Referrals Accepted',
'Recuperative Care Referrals Arrived',
'VA Referrals Received',
'VA Referrals Accepted',
'VA Referrals Arrived'
)