# Instruções globais

## Implementação nova

1. **Branch**: confira a branch atual. Se for `main`, `master` ou `develop`, crie uma branch de feature a partir da `main` (ou `master`) atualizada, no padrão `bhcosta90/feature/<slug-da-feature>`, e siga nela. Nunca crie a branch a partir da `develop`.
2. **Brainstorming**: toda implementação nova começa pela skill `brainstorming`, mesmo que eu não peça.
3. **Documentação no brainstorming**: ao concluir o brainstorming, use a skill `docs-feature` para gerar os documentos da feature em `docs-bhcosta90/<branch-ativa>/`. O brainstorming só está concluído quando eles existirem, mesmo que a skill `brainstorming` não peça ou que eu não lembre de pedir.
4. **Documentação após a implementação**: ao concluir a implementação, use de novo a skill `docs-feature` para finalizar o `qa.md` e gerar o `rdm.md`.

## Git: develop nunca entra nas branches

**Nunca, em hipótese nenhuma, traga a `develop` para dentro de outra branch.** Isso vale para `git merge develop`, `git merge origin/develop`, `git rebase develop`, `git pull origin develop` e qualquer outra forma.

- "Faz o merge com a develop" significa levar a branch **para** a `develop`: `git checkout develop`, `git merge --ff-only origin/develop`, `git merge --no-ff <branch>`, push da `develop` e voltar para a branch de trabalho.
- As branches de feature, fix e hotfix nascem da `main` (ou `master`) e voltam para ela. A `develop` só recebe, nunca é fonte.
- Se a branch precisar de algo novo, traga da `main`/`master`, nunca da `develop`.
- Na dúvida sobre a direção de um merge, pergunte antes.
