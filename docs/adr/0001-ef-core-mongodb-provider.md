# ADR 0001: EF Core MongoDB provider

## Status
Accepted

## Context
O backend precisa persistir dados no MongoDB mantendo o padrão de repositórios e o modelo de domínio atual. A equipe também quer padronizar o acesso a dados com EF Core para facilitar validações, consultas e testes.

## Decision
Adotar o provider do MongoDB para Entity Framework Core. O acesso aos dados passa a ser feito via `DbContext` e `DbSet`, com mapeamento das coleções para `products` e `categories`.

## Consequences
- Padronização das consultas em EF Core.
- Remoção do uso direto do `MongoDB.Driver` nas camadas de infraestrutura.
- Necessidade de configurar o `DbContext` com `UseMongoDB` e atualizar repositórios para usar LINQ.
