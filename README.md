## 🛠️ The Anti-Fraud Logic & Architecture
To scale monitoring without overloading data warehouses, the system is split into three production-ready, highly optimized SQL modules. Each module targets a specific fraudulent behavior and runs via scheduled Metabase cron-refresh windows:

### 📑 1. Payout Velocity Attack Detector (`rule_1_payout_velocity.sql`)
* **Target:** Malicious merchants or compromised accounts draining balances via high-frequency identical payout bursts.
* **Logic:** Isolates transaction streams using dynamic windows (`NOW() - INTERVAL 1 HOUR`) and aggregates telemetry by user and amount. Flags accounts generating 10+ duplicate transactions. Uses `COUNT(DISTINCT id)` to remain idempotent against state-transition log duplicates.

### 📑 2. Card Testing & Bruteforce Monitor (`rule_2_card_testing_bruteforce.sql`)
* **Target:** Automated scripts testing stolen card credentials by guessing transaction thresholds.
* **Logic:** Continuously tracks hard-declined signals (`Status = 'declined'`) within a narrow 15-minute sliding horizon. Rings an operational alarm if a single user identity hits 10 or more failures across any gateway.

### 📑 3. Gateway Hopping Anomalies (`rule_3_gateway_hopping.sql`)
* **Target:** Fraudsters attempting to bypass transaction limits by rapidly shuffling between different payment processing routes.
* **Logic:** Measures infrastructural velocity by counting unique gateways utilized by a single account over the last hour. Triggers an alert if `COUNT(DISTINCT Gateway) >= 3`.
