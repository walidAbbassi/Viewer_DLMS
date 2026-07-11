# Configure GitLab CI/CD Variables for Pipeline Email Notification
# Usage: .\setup_gitlab_ci_variables.ps1 -ProjectId 2202 -Email walid.abbassi@sagemcom.com

param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectId = $env:CI_PROJECT_ID,
    
    [Parameter(Mandatory = $false)]
    [string]$Email = "walid.abbassi@sagemcom.com",
    
    [Parameter(Mandatory = $false)]
    [string]$GitLabUrl = $env:CI_SERVER_URL,
    
    [Parameter(Mandatory = $false)]
    [string]$GitLabToken = $env:GITLAB_TOKEN,
    
    [switch]$DryRun = $false
)

$ErrorActionPreference = 'Stop'

# Colors
$E = [char]27
$G = "$($E)[32m"; $Y = "$($E)[33m"; $R = "$($E)[31m"; $C = "$($E)[36m"; $X = "$($E)[0m"

function Banner([string]$title) {
    Write-Host "`n$C╔════════════════════════════════════════════════════════╗$X"
    Write-Host "$C║  $title$(' ' * (50 - $title.Length))║$X"
    Write-Host "$C╚════════════════════════════════════════════════════════╝$X`n"
}

function Ok([string]$msg) { Write-Host "$G✅ $msg$X" }
function Warn([string]$msg) { Write-Host "$Y⚠️  $msg$X" }
function Fail([string]$msg) { Write-Host "$R❌ $msg$X" }
function Info([string]$label, [string]$value) { Write-Host "  $C$label$X  $value" }

Banner "GitLab CI/CD Variable Setup - Pipeline Email Notification"

# Validate inputs
if (-not $ProjectId) {
    Fail "ProjectId is required (use -ProjectId or CI_PROJECT_ID env var)"
    exit 1
}

if (-not $GitLabToken) {
    Fail "GitLabToken is required (use -GitLabToken or GITLAB_TOKEN env var)"
    exit 1
}

if (-not $GitLabUrl) {
    $GitLabUrl = "https://gitlab-produits.rmm.scom"
    Warn "GitLabUrl not provided, using default: $GitLabUrl"
}

Info "Project ID" $ProjectId
Info "Email" $Email
Info "GitLab URL" $GitLabUrl
Info "Dry Run" $(if ($DryRun) { "YES" } else { "NO" })
Write-Host ""

# Define variables to set
$variables = @(
    @{
        key          = "PIPELINE_NOTIFICATION_EMAIL"
        value        = $Email
        variable_type = "env_var"
        protected    = $false
        masked       = $false
        description  = "Email recipient for pipeline completion notifications"
    }
)

Write-Host "$C→ Variables to configure:$X"
foreach ($var in $variables) {
    Write-Host "  • $($var.key) = $($var.value)"
}
Write-Host ""

try {
    Write-Host "$C→ Connecting to GitLab API...$X"
    
    $headers = @{
        'PRIVATE-TOKEN' = $GitLabToken
        'Content-Type'  = 'application/json'
    }
    
    # Test connection
    $testUri = "$GitLabUrl/api/v4/projects/$ProjectId"
    $test = Invoke-WebRequest -Uri $testUri -Headers $headers -UseBasicParsing -TimeoutSec 10
    Ok "Connected to GitLab (project ID: $ProjectId)"
    
    # Process each variable
    foreach ($var in $variables) {
        Write-Host "`n$C→ Processing variable: $($var.key)$X"
        
        $body = @{
            key            = $var.key
            value          = $var.value
            variable_type  = $var.variable_type
            protected      = $var.protected
            masked         = $var.masked
        } | ConvertTo-Json
        
        $uri = "$GitLabUrl/api/v4/projects/$ProjectId/variables/$($var.key)"
        
        if ($DryRun) {
            Info "Mode" "DRY-RUN (no changes will be made)"
            Write-Host "  POST $uri"
            Write-Host "  Body: $body"
            Ok "DRY-RUN: Would set $($var.key) = $($var.value)"
        } else {
            try {
                # Try to update existing variable
                Invoke-WebRequest -Uri $uri -Method PUT -Headers $headers -Body $body -UseBasicParsing -TimeoutSec 10 | Out-Null
                Ok "Updated variable: $($var.key)"
            } catch {
                if ($_.Exception.Response.StatusCode -eq 404) {
                    # Variable doesn't exist, create it
                    $createUri = "$GitLabUrl/api/v4/projects/$ProjectId/variables"
                    Invoke-WebRequest -Uri $createUri -Method POST -Headers $headers -Body $body -UseBasicParsing -TimeoutSec 10 | Out-Null
                    Ok "Created variable: $($var.key)"
                } else {
                    throw $_
                }
            }
        }
        
        Info "Key" $var.key
        Info "Value" $var.value
        Info "Protected" $(if ($var.protected) { "Yes" } else { "No" })
        Info "Masked" $(if ($var.masked) { "Yes" } else { "No" })
    }
    
    Write-Host "`n$C═══════════════════════════════════════════════════════════$X"
    Ok "All variables configured successfully!"
    Write-Host "$C═══════════════════════════════════════════════════════════$X"
    
    Write-Host "`n$G📋 Next Steps:$X"
    Write-Host "  1. Run next pipeline to test email notification"
    Write-Host "  2. Check pipeline logs: notify_pipeline_completion job"
    Write-Host "  3. Verify email received at: $Email"
    Write-Host "  4. To change recipient: Update PIPELINE_NOTIFICATION_EMAIL in GitLab UI"
    Write-Host ""
    
    Write-Host "$G✨ Pipeline email notification is now configured!$X`n"
    
} catch {
    Fail "Error: $($_.Exception.Message)"
    exit 1
}
