INSERT INTO lodging.AuditLog (bedLogId, reservationId, bedId, participantId, action, employeeId, userName, actionTime )
VALUES ( :bedLogId, :reservationId,  :bedId ,  :participantId , :action,  :employeeId ,  :userName , current_timestamp)