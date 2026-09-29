# SOC-CyberDeck Tools Integration Guide for Shuffle

## 🔗 Quick Reference - All Tool Connections

Use these pre-configured endpoints in your Shuffle workflows:

---

## 🔍 DFIR & Forensics

### Velociraptor
- **URL**: `https://{{SERVER_IP}}:7000`
- **API**: `https://{{SERVER_IP}}:7000/api/v1`
- **Username**: `admin`
- **Password**: `SOC-CyberDeck`
- **Use Cases**: Artifact collection, hunt execution, forensic analysis
- **Shuffle Apps**: HTTP, Velociraptor (if available)

---

## 🛡️ SIEM & Monitoring

### Wazuh Dashboard
- **URL**: `https://{{SERVER_IP}}:7001`
- **API**: `https://{{SERVER_IP}}:55000`
- **Username**: `admin`
- **Password**: `SecretPassword`
- **Use Cases**: Alert enrichment, log analysis, compliance checks
- **Shuffle Apps**: HTTP, Wazuh API

---

## 🧠 Threat Intelligence

### MISP
- **URL**: `https://{{SERVER_IP}}:7003`
- **API**: `https://{{SERVER_IP}}:7003/events`
- **Username**: `admin@admin.test`
- **Password**: `admin`
- **API Key**: Get from MISP UI → Administration → Automation
- **Use Cases**: IOC enrichment, threat correlation, intel sharing
- **Shuffle Apps**: MISP, HTTP

### MITRE ATT&CK Navigator
- **URL**: `http://{{SERVER_IP}}:7013`
- **Use Cases**: Attack mapping, technique visualization
- **Shuffle Apps**: HTTP

---

## 🤖 SOAR & Automation

### TheHive
- **URL**: `http://{{SERVER_IP}}:7005`
- **API**: `http://{{SERVER_IP}}:7005/api`
- **Username**: `admin@thehive.local`
- **Password**: `secret`
- **API Key**: Get from TheHive UI → admin → API Keys
- **Use Cases**: Case management, incident tracking, collaboration
- **Shuffle Apps**: TheHive, HTTP

### Cortex
- **URL**: `http://{{SERVER_IP}}:7006`
- **API**: `http://{{SERVER_IP}}:7006/api`
- **Username**: `admin`
- **Password**: `admin`
- **API Key**: Get from Cortex UI
- **Use Cases**: Observable analysis, automated enrichment
- **Shuffle Apps**: Cortex, HTTP

### Caldera
- **URL**: `http://{{SERVER_IP}}:7009`
- **API**: `http://{{SERVER_IP}}:7009/api/v2`
- **Username**: `admin`
- **Password**: `admin`
- **Use Cases**: Adversary emulation, attack simulation
- **Shuffle Apps**: HTTP

---

## 🔧 Utilities

### CyberChef
- **URL**: `http://{{SERVER_IP}}:7004`
- **Use Cases**: Data decoding, encoding, analysis
- **Shuffle Apps**: HTTP (for automation via API if needed)

### Arkime
- **URL**: `http://{{SERVER_IP}}:7008`
- **Username**: `admin`
- **Password**: `admin`
- **Use Cases**: Packet analysis, session search
- **Shuffle Apps**: HTTP

---

## 📊 Example Shuffle Workflow Snippets

### 1. Wazuh Alert → MISP Enrichment → TheHive Case

```
Trigger: Wazuh Webhook
↓
HTTP Request to MISP: Search IOC
↓
If IOC found → Create TheHive Case
↓
Notify via Email/Slack
```

### 2. File Hash Analysis

```
Input: File Hash
↓
VirusTotal Lookup
↓
MISP Search
↓
If Malicious → Velociraptor Hunt
↓
Quarantine + Create Case
```

### 3. Automated Threat Hunting

```
Schedule: Daily 9 AM
↓
Velociraptor: Run hunt artifact
↓
Parse results
↓
If matches found → MISP correlation
↓
TheHive case creation
```

---

## 🎯 Common Integration Patterns

### Pattern 1: Alert → Enrich → Case
```
Wazuh/Suricata Alert
→ Enrich with MISP
→ Analyze with Cortex
→ Create TheHive case
```

### Pattern 2: IOC → Hunt → Remediate
```
New IOC in MISP
→ Velociraptor hunt
→ Findings to TheHive
→ Caldera remediation test
```

### Pattern 3: Scheduled Analysis
```
Cron trigger
→ Collect logs
→ CyberChef decode
→ Wazuh ingest
→ Alert if suspicious
```

---

## ⚙️ Shuffle Configuration Tips

### HTTP App Settings

**For HTTPS tools (Velociraptor, MISP, Wazuh):**
- Disable SSL verification (lab environment)
- Add header: `Authorization: Bearer {api_key}`

**For Basic Auth tools:**
- Use built-in authentication in HTTP app
- Format: `username:password`

### Webhook Setup

**Wazuh → Shuffle:**
```xml
<!-- In Wazuh ossec.conf -->
<integration>
  <name>shuffle</name>
  <hook_url>http://{{SERVER_IP}}:7002/api/v1/hooks/webhook_YOUR_ID</hook_url>
  <level>3</level>
  <alert_format>json</alert_format>
</integration>
```

**Suricata → Shuffle:**
Configure EVE JSON output → Parse in Shuffle

---

## 🚀 Getting Started

1. **Access Shuffle**: `https://{{SERVER_IP}}:7002`
2. **Login**: `admin` / `password` (set on first use)
3. **Import workflow**: Click "Workflows" → "Import" → Upload .json
4. **Configure apps**: Click app → Add authentication
5. **Test**: Click "Run workflow"

---

## 📝 Notes

- All services on localhost network (cyberdeck-net Docker network)
- Use container names OR `{{SERVER_IP}}` for external access
- API keys should be created fresh (defaults shown for initial setup)
- Lab environment - SSL verification disabled

---

**Happy Automating! 🤖**

