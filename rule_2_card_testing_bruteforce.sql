SELECT 
    user_identifier,
    Gateway,
    Type,
    MIN(operationDT) as attack_started_at,
    MAX(operationDT) as last_attempt_at,
    COUNT(DISTINCT id) as falied_attempts_count,   
    COUNT(DISTINCT Amount) as unique_amounts_tested   
FROM ayment_transactions    -- Replace with your actual table name
WHERE Status = 'declined'
AND operationDT >= NOW() - INTERVAL 15 MINUTE  
GROUP BY user_identifier, Gateway, Type,
HAVING falied_attempts_count >= 10   
ORDER BY falied_attempts_count DESC;
