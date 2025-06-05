[CmdletBinding()]
param(
    [Parameter(Position=0, ValueFromRemainingArguments=$true)]
    [string[]]$TerraformArgs
)

# Stop on any error
$ErrorActionPreference = "Stop"

try {
    # Check for .env file in current or parent directory
    $envPath = $null
    if (Test-Path .env) {
        $envPath = ".env"
    } elseif (Test-Path ..\.env) {
        $envPath = "..\.env"
    } else {
        # Create a minimal .env file with required variables
        $envPath = ".env"
        @"
resource_group_name=nodejs-aks-rg
location=northeurope
cluster_name=aks-cluster
"@ | Out-File -FilePath $envPath
        Write-Host "Created minimal .env file" -ForegroundColor Yellow
    }
    
    # Set Azure authentication environment variables
    if (Test-Path $envPath) {
        $envContent = Get-Content $envPath -Raw
        if ($envContent -match 'AZURE_SUBSCRIPTION_ID=([^\r\n]+)') {
            [Environment]::SetEnvironmentVariable("ARM_SUBSCRIPTION_ID", $matches[1])
            Write-Host "Set ARM_SUBSCRIPTION_ID"
        }
        if ($envContent -match 'AZURE_TENANT_ID=([^\r\n]+)') {
            [Environment]::SetEnvironmentVariable("ARM_TENANT_ID", $matches[1])
            Write-Host "Set ARM_TENANT_ID"
        }
        if ($envContent -match 'AZURE_CLIENT_ID=([^\r\n]+)') {
            [Environment]::SetEnvironmentVariable("ARM_CLIENT_ID", $matches[1])
            Write-Host "Set ARM_CLIENT_ID"
        }
        if ($envContent -match 'AZURE_CLIENT_SECRET=([^\r\n]+)') {
            $secretValue = $matches[1]
            # Check if the value is a placeholder
            if ($secretValue -eq "<YOUR_CLIENT_SECRET_HERE>") {
                Write-Host "Error: Azure client secret is set to a placeholder value. Please update your .env file with the actual secret." -ForegroundColor Red
                throw "Invalid Azure client secret"
            }
            [Environment]::SetEnvironmentVariable("ARM_CLIENT_SECRET", $secretValue)
            Write-Host "Set ARM_CLIENT_SECRET"
        }
    }

    Write-Host "Loading environment variables from $envPath file..." -ForegroundColor Cyan

    # Read .env file and set environment variables
    Get-Content $envPath | ForEach-Object {
        if ($_ -match '^([^#][^=]+)=(.+)$') {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()
            
            # Set TF_VAR_ environment variable
            $tfVarName = "TF_VAR_" + $name.ToLower()
            [Environment]::SetEnvironmentVariable($tfVarName, $value)
            Write-Host "Set $tfVarName"
        }
    }

    Write-Host "Environment variables loaded successfully" -ForegroundColor Green
    
    # Navigate to terraform environment directory
    $terraformDir = $null
    if (Test-Path .\terraform\environments\dev) {
        $terraformDir = ".\terraform\environments\dev"
    } elseif (Test-Path ..\terraform\environments\dev) {
        $terraformDir = "..\terraform\environments\dev"
    } elseif (Test-Path .\terraform) {
        $terraformDir = ".\terraform"
    } elseif (Test-Path ..\terraform) {
        $terraformDir = "..\terraform"
    }
    
    if ($terraformDir) {
        Write-Host "Changing to directory: $terraformDir" -ForegroundColor Cyan
        Push-Location $terraformDir
    } else {
        Write-Host "Warning: No terraform directory found" -ForegroundColor Yellow
    }
    
    Write-Host "Running: terraform $($TerraformArgs -join ' ')" -ForegroundColor Cyan

    # Execute terraform with all passed arguments
    & terraform $TerraformArgs
    
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform command failed with exit code $LASTEXITCODE"
    }
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}
finally {
    # Return to original directory if we changed it
    if ($terraformDir) {
        Pop-Location
    }
}