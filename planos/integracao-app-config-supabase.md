# Integração app_config (Supabase) — concluído

**Data:** 2026-04-16

## O que foi feito

- `config` no `index`: `cwUrl` e `cwAccount` fixos (`https://chat.wassis.com.br`, `1`).
- Cache `app.appConfig` preenchido por `loadAppConfig()` após `loadConfigData()` no `initApp`.
- Webhooks n8n e token Chatwoot lidos de `app.appConfig` (`n8n_deal_webhook`, `n8n_user_webhook`, `chatwoot`).
- `saveIntegrations`: `upsert` em `public.app_config` (apenas gerente); atualiza cache local.
- UI Chatwoot: URL/Account como texto informativo; edição só do token + webhooks.
- Remoção das chaves legadas `nexus_cw_*` e `nexus_n8n_*` do `localStorage` após carga bem-sucedida de `app_config`.
- `database.sql`: tabela `app_config` + RLS alinhada ao projeto (select autenticado, escrita gerente).
- `README.md`: documentação atualizada.

## Chaves esperadas em `app_config`

| key | Uso |
|-----|-----|
| `n8n_deal_webhook` | Fechamento ganho/perdido |
| `n8n_user_webhook` | Criar usuário via n8n |
| `chatwoot` | Token API Chatwoot |
