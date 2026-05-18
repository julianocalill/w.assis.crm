# Plano: telefone em E.164 no banco e exibição sem máscara

## Contexto atual

- A coluna já existe como `TEXT` em `database.sql` (`contatos.telefone`); cabe o formato `+5511996572103` sem migração de tipo.
- Em `index`, o fluxo grava o texto do input (hoje alterado por `maskPhone`), por exemplo em `saveContatoOnly` e em `saveDeal` (`opTelefone` / `opRespTelefone`, `editContatoTelefone`).
- `ui.maskPhone` assume número só nacional; com E.164 no banco a máscara distorce a leitura. Pedido: **não usar máscara** — tela = banco.
- `buscarChatwoot` precisa não duplicar `55` quando o número já estiver em E.164.
- Busca e duplicidade precisam de `phoneComparableKey` coerente após padronizar `+55...`.

## Decisão de produto

- **Persistência:** sempre salvar em **E.164** com `+`, padrão **Brasil (+55)** quando o usuário digitar apenas DDD+número (10 ou 11 dígitos), ou ao colar `5511996572103` / `+5511996572103`.
- **Exibição:** **sem máscara** — inputs, modais, tabelas mostram exatamente o valor armazenado. Placeholders sugerem formato internacional.
- **Escopo DDI:** foco Brasil; heurísticas 12–13 dígitos com prefixo `55`; 10–11 dígitos → prefixar `55` ao montar E.164.

## Implementação técnica (`index`)

1. **`app.toPhoneE164(v)`** e **`app.phoneComparableKey(v)`** perto de `normalizeDigits`.
2. **UI:** remover `maskPhone` dos campos de telefone de contato; listagens usam texto do banco; placeholders tipo `+5511996572103`; grep para remover ou apagar `ui.maskPhone` se não houver outro uso.
3. **Save:** `saveContatoOnly` e `saveDeal` com `toPhoneE164`; duplicidade com `phoneComparableKey`.
4. **Chatwoot** e **buscas:** mesma chave comparável.

## Validação sugerida

Salvar com dígitos nacionais → banco `+55...` → reabrir e ver o mesmo texto no campo; duplicidade; buscas; Chatwoot.

## Tarefas (checklist)

- [ ] helpers-e164
- [ ] ui-sem-mascara
- [ ] save-paths
- [ ] search-chatwoot
- [ ] qa-manual
