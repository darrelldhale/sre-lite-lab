# Operations Log

# Operations Log

## 2026-05-20
- Started Track 2: Lab as a Living System
- Created morning-check.sh and added CANARY_NAME to config.sh
- Installed and authenticated GitHub CLI (gh)
- All 6 alarms: OK
- Canary: PASSING (3/3 last runs)
- VPC rejects: 10,698 (24h) — internet scanner noise, no new patterns, alarm OK
- GitHub Actions: 1 failed run at 00:45Z — intentional chaos test, smoke test caught
  bad image before ECR push, pipeline stopped correctly. Subsequent run at 00:55Z clean.
- Notes: morning-check.sh running cleanly, daily routine established
