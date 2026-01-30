**Boas Práticas — Keycloak (Produção)**

Este documento descreve passos recomendados para manter o Keycloak seguro, reproduzível e com paridade entre dev/CI e produção.

1. Versione um `realm-export.json`
- Exporte o realm (clients, roles, flows, mappers, users seed) a partir de uma instância de referência e guarde o JSON no repositório (por ex. `docker/keycloak/realm-export.json`).
- Ao fazer deploy, importe esse arquivo (full import) em staging/production para garantir paridade.

2. Crie flows customizados — não altere built-ins
- Crie um `authenticationFlow` top-level com `builtIn:false` (por exemplo `direct grant`) e inclua apenas as execuções necessárias (username + password) como `REQUIRED`.
- Versione esse flow no `realm-export.json` — isso elimina a necessidade de chamadas de Admin API que tentem modificar execuções built-in (essas mudanças frequentemente retornam 404).

3. Não desative required-actions em produção
- Required-actions (VERIFY_EMAIL, CONFIGURE_TOTP, UPDATE_PASSWORD, etc.) são importantes para segurança. Evite desativá-las em produção. Em dev/CI é aceitável desabilitá-las para estabilidade de testes, mas documente isso claramente.

4. Bootstrapping idempotente e seguro
- Para dev/CI: scripts idempotentes que normalizam usuários e roles são úteis (`scripts/bootstrap_manager.ps1`).
- Para produção: prefira scripts que apenas verificam e criam recursos ausentes (flows, clients, roles), **sem** desabilitar providers de required-actions.

5. Logging e auditoria
- Não mantenha TRACE em produção. Configure eventos e encaminhe logs de forma centralizada para auditoria.

6. Pipeline / Deploy
- No CI, importe o `realm-export.json` como parte de um job de setup (ou execute um bootstrap idempotente que cria somente recursos faltantes). Só depois rode os testes.

7. Atualizando o realm em produção
- Gere um novo `realm-export.json` a partir de uma instância de referência sempre que alterar flows ou clients. Teste a importação em staging antes de aplicar em produção.

Exemplo de fragmento `authenticationFlow` recomendado (exportado):

```json
{
  "alias": "direct grant",
  "providerId": "basic-flow",
  "topLevel": true,
  "builtIn": false,
  "authenticationExecutions": [
    { "authenticator": "direct-grant-validate-username", "requirement": "REQUIRED" },
    { "authenticator": "direct-grant-validate-password", "requirement": "REQUIRED" }
  ]
}
```

Resumo: para produção, não use atalhos dev (desativar required-actions). Exporte flows corretos e use bootstraps conservadores que criem somente recursos ausentes.
