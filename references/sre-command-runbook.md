# SRE Command Runbook — First Responder Reference

> When something is on fire, you don't have time to Google.
> This is your first 10 minutes on any Linux server during an incident.

---

## 1. Orient Yourself First
> "Where am I, what is this machine, and how long has it been up?"

| Command | What it tells you |
|---------|------------------|
| `hostname` | Name of the server |
| `uname -r` | Kernel version |
| `cat /etc/os-release` | OS and version (Ubuntu vs CentOS vs Amazon Linux) |
| `uptime` | How long running, load averages for 1/5/15 min |
| `whoami && id` | Who you are and what groups you're in |
| `w` | Who else is logged in right now |

---

## 2. Is the Server Overwhelmed?
> "What is actually consuming resources right now?"

| Command | What it tells you |
|---------|------------------|
| `top -bn1 \| head -20` | Snapshot of top CPU consumers |
| `htop` | Interactive version of top (if installed) |
| `uptime` | Load average — if above CPU count, you're saturated |
| `vmstat 1 5` | CPU, memory, swap, I/O every 1 second, 5 times |
| `iostat -x 1 3` | Disk I/O — are you hitting a storage bottleneck? |
| `free -h` | Memory and swap usage in human readable form |
| `sar -u 1 5` | CPU history — was it bad before you arrived? |

**Load average rule of thumb:** Compare load to number of CPU cores.
- Load of 2.0 on a 4-core machine = 50% saturated (ok)
- Load of 4.0 on a 4-core machine = 100% saturated (investigate)
- Load of 8.0 on a 4-core machine = 200% saturated (on fire)

Check core count with: `nproc`

---

## 3. Find the Offending Process
> "Who is the culprit?"

| Command | What it tells you |
|---------|------------------|
| `ps aux --sort=-%cpu \| head -15` | Top CPU consumers |
| `ps aux --sort=-%mem \| head -15` | Top memory consumers |
| `ps aux \| grep <name>` | Find a specific process by name |
| `pgrep -a nginx` | Find PIDs of a named process |
| `lsof -p <PID>` | All files/sockets open by a process |
| `strace -p <PID>` | What system calls is this process making right now |
| `cat /proc/<PID>/cmdline \| tr '\0' ' '` | Exact command that launched this process |
| `cat /proc/<PID>/status` | Process state, memory, threads |

---

## 4. Is a Service Down?
> "What is systemd's view of the world?"

| Command | What it tells you |
|---------|------------------|
| `systemctl status <service>` | State, PID, memory, last log lines |
| `systemctl list-units --state=failed` | Everything systemd considers failed |
| `systemctl restart <service>` | Restart a service |
| `systemctl reload <service>` | Reload config without restarting (sends SIGHUP) |
| `journalctl -u <service> -f` | Follow a service's logs live |
| `journalctl -u <service> --since "30 min ago"` | Last 30 minutes of service logs |
| `journalctl -u <service> -p err` | Errors only |
| `journalctl --disk-usage` | How much space logs are consuming |

---

## 5. Is It a Network Problem?
> "Can this machine talk to the world, and can the world talk to it?"

| Command | What it tells you |
|---------|------------------|
| `ping -c 4 8.8.8.8` | Basic connectivity — can we reach the internet |
| `curl -I https://example.com` | HTTP response headers — is a URL reachable |
| `dig example.com` | DNS resolution — does DNS work |
| `nslookup example.com` | Alternative DNS check |
| `ss -tulnp` | All listening ports and which process owns them |
| `netstat -tulnp` | Same as ss (older systems) |
| `ss -s` | Socket summary — connection counts by state |
| `ip addr` | Network interfaces and IP addresses |
| `ip route` | Routing table — where does traffic go |
| `traceroute 8.8.8.8` | Hop-by-hop path to a destination |
| `curl -v telnet://<host>:<port>` | Is a specific port open on a remote host |

**Common port checks:**
- HTTP: 80 — HTTPS: 443 — SSH: 22
- MySQL: 3306 — Postgres: 5432 — Redis: 6379

---

## 6. Is It a Disk Problem?
> "Are we out of space or are we hammering the disk?"

