# SOC-CyberDeck Shuffle Workflow Templates

## 📦 Pre-Built Workflows

These workflows are ready to import into Shuffle for common SOC operations.

### Available Workflows:

1. **integration-test.json** - Simple workflow to test all SOC-CyberDeck tool connections
   - Tests connectivity to Wazuh, MISP, TheHive, Velociraptor
   - Verifies API endpoints
   - Good for validating your setup

2. **Coming Soon:**
   - Malware analysis automation
   - Alert triage workflow
   - Incident response playbook
   - Threat hunting automation

---

## 📥 How to Import

### Method 1: Via Shuffle UI
1. Access Shuffle: `https://YOUR_IP:7002`
2. Login with admin credentials
3. Click "Workflows" → "New Workflow" → "Import"
4. Upload the .json file
5. Configure any API keys if needed
6. Click "Save"

### Method 2: Via SOC-CyberDeck Portal (Coming Soon)
- Portal will have one-click import buttons

---

## 🔧 After Import

1. **Review the workflow** - Understand each step
2. **Configure APIs** - Add authentication for tools
3. **Test execution** - Click "Run" to test
4. **Customize** - Modify for your needs

---

## 🎓 Learning Resources

- Shuffle Documentation: https://shuffler.io/docs
- SOC-CyberDeck Integration Guide: See `integration-guide/CYBERDECK_TOOLS_INTEGRATION.md`
- Tool-specific APIs: Check each tool's documentation

---

## 💡 Tips

- Start with integration-test workflow to verify setup
- Use SOC-CyberDeck's default credentials (documented in integration guide)
- Test workflows in Shuffle before deploying to production
- All tools are on the same Docker network for easy communication

Happy Automating! 🚀

