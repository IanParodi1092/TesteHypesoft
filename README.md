# Aplicativo Hypesoft - Sistema de Gestão de Produtos

## Sobre o aplicativo

O Aplicativo Hypesoft é um sistema completo de gestão de produtos, com controle de estoque, categorias e dashboard analítico. Ele integra autenticação via Keycloak e fornece uma API segura com documentação Swagger (Swagger UI).

Principais destaques:
- CRUD de produtos e categorias com validações
- Controle de estoque com alerta de baixo nível
- Dashboard com métricas e gráfico por categoria
- Autenticação e autorização por roles (Admin/Manager)
- Cache e rate limiting para desempenho e proteção

## Solução Implementada

Esta implementação entrega um backend em .NET (Clean Architecture + CQRS) e um frontend em React com autenticação via Keycloak.

### Executar com Docker

```bash
docker-compose up -d --build
```

### URLs

- Frontend: http://localhost:3000
- API: http://localhost:5000
- Swagger: http://localhost:5000/swagger
- MongoDB Express: http://localhost:8081
- Keycloak: http://localhost:8080

### Credenciais (Keycloak)

- Admin (role Admin): `admin` / `Admin123!`
- Manager (role Manager): `manager` / `Manager123!`

### Desenvolvimento local

```bash
# Backend
dotnet run --project src/Hypesoft.API/Hypesoft.API.csproj

# Frontend
cd frontend
```

### Obter token e exemplos de chamadas autenticadas

Exemplo rápido para obter um `access_token` (password grant) e usar em chamadas à API.

curl (Linux / macOS / Windows w/ curl):

```bash
curl -s -X POST "http://localhost:8080/realms/hypesoft/protocol/openid-connect/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=password&client_id=hypesoft-api&client_secret=hypesoft-api-secret&username=admin&password=Admin123!" \
    | jq -r .access_token > token.txt

API example with token:
curl -H "Authorization: Bearer $(cat token.txt)" -H "Content-Type: application/json" \
    -d '{"Name":"Categoria Exemplo"}' \
    http://localhost:5000/api/categories
```

PowerShell (Windows):

```powershell
# $tokenResp = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/hypesoft/protocol/openid-connect/token' -ContentType 'application/x-www-form-urlencoded' -Body @{grant_type='password';client_id='hypesoft-api';client_secret='hypesoft-api-secret';username='admin';password='Admin123!'}
# $token = $tokenResp.access_token
# Invoke-RestMethod -Method Post -Uri 'http://localhost:5000/api/categories' -Headers @{ Authorization = "Bearer $token" } -Body (@{ Name = 'Categoria Exemplo' } | ConvertTo-Json) -ContentType 'application/json'
```

Observações:
- Se estiver usando o client `hypesoft-api` como confidential, use `client_secret` (ex.: `hypesoft-api-secret`).
- Em alguns ambientes o Keycloak demora a ficar pronto; aguarde alguns segundos após o bootstrap.

### Pré-requisitos Docker

- Docker Engine e Docker Compose instalados.
- Portas livres: `8080` (Keycloak), `5000` (API), `3000` (frontend), `27017` (MongoDB), `8081` (mongo-express, se habilitado).
- Se houver problemas de bootstrap do Keycloak, reinicie o container ou aguarde a importação do realm.

### Import idempotente do Keycloak (recomendado)

Para evitar problemas com import manual do `realm` em instalações do zero, incluímos scripts que importam o `realm-export.json` de forma idempotente — o import só será executado se o realm `hypesoft` não existir.

- Script Bash: `scripts/bootstrap-keycloak.sh`
- Script PowerShell (Windows): `scripts/bootstrap-keycloak.ps1`

Exemplos:

```bash
# Executar (Linux/macOS):
bash scripts/bootstrap-keycloak.sh

# Forçar clean install (remove volumes e reimporta):
docker-compose down -v
docker-compose up -d --build
```

No Windows PowerShell:

```powershell
# Executar:
.\scripts\bootstrap-keycloak.ps1
```

Esses scripts usam a Admin API do Keycloak para importar o realm apenas quando necessário — ideal para instalações reproducíveis.

### Testes

- Testes locais (sem Docker): `dotnet test`
- Testes de integração com Mongo via Testcontainers: defina `RUN_INTEGRATION_TESTS=true`
- Testes que dependem do Keycloak: garanta o Keycloak ativo e, se necessário, defina `KEYCLOAK_URL` (ex.: `http://localhost:8080`)

### CI

- Pipeline no GitHub Actions executa testes de backend e frontend.

## Visão Geral

O Aplicativo Hypesoft oferece uma experiência completa para gestão de produtos, com foco em produtividade, segurança e métricas claras para tomada de decisão.

## Funcionalidades

- Gestão completa de produtos (CRUD)
- Gestão de categorias e filtros
- Controle de estoque e alertas de baixo nível
- Dashboard com métricas e gráfico por categoria
- Autenticação e autorização via Keycloak (roles Admin/Manager)
- API documentada com OpenAPI e Swagger UI

