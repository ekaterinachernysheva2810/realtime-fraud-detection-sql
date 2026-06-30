SELECT 
    user_identifier,
    Type,
    MIN(operationDT) as first_active_DT,
    MAX(operationDT) as last_active_DT,
    COUNT(DISTINCT Gateway) as unique_gateways_used,
    COUNT(DISTINCT id) as total_attempts_count
FROM payment_transactions        -- Replace with your actual table name
WHERE Status IN ('completed', 'pending', 'declined') 
  AND operationDT >= NOW() - INTERVAL 1 HOUR
GROUP BY user_identifier, Type
  -- FRAUD TRIGGER CRITERIA:
HAVING unique_gateways_used >= 3
ORDER BY unique_gateways_used DESC;
