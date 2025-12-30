$ErrorActionPreference = "Continue"

Write-Host "Waiting for Nextcloud to initialize (this takes a few minutes)..."
$maxRetries = 100
$retryCount = 0
do {
    Start-Sleep -Seconds 5
    # redirect stderr to null so powershell doesn't panic
    docker compose exec -u www-data app php occ status 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) { 
        Write-Host "`nNextcloud is ready!"
        break 
    }
    $retryCount++
    if ($retryCount % 5 -eq 0) { Write-Host -NoNewline "$retryCount.." } else { Write-Host -NoNewline "." }
} while ($retryCount -lt $maxRetries)

if ($retryCount -ge $maxRetries) {
    Write-Error "Timeout waiting for Nextcloud."
}

$ErrorActionPreference = "Stop"
Write-Host "`nConfiguring Nextcloud..."

# Helper function 
function Run-Occ {
    param($args)
    Write-Host "Running: occ $args"
    # Execute commands and ignore errors for now (e.g. if already set) or let them fail if critical
    # We use invoke-expression or direct call. Direct call is tricky with args array in PS.
    # We'll use a simpler approach: build the command string.
    
    $cmd = "docker compose exec -u www-data app php occ $args"
    Invoke-Expression $cmd
}

Run-Occ "config:system:set trusted_domains 1 --value='localhost'"
Run-Occ "config:system:set trusted_domains 2 --value='localhost'"
Run-Occ "config:system:set redis host --value='redis'"
Run-Occ "config:system:set redis port --value='6379'"
Run-Occ "config:system:set redis password --value='change_me_redis'"
Run-Occ "config:system:set memcache.local --value='\OC\Memcache\APCu'"
Run-Occ "config:system:set memcache.distributed --value='\OC\Memcache\Redis'"
Run-Occ "config:system:set memcache.locking --value='\OC\Memcache\Redis'"
Run-Occ "config:system:set default_quota --value='1 GB'"

Write-Host "Installing OnlyOffice..."
try { Run-Occ "app:install onlyoffice" } catch { Write-Host "OnlyOffice install skipped or failed: $_" }
try { Run-Occ "app:enable onlyoffice" } catch { Write-Host "OnlyOffice enable skipped or failed: $_" }

Write-Host "Configuring Previews..."
Run-Occ "config:system:set preview_max_x --value=2048"
Run-Occ "config:system:set preview_max_y --value=2048"

Write-Host "✅ Setup Complete!"
