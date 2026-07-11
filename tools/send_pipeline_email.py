#!/usr/bin/env python3
"""
Pipeline Email Notifier — Auto-send email at end of pipeline
Sends comprehensive pipeline report with all artifacts (reports, charts, findings, coverage data)

Usage:
  python send_pipeline_email.py --pipeline-id 24627 --mr-id 48 \
    --artifacts-dir backend/reports

Environment Variables (Required):
  PIPELINE_NOTIFICATION_EMAIL: Recipient email address (set in GitLab CI/CD Variables)
  CI_PIPELINE_ID: Pipeline ID (auto-set by GitLab CI)
  CI_MERGE_REQUEST_IID: MR ID (auto-set by GitLab CI)

Environment Variables (Optional):
  SMTP_SERVER: Email server (default: smtp.gmail.com)
  SMTP_PORT: Email port (default: 587)
  SMTP_USER: Email sender username (default: from PIPELINE_NOTIFICATION_EMAIL)
  SMTP_PASSWORD: Email sender password
"""

import os
import sys
import argparse
import smtplib
import json
from pathlib import Path
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email.mime.text import MIMEText
from email.utils import formatdate
from email import encoders
import requests
from datetime import datetime

class PipelineEmailNotifier:
    """Handles email sending for pipeline completion notifications"""
    
    def __init__(self, pipeline_id, mr_id, artifacts_dir=None):
        self.pipeline_id = pipeline_id
        self.mr_id = mr_id
        self.recipient = os.getenv("PIPELINE_NOTIFICATION_EMAIL", "")
        self.artifacts_dir = Path(artifacts_dir) if artifacts_dir else Path("backend/reports")
        
        # SMTP Configuration
        self.smtp_server = os.getenv("SMTP_SERVER", "smtp.gmail.com")
        self.smtp_port = int(os.getenv("SMTP_PORT", "587"))
        self.smtp_user = os.getenv("SMTP_USER", self.recipient)
        self.smtp_password = os.getenv("SMTP_PASSWORD", "")
        
        # GitLab Configuration
        self.gitlab_project_id = os.getenv("GITLAB_PROJECT_ID", "")
        self.gitlab_token = os.getenv("GITLAB_TOKEN", "")
        self.gitlab_url = os.getenv("CI_SERVER_URL", "https://gitlab-produits.rmm.scom")
        
        self.subject = f"TV-11441 - MR !{mr_id} Pipeline #{pipeline_id} Completion Report"
        self.attachments = []
    
    def collect_artifacts(self):
        """Collect all report artifacts from pipeline"""
        print(f"📂 Collecting artifacts from: {self.artifacts_dir}")
        
        if not self.artifacts_dir.exists():
            print(f"⚠️  Artifacts directory not found: {self.artifacts_dir}")
            return []
        
        artifact_files = []
        
        # Collect all markdown and HTML reports
        for ext in ["*.md", "*.html", "*.png", "*.json"]:
            files = list(self.artifacts_dir.glob(ext))
            for file in files:
                if file.is_file() and file.stat().st_size > 0:
                    artifact_files.append(file)
                    size_kb = file.stat().st_size / 1024
                    print(f"  ✓ {file.name:40} ({size_kb:7.1f} KB)")
        
        print(f"✅ Collected {len(artifact_files)} artifacts")
        return artifact_files
    
    def build_html_body(self):
        """Build HTML email body with pipeline summary"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        html = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset='UTF-8'>
            <style>
                body {{ font-family: Segoe UI, Arial, sans-serif; color: #333; line-height: 1.6; }}
                .header {{ background: #0078d4; color: white; padding: 20px; border-radius: 8px; margin-bottom: 20px; }}
                .section {{ background: #f5f5f5; padding: 15px; border-left: 4px solid #0078d4; margin: 15px 0; }}
                .status-success {{ color: #107c10; font-weight: bold; }}
                .status-warning {{ color: #ffb900; font-weight: bold; }}
                .status-critical {{ color: #d13438; font-weight: bold; }}
                .info-box {{ background: white; padding: 10px; margin: 10px 0; border: 1px solid #ddd; }}
                .artifact-list {{ display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px; }}
                .artifact-item {{ background: white; padding: 10px; border-radius: 4px; }}
                .footer {{ margin-top: 30px; font-size: 12px; color: #666; }}
            </style>
        </head>
        <body>
        
        <div class='header'>
            <h1>🎉 Pipeline Completion Notification</h1>
            <p><strong>Pipeline:</strong> #{self.pipeline_id} | <strong>MR:</strong> !{self.mr_id}</p>
            <p><strong>Status:</strong> <span class='status-success'>✅ COMPLETED</span></p>
            <p><strong>Timestamp:</strong> {timestamp} UTC</p>
        </div>
        
        <div class='section'>
            <h2>📊 Report Summary</h2>
            <p>Your pipeline has completed successfully. See attached comprehensive reports:</p>
            <ul>
                <li>Security Scanner Report (Anubis)</li>
                <li>Code Review Findings (Osiris)</li>
                <li>Test Coverage Analysis (TIA-Python, Laika-Flutter)</li>
                <li>Dependency Audit (Cassandra)</li>
                <li>License Compliance (Atlas)</li>
                <li>Documentation Analysis (Hermes)</li>
                <li>Pipeline Executive Summary (Vostok)</li>
                <li>Code Architecture Explanation (Themis)</li>
            </ul>
        </div>
        
        <div class='section'>
            <h2>📎 Attachments</h2>
            <p>All reports are included as attachments. Total: {len(self.attachments)} files</p>
            <div class='artifact-list'>
        """
        
        for i, file in enumerate(self.attachments):
            if i % 2 == 0:
                html += "<div>"
            size_kb = file.stat().st_size / 1024
            icon = "📄" if file.suffix in [".md", ".html"] else "📈" if file.suffix == ".png" else "📊"
            html += f"<div class='artifact-item'>{icon} {file.name} ({size_kb:.1f} KB)</div>"
            if i % 2 == 1 or i == len(self.attachments) - 1:
                html += "</div>"
        
        html += """
            </div>
        </div>
        
        <div class='section'>
            <h2>🔗 Quick Access</h2>
            <div class='info-box'>
                <p><strong>View in GitLab:</strong></p>
                <p>Navigate to your MR and check the pipeline status, job logs, and artifacts.</p>
            </div>
        </div>
        
        <div class='footer'>
            <p><em>This is an automated notification from Viewer NG CI/CD Pipeline.</em></p>
            <p>Pipeline ID: {self.pipeline_id} | MR: !{self.mr_id} | Branch: Update_Demo</p>
        </div>
        
        </body>
        </html>
        """
        
        return html
    
    def add_attachment(self, file_path):
        """Add file as attachment to email"""
        try:
            with open(file_path, 'rb') as attachment:
                part = MIMEBase('application', 'octet-stream')
                part.set_payload(attachment.read())
            
            encoders.encode_base64(part)
            part.add_header('Content-Disposition', f'attachment; filename= {file_path.name}')
            self.attachments.append(part)
            return True
        except Exception as e:
            print(f"❌ Error attaching {file_path.name}: {e}")
            return False
    
    def send_email(self):
        """Send email via SMTP"""
        try:
            print(f"\n📧 Preparing email...")
            print(f"  To: {self.recipient}")
            print(f"  Subject: {self.subject}")
            
            # Create message
            msg = MIMEMultipart('alternative')
            msg['From'] = self.smtp_user
            msg['To'] = self.recipient
            msg['Subject'] = self.subject
            msg['Date'] = formatdate(localtime=True)
            msg['X-Priority'] = '2'  # High priority
            
            # Build and attach HTML body
            html_body = self.build_html_body()
            msg.attach(MIMEText(html_body, 'html'))
            
            # Collect and attach artifacts
            artifacts = self.collect_artifacts()
            print(f"\n📎 Attaching {len(artifacts)} artifact files...")
            
            for artifact in artifacts:
                if self.add_attachment(artifact):
                    print(f"  ✓ Attached: {artifact.name}")
            
            print(f"\n🔗 Connecting to SMTP server: {self.smtp_server}:{self.smtp_port}")
            
            # Send email
            server = smtplib.SMTP(self.smtp_server, self.smtp_port)
            server.starttls()
            server.login(self.smtp_user, self.smtp_password)
            server.send_message(msg)
            server.quit()
            
            print(f"✅ Email successfully sent to {self.recipient}")
            return True
            
        except smtplib.SMTPAuthenticationError:
            print(f"❌ SMTP authentication failed. Check SMTP_USER and SMTP_PASSWORD.")
            return False
        except smtplib.SMTPException as e:
            print(f"❌ SMTP error: {e}")
            return False
        except Exception as e:
            print(f"❌ Error sending email: {e}")
            return False
    
    def run(self):
        """Main execution"""
        print("=" * 70)
        print("🚀 Pipeline Email Notifier")
        print("=" * 70)
        print(f"Pipeline ID: {self.pipeline_id}")
        print(f"MR ID: {self.mr_id}")
        print(f"Recipient: {self.recipient}")
        print(f"Artifacts Dir: {self.artifacts_dir}")
        print("=" * 70)
        
        return self.send_email()


