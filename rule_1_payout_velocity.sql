-- Production SQL Query for Monitoring Velocity Fraud Attacks
-- Compatible with MySQL / Metabase

SELECT 
    user_identifier, -- Unique client/user identifier
    Amount,          -- Transaction amount
    MIN(operationDT) as first_transaction_at,
    MAX(operationDT) as last_transaction_at,
    
    -- Count only unique IDs to handle state-transition duplicates safely
    COUNT(DISTINCT id) as total_transactions_count,
    
    -- Calculate total volume processed during the burst
    SUM(DISTINCT Amount) * COUNT(DISTINCT id) as total_volume_amount,
    
    -- Time difference in minutes between the first and last transaction in the burst
    TIMESTAMPDIFF(MINUTE, MIN(operationDT), MAX(operationDT)) as minutes_passed

FROM payment_transactions -- Replace with your actual table name
WHERE Status IN ('completed', 'pending') -- Covers successful and active in-progress attacks
  AND Gateway = 'TX-001'                -- Filters by the specific compromised gateway (NDA friendly example)
  AND Type = 'payouts'                  -- Targets cash-out/withdrawal operations specifically
  
  -- Dynamic lookback window for real-time monitoring (checks the last 1 hour)
  AND operationDT >= NOW() - INTERVAL 1 HOUR

GROUP BY user_identifier, Amount

-- FRAUD TRIGGER CRITERIA:
-- Flags accounts triggering 10 or more identical amounts within a 60-minute window
HAVING total_transactions_count >= 10 
   AND minutes_passed <= 60

ORDER BY total_transactions_count DESC
