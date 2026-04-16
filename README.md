# W.Assis CRM - Plataforma de Vendas e Gestão

Plataforma de CRM (Customer Relationship Management) desenvolvida sob medida para a gestão de seguros, focada em alta performance, usabilidade e automação de processos.

Desenvolvido pela equipe **Be More**.

## 🛠 Arquitetura do Sistema

O sistema foi construído utilizando uma arquitetura **Serverless** (Sem Servidor Backend tradicional) e **Event-Driven** (Orientada a Eventos).

- **Front-end:** HTML5, TailwindCSS, JavaScript Vanilla.
- **Back-end as a Service (BaaS):** Supabase (PostgreSQL, Auth, Storage).
- **Automação:** n8n (Integração com ERP SegFy, ChatWoot e gestão de usuários).

---

## 🚀 Como rodar o projeto localmente

Como o sistema é uma Aplicação de Página Única (SPA) Serverless, não é necessário instalar dependências via `npm` ou configurar servidores locais.

1. Faça o clone deste repositório:
   `git clone https://github.com/SEU-USUARIO/wassis-crm.git`
2. Abra a pasta do projeto.
3. Para executar, basta abrir o arquivo `index.html` em qualquer navegador web atualizado.
4. *(Recomendado para Devs)*: Abra a pasta no VS Code e utilize a extensão **Live Server**.

---

## 🗄️ Configuração do Banco de Dados (Supabase)

Para rodar o sistema do zero em uma nova instância, siga os passos:

1. Crie um projeto no [Supabase](https://supabase.com).
2. Vá ao menu **SQL Editor**, cole o conteúdo do arquivo `database.sql` e clique em **Run**. Isso criará todas as tabelas e relacionamentos.
3. Vá ao menu **Storage** e crie um novo Bucket chamado `arquivos_crm`. Marque-o como **Public**.
4. No arquivo `index.html`, localize o objeto `config` (linha ~900) e insira a sua **URL** e **Anon Key** fornecidas nas configurações do Supabase.

### 🔐 Criando o primeiro usuário Administrador (Gerente)
1. Crie seu usuário normalmente via Supabase Auth ou pela tela de Login do CRM (caso ative o Sign Up).
2. Vá ao SQL Editor e rode o comando abaixo para dar permissão total à sua conta:
   `UPDATE corretores SET perfil = 'Gerente' WHERE email = 'seu-email@dominio.com';`

---

## 🤖 Configuração de Automações (n8n)

A criação de novos usuários de forma segura e o fluxo de Pós-Venda (Negócio Ganho) são processados via n8n.

1. Acesse o sistema CRM com seu usuário nível **Gerente**.
2. Vá em **Configurações > Integrações API**.
3. Insira as URLs dos Webhooks gerados no seu servidor n8n para:
   - Webhook: Negócio Ganho (Pós-Venda)
   - Webhook: Criar Novo Usuário
4. Configure o **User API Access Token** do Chatwoot (URL e Account ID da instância ficam fixos no código).
5. Ao salvar, os valores são persistidos na tabela **`app_config`** do Supabase (chaves `n8n_deal_webhook`, `n8n_user_webhook`, `chatwoot`). O CRM carrega essas chaves ao iniciar a sessão.
6. A partir de agora, o front-end disparará pacotes JSON automaticamente para os webhooks quando as ações ocorrerem.

---

## 🌐 Deploy (Hospedagem em Produção)

Para colocar o sistema no ar com um link público, utilize plataformas de hospedagem estática gratuitas.

**Exemplo rápido via Vercel ou Netlify:**
1. Crie uma conta na [Vercel](https://vercel.com).
2. Clique em "Add New Project" e conecte com o seu repositório do GitHub.
3. Clique em "Deploy". Em segundos, seu CRM estará online e acessível globalmente.
