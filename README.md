# Azaleia

**Azaleia** é um aplicativo de gerenciamento de tarefas projetado para garantir que você não perca seus compromissos e tarefas, construído com foco em fluidez de interface e experiência de usuário.

## ✨ Principais Funcionalidades

*   📥 **Inbox & Dashboard:** Uma visualização clara! Use o Inbox para capturar ideias que não possuem um prazo definido e deixe o Dashboard focar nas prioridades divididas por dia.
*   📅 **Agrupamento Automático e Integração com Google:** Tarefas agrupadas por data na exibição em grid. As tarefas podem ser sincronizadas com o seu Google Calendar automaticamente.
*   🚨 **Destaques de Tarefas Atrasadas:** Perdeu o prazo? A tarefa acende em vermelho em toda a plataforma para chamar atenção.
*   ⏱️ **Time Tracker Progressivo:** Registre blocos de foco (Pomodoro) em cada tarefa com feedback instantâneo de porcentagem, barra de progresso dinâmica em cores, limites ajustáveis e listagem de histórico fluída.
*   📝 **Bloco de Anotações:** Guarde informações rápidas, listas e resumos em um espaço dedicado e com suporte completo a edição em Markdown (GFM).

> 📚 **Documentação Completa:** Para detalhes técnicos, arquitetura e regras de negócio, consulte o diretório [`/docs`](./docs/).

## 🛠️ Stack de Tecnologias

*   **Linguagem & Framework:** Ruby 3+ / [Ruby on Rails 8.1+](https://rubyonrails.org/)
*   **Interface Dinâmica:** Hotwire (Turbo Frames & Stimulus Controllers) interagindo nativamente sem dependência de SPAs complexos como React.
*   **Estilização:** [Tailwind CSS](https://tailwindcss.com/) com design system de paletas harmônicas para Dark Mode em container global.
*   **Internacionalização (I18n):** Estruturado e funcional (`pt-BR`).

## 👩‍💻 Como Executar o Projeto Localmente

Certifique-se de ter o Ruby, Bundler e o banco de dados (SQLite/PostgreSQL) configurados.

1. Clone esse repositório:
   ```bash
   git clone https://github.com/seu-usuario/azaleia.git
   cd azaleia
   ```

2. Instale as dependências Gems utilizadas e importe os mapas Javascript:
   ```bash
   bundle install
   rails importmap:install
   ```

3. Prepare o banco de dados:
   ```bash
   rails db:create db:migrate
   ```

4. Inicie o servidor:
   ```bash
   rails server
   ```

5. Acesse no navegador:
   `http://localhost:3000`

---
Desenvolvido com ❤️ and ☕
