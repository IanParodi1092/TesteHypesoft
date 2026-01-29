# Aplicativo Hypesoft - Sistema de Gestão de Produtos

## Sobre o aplicativo

O Aplicativo Hypesoft é um sistema completo de gestão de produtos, com controle de estoque, categorias e dashboard analítico. Ele integra autenticação via Keycloak e fornece uma API segura com documentação OpenAPI/Scalar.

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
- OpenAPI JSON: http://localhost:5000/openapi/v1.json
- Docs (Scalar): http://localhost:5000/scalar (apenas em desenvolvimento)
- Keycloak: http://localhost:8080

### Credenciais (Keycloak)

- Admin (role Admin): `admin` / `Admin123!`
- Manager (role Manager): `manager` / `Manager123!`

### Desenvolvimento local

```bash
# Backend
cd backend
dotnet run --project src/Hypesoft.API/Hypesoft.API.csproj

# Frontend
cd frontend
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
