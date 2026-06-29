# Real-Time Financial Fraud Detection (SQL Monitoring Tool)

## 📌 Business Case & Problem Statement
In digital payment platforms and billing systems, high-frequency velocity attacks are a critical security and financial risk. A recent real-world incident involved a malicious entity triggering over 40 identical cash-out/payout requests within a short timeframe to drain system balances before standard batch security gates could activate.

As a Financial Analyst, I designed and implemented this **production-ready SQL (MySQL) monitoring query** to instantly detect these specific behavioral anomalies directly inside our data warehouse via Metabase.

*Note: All table names, column names, status codes, and gateway identifiers in this repository have been fully anonymized and generalized to strictly comply with corporate NDA corporate policies.*

## 🛠️ The Technical Logic & Optimization
To handle real-time monitoring without degrading database performance under heavy transaction loads, the query avoids heavy window functions (`ROWS BETWEEN`) and instead utilizes highly efficient indexed **SQL Aggregation (`GROUP BY` and `HAVING`)**:

1. **Early Filter Application**: Restricts the dataset to successful/in-progress states and a specific payment gateway at the entry point (`WHERE`), instantly dropping 99% of irrelevant historical data.
2. **Dynamic Sliding Horizon**: Uses a live sliding window (`NOW() - INTERVAL 1 HOUR`) to evaluate telemetry continuously.
3. **Idempotency Control**: Employs `COUNT(DISTINCT transaction_id)` to prevent calculation inflation caused by state-transition rows (where a single financial order generates separate log entries for 'In-Progress' and 'Success' states).
4. **Velocity Threshold Filtering**: The `HAVING` clause filters out regular users, isolating only accounts executing 10+ identical transaction amounts within a 60-minute window.

## 💾 Repository Structure
* `fraud_detector.sql` — The optimized SQL monitoring code used for real-time alerts.

## 🚀 Future Automation (Production Framework)
In a live production environment, this query is scheduled to run every 30 seconds via a lightweight daemon script. If the query returns any rows, a Python webhook automatically forwards a high-priority payload to corporate communication channels (such as Slack or Microsoft Teams) alerting the risk operations team for immediate account suspension:

```text
🚨 POSSIBLE FRAUD DETECTED 🚨
• User ID: [User_Identifier]
• Pattern: 40 identical transactions within 41 minutes.
• Action Required: Immediate account freeze.
```
