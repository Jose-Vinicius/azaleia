## Changelog

Sempre que você concluir uma alteração de código com impacto observável
(feature nova, mudança de comportamento, correção de bug, remoção de algo),
adicione uma entrada em `CHANGELOG.md`, dentro de `## [Unreleased]`, na
subseção correta:

- `### Adicionado` — funcionalidade nova
- `### Alterado` — mudança de comportamento em algo que já existia
- `### Corrigido` — correção de bug
- `### Removido` — funcionalidade, endpoint ou coluna removida

Regras:
- Uma linha por item, em português, começando com verbo no passado
  (ex: "Adicionado endpoint de exportação de relatórios em CSV").
- Descreva o impacto observável (pro usuário ou pro time), não detalhe de
  implementação interna (ex: não escreva "Refatorado UserService").
- Não crie entrada pra mudanças sem impacto externo: reformatação, comentários,
  ajustes de teste, dependências internas.
- Se a subseção ainda não tiver itens, adicione a primeira linha nela.
- Nunca apague entradas já existentes — só adicione as suas.
