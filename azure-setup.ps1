# Azure Resources Setup Script

# This PowerShell script creates the required Azure resources for the zero-downtime deployment solution

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory=$true)]
    [string]$WebAppName,
    
    [Parameter(Mandatory=$true)]
    [string]$Location = "East US",
    
    [Parameter(Mandatory=$true)]
    [string]$AppServicePlanName,
    
    [Parameter(Mandatory=$false)]
    [string]$SubscriptionId
)

# Set subscription if provided
if ($SubscriptionId) {
    Set-AzContext -SubscriptionId $SubscriptionId
}

Write-Host "Creating Azure resources for zero-downtime deployment..."

# Create Resource Group
Write-Host "Creating Resource Group: $ResourceGroupName"
try {
    $rg = New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Force
    Write-Host "✓ Resource Group created successfully"
} catch {
    Write-Error "Failed to create Resource Group: $($_.Exception.Message)"
    throw
}

# Create App Service Plan (Standard tier minimum for deployment slots)
Write-Host "Creating App Service Plan: $AppServicePlanName"
try {
    $asp = New-AzAppServicePlan -ResourceGroupName $ResourceGroupName -Name $AppServicePlanName -Location $Location -Tier "Standard" -NumberofWorkers 1 -WorkerSize "Small"
    Write-Host "✓ App Service Plan created successfully"
} catch {
    Write-Error "Failed to create App Service Plan: $($_.Exception.Message)"
    throw
}

# Create Web App
Write-Host "Creating Web App: $WebAppName"
try {
    $webapp = New-AzWebApp -ResourceGroupName $ResourceGroupName -Name $WebAppName -Location $Location -AppServicePlan $AppServicePlanName
    Write-Host "✓ Web App created successfully"
} catch {
    Write-Error "Failed to create Web App: $($_.Exception.Message)"
    throw
}

# Create deployment slots
Write-Host "Creating deployment slots..."

# Create Blue slot
try {
    $blueSlot = New-AzWebAppSlot -ResourceGroupName $ResourceGroupName -Name $WebAppName -Slot "blue"
    Write-Host "✓ Blue deployment slot created"
} catch {
    Write-Error "Failed to create Blue slot: $($_.Exception.Message)"
    throw
}

# Create Green slot
try {
    $greenSlot = New-AzWebAppSlot -ResourceGroupName $ResourceGroupName -Name $WebAppName -Slot "green"
    Write-Host "✓ Green deployment slot created"
} catch {
    Write-Error "Failed to create Green slot: $($_.Exception.Message)"
    throw
}

# Configure slot settings to not swap
Write-Host "Configuring slot-specific settings..."

$slotSettings = @(
    "SlotName",
    "ASPNETCORE_ENVIRONMENT"
)

try {
    # Configure slot settings for the main app
    Set-AzWebAppSlotConfigName -ResourceGroupName $ResourceGroupName -Name $WebAppName -AppSettingNames $slotSettings
    Write-Host "✓ Slot-specific settings configured"
} catch {
    Write-Warning "Could not configure slot settings: $($_.Exception.Message)"
}

# Output summary
Write-Host ""
Write-Host "=== Azure Resources Created Successfully ==="
Write-Host "Resource Group: $ResourceGroupName"
Write-Host "App Service Plan: $AppServicePlanName"
Write-Host "Web App: $WebAppName"
Write-Host "Production URL: https://$WebAppName.azurewebsites.net"
Write-Host "Blue Slot URL: https://$WebAppName-blue.azurewebsites.net"
Write-Host "Green Slot URL: https://$WebAppName-green.azurewebsites.net"
Write-Host ""
Write-Host "Next Steps:"
Write-Host "1. Configure your Octopus Deploy project variables"
Write-Host "2. Set up Azure Service Principal for Octopus"
Write-Host "3. Import the deployment process JSON"
Write-Host "4. Deploy your first application to begin the blue-green cycle"
