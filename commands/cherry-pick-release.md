---
description: Cria uma branch <origem>-release a partir de origin/master e cherry-picka, em ordem cronológica, somente os commits do usuário atual (git config user.email) da branch de origem, excluindo merges.
argument-hint: "[branch-origem]"
allowed-tools: Bash, AskUserQuestion
---

# Cherry-pick release branch

Seu objetivo é criar uma branch `<origem>-release` contendo apenas os commits do usuário atual, trazidos via `cherry-pick` da branch de origem em ordem cronológica (do mais antigo para o mais novo), **excluindo commits de merge**.

## Inputs

- `$ARGUMENTS` pode conter o nome da branch de origem. Se estiver vazio, **use AskUserQuestion** para perguntar ao usuário qual branch servirá de base (aceitar qualquer nome).
- Detecte o email do autor com `git config user.email`. Todos os commits a serem cherry-picked devem ter esse email como `%ae`.
- A branch de destino é sempre `<origem>-release` (sufixo fixo `-release`).
- A base do cherry-pick é `origin/master`. Se `origin/master` não existir, use `origin/main`. Se nenhum dos dois existir, aborte com mensagem clara. A partir daqui, `<base>` se refere à base detectada.

## Pré-requisitos a validar antes de começar

Execute em paralelo e aborte com mensagem clara se algo falhar:

1. `git rev-parse --verify <origem>` — a branch de origem precisa existir localmente.
2. Detecte a base: tente `git rev-parse --verify origin/master`; se falhar, tente `git rev-parse --verify origin/main`; se ambos falharem, aborte.
3. `git config user.email` — precisa retornar algo (não vazio).
4. Se `<origem>-release` já existir, **pergunte** com AskUserQuestion: sobrescrever (delete + recria), trocar o nome, ou abortar. **Nunca delete sem confirmação**.

## Fluxo

1. **Working tree sujo?** Se `git status --porcelain` retornar linhas, pergunte com AskUserQuestion: `stash`, `abortar`, ou `continuar mesmo assim`. Se stash, guarde com `git stash push -u -m "pre-cherry-pick wip"` e restaure no final com `git stash pop`.

2. **Criar/posicionar a branch de destino** a partir de `<base>` (detectada acima — `origin/master` ou `origin/main`):
   ```bash
   git fetch origin <nome-curto-da-base>   # master ou main
   git checkout -B <origem>-release <base>
   ```

3. **Listar os commits em ordem cronológica**, filtrando por autor e excluindo merges:
   ```bash
   git log <base>..<origem> --author="<email>" --no-merges --pretty=format:"%H" --reverse
   ```
   Mostre a lista resumida (hash curto + mensagem) para o usuário antes de aplicar. Se a lista estiver vazia, aborte com mensagem informando que não há commits elegíveis.

4. **Cherry-pick em lote** com todos os hashes numa chamada só:
   ```bash
   git cherry-pick <h1> <h2> ... <hN>
   ```

5. **Tratamento de conflitos**:
   - **Conflito real** (merge conflict em arquivos): PARE, mostre `git status`, liste os arquivos em conflito, e pergunte com AskUserQuestion: `resolver manualmente (aguardar)`, `pular esse commit (--skip)`, ou `abortar tudo (--abort)`. Nunca resolva conflitos automaticamente.
   - **Commit vazio / patch já aplicado** ("The previous cherry-pick is now empty"): execute `git cherry-pick --skip` automaticamente e siga.
   - **Modify/delete**: tratar como conflito real — pergunte ao usuário.

6. **Verificações finais** (obrigatórias, imprima o resultado):
   ```bash
   git log <base>..HEAD --format="%ae" | sort -u   # deve conter só o email do usuário
   git log <base>..HEAD --merges                    # deve estar vazio
   git log <base>..HEAD --oneline                   # lista final aplicada
   ```

7. **Restaure o stash** se foi criado no passo 1.

## Regras de segurança

- **Nunca faça push automático** — a branch é de release, exige revisão humana.
- **Nunca use `--no-verify`**, `--strategy-option=theirs/ours`, `cherry-pick --abort` ou `branch -D` sem confirmação explícita do usuário.
- **Não amende** commits já aplicados; se precisar corrigir algo, pergunte antes.
- Se a branch de origem tiver centenas de commits, confirme o volume com o usuário antes de disparar o cherry-pick em lote (mais de 50 commits é um bom limiar para perguntar).

## Saída esperada ao final

Reporte de forma concisa:
- Nome da branch criada.
- Quantidade de commits aplicados (e quantos foram pulados, se houver).
- Lista final de `git log <base>..HEAD --oneline`.
- Estado do working tree (limpo / stash restaurado / etc).
