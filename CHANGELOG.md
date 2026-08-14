# Changelog

## [Unreleased]
### Adicionado
### Alterado
### Corrigido
### Removido

## [0.4.1] - 2026-08-14

### Corrigido
- Corrigido conflito de nomes de containers antigos durante o deploy na VPS adicionando a flag --remove-orphans no workflow do GitHub Actions
- Corrigido falso positivo no status de deploy na VPS adicionando a instrução set -e para abortar o script imediatamente ao falhar qualquer comando do Docker

## [0.4.0] - 2026-08-14

### Adicionado
- Adicionado badge visual em tarefas para identificação direta de origem vinculada a um OKR
- Adicionada abertura do modal de detalhes ao clicar nas tarefas listadas dentro dos OKRs

## [0.3.0] - 2026-08-14

### Adicionado
- Adicionado módulo e menu de gerenciamento de Tarefas Recorrentes (/recurrent_tasks) com renovação automática por data ao concluir a tarefa
- Adicionada funcionalidade de anexo de imagens em tarefas via Active Storage com pré-visualização e remoção no modal
- Adicionado visualizador interativo em modal (Lightbox) para imagens anexadas com navegação por carrossel entre fotos, zoom (+/-), download direto e abertura em nova aba
- Adicionados badges visuais de nível de importância (Multiplicadores), tempo estimado, frequência de recorrência e contagem de imagens nos cards de tarefas
### Alterado
- Ajustado disparo do workflow de release para ocorrer exclusivamente quando houver merge de Pull Request para a branch main
- Expandida a exibição das badges de importância, tempo estimado, recorrência e imagens para todas as visualizações do Dashboard (Modo Cards, Modo Lista e Modo Calendário)
- Adicionado suporte a movimentação/arraste (Pan & Drag) da imagem aproximada com o mouse/touch, zoom via scroll do mouse e clique duplo no visualizador Lightbox
### Corrigido
- Corrigido erro de coluna ausente `recurrence` na tabela `tasks` do banco de dados executando a migração correspondente e adicionando verificações defensivas nas views
- Corrigido erro de método inexistente 'recurrence' no modelo de Tarefas ao gerar sugestões por IA para Resultados-Chave e Metas SMART
### Removido

## [0.2.0] - 2026-08-14

### Adicionado
- Adicionado módulo dedicado de OKRs da empresa com cálculo automático de progresso derivado das tarefas associadas
- Adicionada sugestão e decomposição de tarefas para OKRs e Resultados-Chave via Inteligência Artificial (Gemini)
- Adicionado sistema de Changelog automático com captura de intenção em tempo real e script de release

### Alterado

### Corrigido