## Stack Tecnológica

### Frontend
- **React 18** com TypeScript
- **Vite** para build
- **TailwindCSS** para estilização
- **React Query/TanStack Query** para gerenciamento de estado
- **React Hook Form** + **Zod** para validação
- **Recharts** para dashboards
- **React Testing Library** + **Vitest** para testes

### Backend
- **.NET 10** com C#
- **Clean Architecture** + **DDD** (Domain-Driven Design)
- **CQRS** + **MediatR** pattern
- **Entity Framework Core** com MongoDB provider
- **FluentValidation** para validação
- **AutoMapper** para mapeamento
- **Serilog** para logging estruturado
- **xUnit** + **FluentAssertions** para testes

### Infraestrutura
- **MongoDB** como banco principal
- **Keycloak** para autenticação e autorização
- **Docker** + **Docker Compose** para containerização
- **Nginx** como reverse proxy

## Arquitetura do Sistema

### Backend - Clean Architecture + DDD

```
src/
├── Hypesoft.Domain/              # Camada de Domínio
│   ├── Entities/                 # Entidades do domínio
│   ├── ValueObjects/             # Objetos de valor
│   ├── DomainEvents/            # Eventos de domínio
│   ├── Repositories/            # Interfaces dos repositórios
│   └── Services/                # Serviços de domínio
├── Hypesoft.Application/         # Camada de Aplicação
│   ├── Commands/                # Comandos CQRS
│   ├── Queries/                 # Consultas CQRS
│   ├── Handlers/                # Handlers MediatR
│   ├── DTOs/                    # Data Transfer Objects
│   ├── Validators/              # Validadores FluentValidation
│   └── Interfaces/              # Interfaces da aplicação
├── Hypesoft.Infrastructure/      # Camada de Infraestrutura
│   ├── Data/                    # Contexto e configurações EF
│   ├── Repositories/            # Implementação dos repositórios
│   ├── Services/                # Serviços externos
│   └── Configurations/          # Configurações de DI
└── Hypesoft.API/                # Camada de Apresentação
    ├── Controllers/             # Controllers da API
    ├── Middlewares/             # Middlewares customizados
    ├── Filters/                 # Filtros de ação
    └── Extensions/              # Extensões de configuração
```

### Frontend - Arquitetura Modular

```
src/
├── components/                   # Componentes reutilizáveis
│   ├── ui/                      # Componentes base (shadcn/ui)
│   ├── forms/                   # Componentes de formulário
│   ├── charts/                  # Componentes de gráficos
│   └── layout/                  # Componentes de layout
├── pages/                       # Páginas da aplicação
├── hooks/                       # Custom hooks
├── services/                    # Serviços de API
├── stores/                      # Stores de estado global
├── types/                       # Definições de tipos
├── utils/                       # Funções utilitárias
└── lib/                         # Configurações de bibliotecas
### Desenvolvimento local

```bash
# Backend
- **.NET 10** com C#
dotnet run --project src/Hypesoft.API/Hypesoft.API.csproj

# Frontend
cd frontend

### Obter token e exemplos de chamadas autenticadas

Exemplo rápido para obter um `access_token` (password grant) e usar em chamadas à API.

curl (Linux / macOS / Windows w/ curl):

```bash
curl -s -X POST "http://localhost:8080/realms/hypesoft/protocol/openid-connect/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "grant_type=password&client_id=hypesoft-api&client_secret=hypesoft-api-secret&username=admin&password=Admin123!" \
    | jq -r .access_token > token.txt

API example with token:
curl -H "Authorization: Bearer $(cat token.txt)" -H "Content-Type: application/json" \
    -d '{"Name":"Categoria Exemplo"}' \
    http://localhost:5000/api/categories
```

PowerShell (Windows):

```powershell
# $tokenResp = Invoke-RestMethod -Method Post -Uri 'http://localhost:8080/realms/hypesoft/protocol/openid-connect/token' -ContentType 'application/x-www-form-urlencoded' -Body @{grant_type='password';client_id='hypesoft-api';client_secret='hypesoft-api-secret';username='admin';password='Admin123!'}
# $token = $tokenResp.access_token
# Invoke-RestMethod -Method Post -Uri 'http://localhost:5000/api/categories' -Headers @{ Authorization = "Bearer $token" } -Body (@{ Name = 'Categoria Exemplo' } | ConvertTo-Json) -ContentType 'application/json'
```

Observações:
- Se estiver usando o client `hypesoft-api` como confidential, use `client_secret` (ex.: `hypesoft-api-secret`).
- Em alguns ambientes o Keycloak demora a ficar pronto; aguarde alguns segundos após o bootstrap.

### Pré-requisitos Docker

