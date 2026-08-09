```powershell
Write-Host ""
Write-Host "Starting Acquisition App in Development Mode"
Write-Host ""

# ------------------------------------------------------------
# Check if .env.development exists
# ------------------------------------------------------------

if (-not (Test-Path ".env.development")) {
    Write-Host ""
    Write-Host "Error: .env.development file not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please create .env.development and configure your environment variables."
    Write-Host ""
    exit 1
}

# ------------------------------------------------------------
# Check if Docker is running
# ------------------------------------------------------------

docker info | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Error: Docker is not running!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please start Docker Desktop and try again."
    Write-Host ""
    exit 1
}

# ------------------------------------------------------------
# Create .neon_local directory if it doesn't exist
# ------------------------------------------------------------

if (-not (Test-Path ".neon_local")) {
    New-Item -ItemType Directory -Path ".neon_local" | Out-Null
    Write-Host "Created .neon_local directory"
}

# ------------------------------------------------------------
# Add .neon_local to .gitignore
# ------------------------------------------------------------

if (-not (Test-Path ".gitignore")) {
    New-Item -ItemType File -Path ".gitignore" | Out-Null
}

$gitignore = Get-Content ".gitignore" -Raw

if ($gitignore -notmatch "(?m)^\.neon_local/$") {
    Add-Content ".gitignore" "`n.neon_local/"
    Write-Host "Added .neon_local/ to .gitignore"
}

# ------------------------------------------------------------
# Start Neon Local database
# ------------------------------------------------------------

Write-Host ""
Write-Host "Starting Neon Local database..."
Write-Host ""

docker compose -f docker-compose.dev.yml up -d neon-local

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Error: Failed to start Neon Local!" -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------
# Wait for Neon Local to become ready
# ------------------------------------------------------------

Write-Host ""
Write-Host "Waiting for Neon Local to be ready..."

$maxAttempts = 30
$attempt = 0
$ready = $false

while ($attempt -lt $maxAttempts) {

    $logs = docker compose -f docker-compose.dev.yml logs neon-local 2>&1

    if ($logs -match "Neon Local is ready") {
        Write-Host "Neon Local is ready!"
        $ready = $true
        break
    }

    $attempt++

    Write-Host "Waiting... ($attempt/$maxAttempts)"

    Start-Sleep -Seconds 2
}

if (-not $ready) {
    Write-Host ""
    Write-Host "Error: Neon Local did not become ready." -ForegroundColor Red
    Write-Host ""
    Write-Host "Check the Neon Local logs with:"
    Write-Host "docker compose -f docker-compose.dev.yml logs neon-local"
    exit 1
}

# ------------------------------------------------------------
# Run Drizzle migrations
# ------------------------------------------------------------

Write-Host ""
Write-Host "Applying latest database schema with Drizzle..."
Write-Host ""

npm run db:migrate

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Error: Database migration failed!" -ForegroundColor Red
    Write-Host ""
    exit 1
}

# ------------------------------------------------------------
# Start development application
# ------------------------------------------------------------

Write-Host ""
Write-Host "Starting application..."
Write-Host ""
Write-Host "Application: http://localhost:3000"
Write-Host "Database: localhost:5432"
Write-Host ""
Write-Host "Press Ctrl+C to stop the application."
Write-Host ""

docker compose -f docker-compose.dev.yml up --build

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Error: Application failed to start!" -ForegroundColor Red
    exit 1
}
```
