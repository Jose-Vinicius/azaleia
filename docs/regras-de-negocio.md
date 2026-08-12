# 📋 Regras de Negócio - Azaleia

O **Azaleia** é estruturado para otimizar o gerenciamento de tempo, a produtividade pessoal e a retenção de compromissos.

---

## 🎯 Entidades e Diretrizes

### 👤 Usuários e Autenticação
* **Isolamento Total:** Todos os recursos (`tasks`, `notes`, `notifications`, `integrations`) são estritamente escopados por `Current.user`.
* **Sessões Nativas:** Utiliza a autenticação padrão do Rails 8 (`has_secure_password` + modelo `Session`).

---

### ⏱️ Tarefas e Time Tracking Progressivo
* **Inbox vs. Dashboard:**
  * Tarefas **sem** `schedule_at` caem na caixa de entrada (**Inbox**) para triagem.
  * Tarefas **com** `schedule_at` aparecem agrupadas no **Dashboard** semanal/diário.
* **Tarefas Atrasadas:** Tarefas não concluídas cujo prazo (`schedule_at`) seja inferior ao momento atual ganham destaque visual em alerta vermelho.
* **Time Tracker:**
  * Permite registrar múltiplos blocos de foco (`time_entries`) em minutos.
  * Exibe barra de progresso em tempo real comparando o tempo consumido contra a estimativa (`estimated_minutes`).
  
> [!IMPORTANT]
> Ultrapassar 100% da estimativa em tempo trabalhado **não** conclui a tarefa automaticamente. A conclusão da tarefa é sempre um ato explícito do usuário.

---

### 📅 Sincronização Externa (Google Calendar)
* Integração via **OAuth 2.0**.
* Permite vincular tarefas criadas a eventos no Google Calendar através de `UserIntegration` e `TaskIntegration`.

---

### 📝 Anotações (Notes)
* Espaço livre para captura de pensamentos, atas e checklists.
* Suporta **Markdown (GFM)** nativo para formatação de texto rico.
