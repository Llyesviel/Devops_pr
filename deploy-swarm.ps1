# PowerShell скрипт для развертывания микросервисов в Docker Swarm

Write-Host "🚀 Начинаем развертывание микросервисов в Docker Swarm..." -ForegroundColor Green

# Проверяем, инициализирован ли Docker Swarm
$swarmStatus = docker info --format "{{.Swarm.LocalNodeState}}"
if ($swarmStatus -ne "active") {
    Write-Host "📋 Инициализируем Docker Swarm..." -ForegroundColor Yellow
    docker swarm init
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Ошибка при инициализации Docker Swarm" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Docker Swarm успешно инициализирован" -ForegroundColor Green
} else {
    Write-Host "✅ Docker Swarm уже инициализирован" -ForegroundColor Green
}

# Собираем образы микросервисов
Write-Host "🔨 Собираем образы микросервисов..." -ForegroundColor Yellow

Write-Host "   📦 Собираем animal-service..." -ForegroundColor Cyan
docker build -t devops_animal-service:latest ./microservices/animal-service/
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Ошибка при сборке animal-service" -ForegroundColor Red
    exit 1
}

Write-Host "   📦 Собираем notification-service..." -ForegroundColor Cyan
docker build -t devops_notification-service:latest ./microservices/notification-service/
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Ошибка при сборке notification-service" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Образы успешно собраны" -ForegroundColor Green

# Развертываем стек в Swarm
Write-Host "🚢 Развертываем стек в Docker Swarm..." -ForegroundColor Yellow
docker stack deploy -c docker-compose.swarm.yml microservices-stack
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Ошибка при развертывании стека" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Стек успешно развернут" -ForegroundColor Green

# Ждем запуска сервисов
Write-Host "⏳ Ожидаем запуска сервисов..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Проверяем статус сервисов
Write-Host "📊 Статус сервисов:" -ForegroundColor Cyan
docker service ls

Write-Host ""
Write-Host "🔍 Детальная информация о сервисах:" -ForegroundColor Cyan
docker stack ps microservices-stack

Write-Host ""
Write-Host "🌐 Доступные endpoints:" -ForegroundColor Green
Write-Host "   • Animal Service API: http://localhost/api/animals" -ForegroundColor White
Write-Host "   • Notification Service API: http://localhost/api/notifications" -ForegroundColor White
Write-Host "   • WebSocket: ws://localhost/ws" -ForegroundColor White
Write-Host "   • Load Balancer Status: http://localhost:8080" -ForegroundColor White
Write-Host "   • Docker Visualizer: http://localhost:9080" -ForegroundColor White
Write-Host "   • Portainer: http://localhost:9000" -ForegroundColor White

Write-Host ""
Write-Host "✅ Развертывание завершено!" -ForegroundColor Green
Write-Host "💡 Используйте 'docker service logs <service-name>' для просмотра логов" -ForegroundColor Yellow
Write-Host "💡 Используйте 'docker stack rm microservices-stack' для удаления стека" -ForegroundColor Yellow