| Command | What it tells you |
|---------|------------------|
| `df -h` | Disk space by filesystem — look for 90%+ |
| `du -sh /* 2>/dev/null \| sort -h` | What is consuming the most space at root |
| `du -sh /var/log/* \| sort -h` | Logs are often the culprit |
| `iostat -x 1 3` | Disk I/O utilization per device |
| `lsof \| grep deleted` | Files deleted but still held open (consuming space) |
| `findmnt` | All mounted filesystems |

**Space emergency:** If a disk is full and you need immediate relief:
```bash
journalctl --vacuum-size=500M   # trim logs to 500MB
```

---

## 7. Kill or Constrain a Process
> "I found the problem. Now I need to act."

| Command | What it tells you |
|---------|------------------|
| `kill <PID>` | Send SIGTERM — polite, allows cleanup |
| `kill -9 <PID>` | Send SIGKILL — immediate, no cleanup |
| `kill -1 <PID>` | Send SIGHUP — reload config |
| `pkill <name>` | Kill by process name |
| `killall <name>` | Kill all processes with this name |
| `renice +10 <PID>` | Lower a process's CPU priority (higher nice = lower priority) |
| `renice -5 <PID>` | Raise a process's CPU priority (requires sudo) |

**Signal order of operations:**
1. Try `kill <PID>` first (SIGTERM — graceful)
2. Wait 10-30 seconds
3. If still alive: `kill -9 <PID>` (SIGKILL — nuclear)

---

## 8. Check System Logs
> "What was the system doing before I arrived?"

| Command | What it tells you |
|---------|------------------|
| `journalctl -f` | Follow all system logs live |
| `journalctl --since "1 hour ago"` | Last hour of everything |
| `journalctl -p err --since today` | All errors since midnight |
| `journalctl -k` | Kernel messages only |
| `dmesg \| tail -50` | Kernel ring buffer — hardware errors, OOM kills |
| `dmesg -T \| grep -i error` | Kernel errors with human timestamps |
| `tail -f /var/log/syslog` | Traditional syslog (Ubuntu) |
| `tail -f /var/log/messages` | Traditional syslog (CentOS/RHEL) |

**OOM (Out of Memory) kills show up in dmesg:**
```bash
dmesg | grep -i "oom\|killed process"
```
If a process mysteriously disappeared, the OOM killer probably got it.

---

## 9. Check cgroups — Resource Boundaries
> "What resource limits are in place?"

| Command | What it tells you |
|---------|------------------|
| `cat /proc/<PID>/cgroup` | Which cgroup a process belongs to |
| `systemd-cgtop` | Live resource usage per cgroup (like top for cgroups) |
| `cat /sys/fs/cgroup/user.slice/cpu.max` | CPU limit for user slice |
| `systemctl show <service> \| grep -i memory` | Memory limit set for a service |

---

## 10. Snapshot the Scene Before You Change Anything
> "Document what you saw. Future you will thank present you."

Before touching anything on a production system:

```bash
# Capture a full snapshot
date >> ~/incident-$(date +%Y%m%d-%H%M).txt
uptime >> ~/incident-$(date +%Y%m%d-%H%M).txt
ps aux --sort=-%cpu | head -20 >> ~/incident-$(date +%Y%m%d-%H%M).txt
df -h >> ~/incident-$(date +%Y%m%d-%H%M).txt
free -h >> ~/incident-$(date +%Y%m%d-%H%M).txt
ss -tulnp >> ~/incident-$(date +%Y%m%d-%H%M).txt
journalctl -p err --since "1 hour ago" >> ~/incident-$(date +%Y%m%d-%H%M).txt
```

This gives you a timestamped file with the system state at the moment you arrived.
Save it. You'll need it for the post-mortem.

---

## Quick Reference — The First 5 Commands on Any Incident

```bash
uptime                          # 1. How bad is the load?
ps aux --sort=-%cpu | head -10  # 2. Who is eating CPU?
df -h                           # 3. Are we out of disk?
free -h                         # 4. Are we out of memory?
systemctl list-units --state=failed  # 5. What has systemd given up on?
```

If you only remember five commands, remember these five.

---

*Part of the SRE Lite Lab — Month 1, Week 1*
*https://github.com/darrelldhale/sre-lite-lab*
