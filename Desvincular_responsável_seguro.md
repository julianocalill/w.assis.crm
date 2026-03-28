# Plano de Implementação: Melhorias no Vínculo de Clientes em Oportunidades

Este plano detalha as alterações necessárias para permitir a desvinculação de clientes em uma oportunidade e a separação dos papéis de "Responsável" (quem fecha/trata o seguro) e "Segurado" (em nome de quem o seguro é feito).

## User Review Required
> [!IMPORTANT]
> A alteração propõe modificar o banco de dados (tabela `oportunidades`) para incluir a coluna `segurado_id`, mantendo `contato_id` como o Responsável pelo seguro. O `nome_segurado` continuará sendo preenchido para compatibilidade, mas o sistema passará a vincular ambos (Responsável e Segurado) à base de contatos. Por favor, confirme se essa estrutura atende à necessidade.

## Proposed Changes

### Banco de Dados (PostgreSQL / Supabase)
Será necessário adicionar uma nova coluna na tabela de oportunidades para referenciar o segurado como um contato distinto do responsável financeiro/negociador.

#### [MODIFY] [database.sql](file:///c:/Users/Renato%20-%20W.Assis/OneDrive%20-%20wassis.com.br/Documentos/Gestor%20Wassis/w.assis.crm-main/database.sql)
- Adicionar instrução para criar a coluna `segurado_id` na tabela `oportunidades`, referenciando a tabela `contatos`:
  ```sql
  ALTER TABLE oportunidades ADD COLUMN IF NOT EXISTS segurado_id BIGINT REFERENCES contatos(id);
  ```
- O campo `contato_id` passará a representar o **Responsável** (quem está tratando o seguro).


### Frontend (Interface de Usuário)
As principais alterações visuais ocorrerão no arquivo [index](file:///c:/Users/Renato%20-%20W.Assis/OneDrive%20-%20wassis.com.br/Documentos/Gestor%20Wassis/w.assis.crm-main/index) no `dealModal`.

#### [MODIFY] [index](file:///c:/Users/Renato%20-%20W.Assis/OneDrive%20-%20wassis.com.br/Documentos/Gestor%20Wassis/w.assis.crm-main/index)
1. **Aba de Segurado (Renomeada para Envolvidos/Cliente)**:
   - Dividir a seção em duas partes: **Responsável pelo Seguro** e **Segurado**.
   - **Responsável**: Manterá a busca atual (`opBuscaCliente`).
   - **Segurado**: Adicionar uma nova busca (`opBuscaSegurado`), com campos espelhados (Nome, CPF/CNPJ, etc.) ou apenas um seletor rápido caso o responsável seja o mesmo que o segurado (um checkbox "O segurado é o responsável").
2. **Botão de Desvincular**:
   - Para ambos os blocos (Responsável e Segurado), quando um contato for selecionado (e o ID preenchido no input hidden), exibir um botão vermelho/discreto com o ícone de lixeira ou "X" dizendo **"Desvincular"**.
   - Ao clicar em "Desvincular":
     - O valor de de `contatoId` ou `seguradoId` é apagado.
     - Os campos de texto (Nome, Documento, Telefone, Email) são limpos.
     - O estado da busca é resetado para permitir procurar outro cliente.
3. **Lógica JS (`app.saveDeal`, `app.onBuscaClienteInput`, `app.selecionarContato`)**:
   - Adicionar id hidden `<input type="hidden" id="seguradoId">`
   - Atualizar a submissão do formulário para enviar tanto o responsável quanto o segurado.
   - Criar funções como `app.desvincularContato()` e `app.desvincularSegurado()` para limpar os dados em tela.

## Verification Plan

### Manual Verification
1. Abrir uma oportunidade existente, clicar num botão para desvincular o cliente atual, buscar um novo parente/cliente, vincular e salvar.
2. Abrir uma nova oportunidade, preencher pai como "Responsável" e filho como "Segurado" usando a busca do sistema.
3. Salvar e verificar no banco de dados se os IDs de `contato_id` e `segurado_id` foram gravados corretamente e referenciam clientes diferentes.
