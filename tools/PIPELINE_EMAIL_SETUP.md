# 📧 Pipeline Email Notification Setup

## Overview

The pipeline now sends automated email notifications upon completion to a recipient defined in **GitLab CI/CD Variables**. This replaces the hardcoded email and allows flexible recipient configuration.

---

## Configuration Steps

### Step 1: Navigate to GitLab Project Settings

1. Go to your GitLab project: **tools/Viewer_NG**
2. Click **Settings** (left sidebar)
3. Click **CI/CD** in the sidebar
4. Click **Variables** section

### Step 2: Add PIPELINE_NOTIFICATION_EMAIL Variable

Click **Add variable** and fill in:

| Field | Value | Notes |
|-------|-------|-------|
| **Key** | `PIPELINE_NOTIFICATION_EMAIL` | Exact name (case-sensitive) |
| **Value** | `walid.abbassi@sagemcom.com` | Email recipient for pipeline notifications |
| **Type** | **Variable** (default) | Not File |
| **Scope** | All (or specific) | Select based on your needs |
| **Protect** | ✓ (optional) | Recommended to limit visibility |
| **Mask** | ✓ (optional) | Hides value in logs |

### Step 3: Add SMTP Credentials (Optional)

If using a corporate email server, also add:

| Key | Value | Notes |
|-----|-------|-------|
| `SMTP_SERVER` | `smtp.your-domain.com` | Email server hostname |
| `SMTP_PORT` | `587` | Usually 587 (TLS) or 25 (plain) |
| `SMTP_USER` | `your-username` | Email account username |
| `SMTP_PASSWORD` | `your-password` | Email account password (mark as Masked) |

**Default Values** (if not set):
- `SMTP_SERVER`: `smtp.gmail.com`
- `SMTP_PORT`: `587`
- `SMTP_USER`: Same as `PIPELINE_NOTIFICATION_EMAIL`

---

## Usage

### Automatic Trigger

The `notify_pipeline_completion` job runs **automatically** at the end of each merge request pipeline:

- **Stage**: `deploy`
- **Trigger**: Pipeline success on merge request
- **When**: `on_success` (only if previous jobs succeed)

### Manual Recipient Change

To change the recipient:

1. Go to **GitLab Project → Settings → CI/CD → Variables**
2. Click **Edit** on `PIPELINE_NOTIFICATION_EMAIL`
3. Change the email address
4. Click **Update variable**
5. Run next pipeline (email will be sent to new recipient)

---

## Email Contents

The notification email includes:

✅ **HTML formatted email** with:
- Pipeline status (✅ COMPLETED)
- Pipeline ID & MR reference
- Summary of all 11 agents' reports
- Complete list of artifacts

📎 **Attachments**:
- All agent reports (MD + HTML)
- Security findings
- Code review findings
- Test coverage data
- Dependency audit
- License compliance
- Documentation analysis
- Pipeline executive summary

---

## Troubleshooting

### Email Not Sent

1. **Check PIPELINE_NOTIFICATION_EMAIL is set**
   - Go to: Project → Settings → CI/CD → Variables
   - Verify `PIPELINE_NOTIFICATION_EMAIL` exists

2. **Check SMTP credentials**
   - If using corporate email, verify:
     - `SMTP_SERVER` is correct
     - `SMTP_PORT` is correct (usually 587 or 25)
     - `SMTP_USER` and `SMTP_PASSWORD` are valid

3. **Check pipeline logs**
   - Go to: Pipeline → Jobs → `notify_pipeline_completion`
   - Look for error messages in the job log

### Email Sent to Wrong Address

1. Verify `PIPELINE_NOTIFICATION_EMAIL` in GitLab Variables
2. Pipeline uses this value at runtime
3. Change value and run new pipeline

### "PIPELINE_NOTIFICATION_EMAIL is not configured" Error

- The variable is missing from GitLab CI/CD Settings
- Follow **Step 2** above to add it

---

## Implementation Details

### Files Modified

1. **`tools/send_pipeline_email.py`**
   - Now reads `PIPELINE_NOTIFICATION_EMAIL` from environment
   - No hardcoded email addresses
   - Validates email is configured before sending

2. **`.gitlab-ci.yml`**
   - New `notify_pipeline_completion` job (stage: deploy)
   - Triggered after successful pipeline completion
   - Checks if PIPELINE_NOTIFICATION_EMAIL is set
   - Calls `send_pipeline_email.py` with pipeline metadata

### Environment Variables Used

| Variable | Source | Purpose |
|----------|--------|---------|
| `PIPELINE_NOTIFICATION_EMAIL` | GitLab CI/CD Variables (manual) | Email recipient |
| `SMTP_SERVER` | GitLab CI/CD Variables (optional) | Email server |
| `SMTP_PORT` | GitLab CI/CD Variables (optional) | Email port |
| `SMTP_USER` | GitLab CI/CD Variables (optional) | Email username |
| `SMTP_PASSWORD` | GitLab CI/CD Variables (optional) | Email password (masked) |
| `CI_PIPELINE_ID` | GitLab CI (auto) | Pipeline ID for email subject |
| `CI_MERGE_REQUEST_IID` | GitLab CI (auto) | MR ID for email subject |

---

## Security Notes

✅ **Best Practices Implemented**:
- No hardcoded email addresses in code
- No hardcoded credentials in code
- All sensitive data in GitLab Variables (protected/masked)
- SMTP credentials should be marked as **Masked** in GitLab

⚠️ **Recommendations**:
- Use app-specific passwords for corporate email accounts
- Limit PIPELINE_NOTIFICATION_EMAIL visibility to CI/CD pipelines only
- Review who has access to project variables

---

## Testing

### Test Email Sending

To test without running full pipeline:

```powershell
# Windows PowerShell
$env:PIPELINE_NOTIFICATION_EMAIL = "test@example.com"
$env:CI_PIPELINE_ID = 12345
$env:CI_MERGE_REQUEST_IID = 48
python tools\send_pipeline_email.py --pipeline-id 12345 --mr-id 48 --artifacts-dir backend\reports
```

### Expected Output

```
======================================================================
🚀 Pipeline Email Notifier
======================================================================
Pipeline ID: 12345
MR ID: 48
Recipient: test@example.com
Artifacts Dir: backend\reports
======================================================================

📂 Collecting artifacts from: backend\reports
  ✓ security_scanner.md (17.4 KB)
  ✓ code_reviewer.md (14.8 KB)
  ...
✅ Collected 18 artifacts

📧 Preparing email...
  To: test@example.com
  Subject: TV-11441 - MR !48 Pipeline #12345 Completion Report

📎 Attaching 18 artifact files...
  ✓ Attached: security_scanner.md
  ...

🔗 Connecting to SMTP server: smtp.gmail.com:587

✅ Email successfully sent to test@example.com
```

---

## Next Steps

1. ✅ Add `PIPELINE_NOTIFICATION_EMAIL` to GitLab Variables
2. ✅ (Optional) Configure SMTP credentials if using corporate email
3. ✅ Run next merge request pipeline
4. ✅ Verify email is received at configured address
5. ✅ Adjust recipient as needed via GitLab Variables

---

*Email automation is now active and fully configurable via GitLab CI/CD Variables.*