def main():
    parser = argparse.ArgumentParser(
        description="Send pipeline completion email with all reports and artifacts"
    )
    parser.add_argument('--pipeline-id', type=int, help='Pipeline ID (default: CI_PIPELINE_ID)', 
                        default=os.getenv('CI_PIPELINE_ID', ''))
    parser.add_argument('--mr-id', type=int, help='Merge Request ID (default: CI_MERGE_REQUEST_IID)',
                        default=os.getenv('CI_MERGE_REQUEST_IID', ''))
    parser.add_argument('--artifacts-dir', help='Artifacts directory (default: backend/reports)',
                        default='backend/reports')
    
    args = parser.parse_args()
    
    # Validate required arguments
    if not args.pipeline_id or not args.mr_id:
        print("❌ Error: --pipeline-id and --mr-id are required (or set CI_PIPELINE_ID, CI_MERGE_REQUEST_IID)")
        sys.exit(1)
    
    recipient = os.getenv('PIPELINE_NOTIFICATION_EMAIL', '')
    if not recipient:
        print("❌ Error: PIPELINE_NOTIFICATION_EMAIL environment variable is not set")
        print("   Set this variable in GitLab Project → Settings → CI/CD → Variables")
        sys.exit(1)
    
    # Create notifier and send email
    notifier = PipelineEmailNotifier(
        pipeline_id=args.pipeline_id,
        mr_id=args.mr_id,
        artifacts_dir=args.artifacts_dir
    )
    
    success = notifier.run()
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