- Docker Engine e Docker Compose instalados.
- Portas livres: `8080` (Keycloak), `5000` (API), `3000` (frontend), `27017` (MongoDB), `8081` (mongo-express, se habilitado).
- Se houver problemas de bootstrap do Keycloak, reinicie o container ou aguarde a importação do realm.

### Import idempotente do Keycloak (recomendado)

Para evitar problemas com import manual do `realm` em instalações do zero, incluímos scripts que importam o `realm-export.json` de forma idempotente — o import só será executado se o realm `hypesoft` não existir.

- Script Bash: `scripts/bootstrap-keycloak.sh`
- Script PowerShell (Windows): `scripts/bootstrap-keycloak.ps1`

Exemplos:

```bash
# Executar (Linux/macOS):
bash scripts/bootstrap-keycloak.sh

# Forçar clean install (remove volumes e reimporta):
docker-compose down -v
docker-compose up -d --build
```

No Windows PowerShell:

```powershell
# Executar:
.\scripts\bootstrap-keycloak.ps1
```

Esses scripts usam a Admin API do Keycloak para importar o realm apenas quando necessário — ideal para instalações reproducíveis.
cp .env.example .env
npm install
npm run dev
```

### Testes

- Testes locais (sem Docker): `dotnet test`
- Testes de integração com Mongo via Testcontainers: defina `RUN_INTEGRATION_TESTS=true`
- Testes que dependem do Keycloak: garanta o Keycloak ativo e, se necessário, defina `KEYCLOAK_URL` (ex.: `http://localhost:8080`)

### CI

- Pipeline no GitHub Actions executa testes de backend e frontend.

## Visão Geral

O Aplicativo Hypesoft oferece uma experiência completa para gestão de produtos, com foco em produtividade, segurança e métricas claras para tomada de decisão.

## Funcionalidades

- Gestão completa de produtos (CRUD)
- Gestão de categorias e filtros
- Controle de estoque e alertas de baixo nível
- Dashboard com métricas e gráfico por categoria
- Autenticação e autorização via Keycloak (roles Admin/Manager)
- API documentada com OpenAPI e UI do Scalar

## Stack Tecnológica

### Frontend
- **React 18** com TypeScript
- **Vite** para build
- **TailwindCSS** para estilização
- **React Query/TanStack Query** para gerenciamento de estado
- **React Hook Form** + **Zod** para validação
- **Recharts** para dashboards
- **React Testing Library** + **Vitest** para testes

### Backend
- **.NET 9** com C#
- **Clean Architecture** + **DDD** (Domain-Driven Design)
- **CQRS** + **MediatR** pattern
- **Entity Framework Core** com MongoDB provider
- **FluentValidation** para validação
- **AutoMapper** para mapeamento
- **Serilog** para logging estruturado
- **xUnit** + **FluentAssertions** para testes

### Infraestrutura
- **MongoDB** como banco principal
- **Keycloak** para autenticação e autorização
- **Docker** + **Docker Compose** para containerização
- **Nginx** como reverse proxy

## Arquitetura do Sistema

### Backend - Clean Architecture + DDD

```
src/
├── Hypesoft.Domain/              # Camada de Domínio
│   ├── Entities/                 # Entidades do domínio
│   ├── ValueObjects/             # Objetos de valor
│   ├── DomainEvents/            # Eventos de domínio
│   ├── Repositories/            # Interfaces dos repositórios
│   └── Services/                # Serviços de domínio
├── Hypesoft.Application/         # Camada de Aplicação
│   ├── Commands/                # Comandos CQRS
│   ├── Queries/                 # Consultas CQRS
│   ├── Handlers/                # Handlers MediatR
│   ├── DTOs/                    # Data Transfer Objects
│   ├── Validators/              # Validadores FluentValidation
│   └── Interfaces/              # Interfaces da aplicação
├── Hypesoft.Infrastructure/      # Camada de Infraestrutura
│   ├── Data/                    # Contexto e configurações EF
│   ├── Repositories/            # Implementação dos repositórios
│   ├── Services/                # Serviços externos
│   └── Configurations/          # Configurações de DI
└── Hypesoft.API/                # Camada de Apresentação
    ├── Controllers/             # Controllers da API
    ├── Middlewares/             # Middlewares customizados
    ├── Filters/                 # Filtros de ação
    └── Extensions/              # Extensões de configuração
```

### Frontend - Arquitetura Modular

```
src/
├── components/                   # Componentes reutilizáveis
│   ├── ui/                      # Componentes base (shadcn/ui)
│   ├── forms/                   # Componentes de formulário
│   ├── charts/                  # Componentes de gráficos
│   └── layout/                  # Componentes de layout
├── pages/                       # Páginas da aplicação
├── hooks/                       # Custom hooks
├── services/                    # Serviços de API
├── stores/                      # Stores de estado global
├── types/                       # Definições de tipos
├── utils/                       # Funções utilitárias
└── lib/                         # Configurações de bibliotecas
```
