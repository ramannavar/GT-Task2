# Octopus Deploy Variables Configuration

This file contains the complete list of variables that need to be configured in your Octopus Deploy project for the zero-downtime deployment solution.

## Project Variables

### Required Variables

| Variable Name | Value | Scope | Description |
|---------------|-------|-------|-------------|
| `Azure.Account` | `azure-service-principal` | All | Azure Account ID in Octopus |
| `Azure.WebApp.Name` | `your-webapp-name` | All | Name of the Azure Web App |
| `Azure.ResourceGroup` | `your-resource-group` | All | Azure Resource Group name |
| `Azure.SubscriptionId` | `your-subscription-id` | All | Azure Subscription ID |
| `Azure.CurrentSlot` | `blue` | Production | Currently active deployment slot |
| `Azure.DeploymentSlot.Blue` | `blue` | All | Blue slot name |
| `Azure.DeploymentSlot.Green` | `green` | All | Green slot name |

### Health Check Variables

| Variable Name | Value | Scope | Description |
|---------------|-------|-------|-------------|
| `HealthCheck.Timeout` | `300` | All | Health check timeout in seconds |
| `HealthCheck.Interval` | `30` | All | Retry interval in seconds |
| `HealthCheck.Retries` | `10` | All | Maximum retry attempts |
| `Deployment.WarmupTime` | `120` | All | Application warmup time in seconds |

### Application Package Variables

| Variable Name | Value | Scope | Description |
|---------------|-------|-------|-------------|
| `Application.Package.Id` | `YourApp.Package` | All | Package ID for deployment |
| `Application.Package.Feed` | `built-in` | All | Package feed name |

### Environment-Specific Variables

#### Development Environment

| Variable Name | Value | Scope | Description |
|---------------|-------|-------|-------------|
| `Azure.CurrentSlot` | `blue` | Development | Active slot for dev |
| `HealthCheck.Timeout` | `180` | Development | Shorter timeout for dev |
| `Deployment.WarmupTime` | `60` | Development | Faster warmup for dev |

#### Staging Environment

| Variable Name | Value | Scope | Description |
|---------------|-------|-------|-------------|
| `Azure.CurrentSlot` | `blue` | Staging | Active slot for staging |
| `HealthCheck.Timeout` | `240` | Staging | Medium timeout for staging |
| `Deployment.WarmupTime` | `90` | Staging | Medium warmup for staging |

#### Production Environment

| Variable Name | Value | Scope | Description |
|---------------|-------|-------|-------------|
| `Azure.CurrentSlot` | `blue` | Production | Active slot for production |
| `HealthCheck.Timeout` | `300` | Production | Maximum timeout for production |
| `Deployment.WarmupTime` | `120` | Production | Full warmup for production |

## Variable Setup Instructions

### 1. Create Project Variables

1. In Octopus Deploy, navigate to your project
2. Go to **Variables** section
3. Create each variable listed above with appropriate values
4. Set the correct scope for each variable

### 2. Azure Account Setup

1. Create a Service Principal in Azure:
   ```powershell
   $sp = New-AzADServicePrincipal -DisplayName "OctopusDeployServicePrincipal"
   ```

2. Grant permissions to the Service Principal:
   ```powershell
   New-AzRoleAssignment -ObjectId $sp.Id -RoleDefinitionName "Contributor" -ResourceGroupName "your-resource-group"
   ```

3. Add the Azure Account in Octopus:
   - Go to **Infrastructure** → **Accounts**
   - Add new **Azure Subscription**
   - Use Service Principal credentials

### 3. Dynamic Variables

Some variables are set dynamically during deployment:

| Variable Name | Set By | Description |
|---------------|--------|-------------|
| `Azure.TargetSlot` | Step 1 | Determined based on current slot |
| `Azure.TargetSlotUrl` | Step 1 | URL of the target deployment slot |

### 4. Sensitive Variables

Mark these variables as sensitive if they contain confidential information:
- Azure Service Principal secrets
- Database connection strings
- API keys

### 5. Variable Templates (Optional)

For multi-tenant deployments, consider using Variable Templates:

```json
{
  "Name": "Azure.WebApp.Name",
  "Label": "Web App Name",
  "HelpText": "The name of the Azure Web App for this tenant",
  "DefaultValue": "",
  "DisplaySettings": {
    "ControlType": "SingleLineText"
  }
}
```

## Validation Script

Use this PowerShell script to validate your variable configuration:

```powershell
# Validate Octopus Variables
$requiredVars = @(
    "Azure.Account",
    "Azure.WebApp.Name", 
    "Azure.ResourceGroup",
    "Azure.CurrentSlot",
    "HealthCheck.Timeout",
    "Application.Package.Id"
)

foreach ($var in $requiredVars) {
    if (-not $OctopusParameters[$var]) {
        Write-Error "Required variable '$var' is not set"
    } else {
        Write-Host "✓ Variable '$var' is configured"
    }
}
```

## Notes

- The `Azure.CurrentSlot` variable must be manually updated after each successful deployment to reflect the new active slot
- Consider using Octopus Deploy's API to automate variable updates
- Test the variable configuration in Development environment before deploying to Production
- Keep backup values for quick rollback scenarios
