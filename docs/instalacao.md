# 🚀 Instalação e Configuração - Azaleia

O **Azaleia** é um aplicativo de gerenciamento de tarefas pessoais e produtividade focado em controle de tempo, organização visual e sincronização externa, desenvolvido com Ruby on Rails 8 e Hotwire.

---

## 📋 Pré-requisitos

Antes de iniciar, certifique-se de ter as seguintes ferramentas instaladas em seu ambiente local:

*   **Ruby:** Versão 3.2.0 ou superior (recomendado via `rbenv` ou `asdf`)
*   **Bundler:** `gem install bundler`
*   **SQLite3** ou **PostgreSQL** (para ambiente de desenvolvimento)
*   **Node.js & NPM / Yarn** (opcional para compilação de assets, caso necessário)

---

## 🛠️ Passo a Passo para Execução Local

### 1️⃣ Clonar o Repositório

```bash
git clone https://github.com/Jose-Vinicius/azaleia.git
cd azaleia
```

### 2️⃣ Inicializar Submódulos (se aplicável)

Se o repositório possuir submódulos (como a engine de documentação Âmbar):

```bash
git submodule update --init --recursive
```

### 3️⃣ Instalar Dependências das Gems

```bash
bundle install
```

### 4️⃣ Configurar as Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto com as configurações básicas:

```env
RAILS_ENV=development
DATABASE_URL=sqlite3:db/development.sqlite3
# Caso utilize integração com Google Calendar (OAuth 2.0):
# GOOGLE_CLIENT_ID=seu_client_id
# GOOGLE_CLIENT_SECRET=seu_client_secret
```

### 5️⃣ Preparar o Banco de Dados

Crie o banco de dados e execute as migrações necessárias:

```bash
bin/rails db:prepare
```

> [!TIP]
> O comando `bin/rails db:prepare` cria o banco de dados, executa todas as migrações e roda as seeds (`db/seeds.rb`) caso o banco seja novo.

### 6️⃣ Iniciar o Servidor de Desenvolvimento

Execute o servidor Web do Rails:

```bash
bin/rails server
```

Acesse a aplicação no navegador em: `http://localhost:3000`

---

## 📖 Visualizando a Documentação Localmente

Para visualizar a documentação com a engine **Âmbar Docs** localmente no seu navegador:

```bash
# Executando um servidor HTTP simples na raiz do projeto:
npx serve .

# Ou com Python 3:
python -m http.server 8000
```

Abra no navegador em: `http://localhost:8000/ambar/`
