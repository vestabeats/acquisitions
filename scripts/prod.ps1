Write-Host ""
Write-Host "Starting Acquisition App in Production Mode" -ForegroundColor Green
Write-Host "============================================"
Write-Host ""

# Check if .env.production exists
if (-not (Test-Path ".env.production")) {
    Write-Host ""
    Write-Host "Error: .env.production file not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please create .env.production with your production environment variables."
    Write-Host ""
    exit 1
}

# Check if Docker is running
docker info | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Error: Docker is not running!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please start Docker Desktop and try again."
    Write-Host ""
    exit 1
}

Write-Host "Production environment checks passed." -ForegroundColor Green
Write-Host ""

Write-Host "Building and starting production container..." -ForegroundColor Cyan
Write-Host " - Using Neon Cloud PostgreSQL"
Write-Host " - No Neon Local database"
Write-Host " - Running in production mode"
Write-Host ""

# Start production container
docker compose -f docker-compose.prod.yml up --build -d

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Error: Failed to start production environment!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Production container started successfully." -ForegroundColor Green
Write-Host ""

# Give the application a few seconds to start
Write-Host "Waiting for application to start..." -ForegroundColor Cyan
Start-Sleep -Seconds 5

# Run database migrations
Write-Host ""
Write-Host "Applying latest database schema with Drizzle..." -ForegroundColor Cyan
Write-Host ""

npm run db:migrate

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Error: Database migration failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "The production container is still running."
    Write-Host "Check the application logs with:"
    Write-Host "docker compose -f docker-compose.prod.yml logs app"
    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "Production environment started successfully!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

Write-Host "Application: http://localhost:3000"
Write-Host ""

Write-Host "Useful commands:"
Write-Host ""
Write-Host "View application logs:"
Write-Host "docker compose -f docker-compose.prod.yml logs -f app"
Write-Host ""
Write-Host "View all logs:"
Write-Host "docker compose -f docker-compose.prod.yml logs -f"
Write-Host ""
Write-Host "Check containers:"
Write-Host "docker compose -f docker-compose.prod.yml ps"
Write-Host ""
Write-Host "Stop production:"
Write-Host "docker compose -f docker-compose.prod.yml down"
Write-Host ""