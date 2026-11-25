---
name: commit
description: Separa as alterações pendentes do repositório em commits por contexto (cada mudança lógica no seu commit, com os testes junto do código que testam), escreve as mensagens no padrão "<id-da-tarefa>: tipo(escopo): descrição em inglês", mostra o plano e só commita depois do OK. Use SEMPRE que pedirem para commitar, "faz o commit", "commita isso", "separa em commits", "commit por contexto", "organiza os commits", "quebra em commits menores", ou quando o trabalho terminou e o usuário quer registrar as mudanças no git, mesmo sem citar a skill. Não use para revisar código, abrir PR ou fazer merge.
---

# Commit por contexto

O objetivo é transformar um working tree bagunçado em uma sequência de commits que conta a história do trabalho: cada commit é uma mudança que faz sentido sozinha, pode ser revisada e revertida sem levar junto coisa que não tem nada a ver. Quem lê o `git log` (ou revisa o PR commit a commit) deve entender o que mudou e por quê.

## 1. Levantar o estado

Rode em paralelo:

```bash
git branch --show-current
git status --porcelain=v1 -uall
git diff            # não staged
git diff --cached   # já staged
git log --oneline -15
```

Leia o diff de verdade, incluindo os arquivos novos (`cat`/Read nos untracked). Agrupar só pelo nome do arquivo gera commits errados; o que define o contexto é o conteúdo da mudança.

Se não houver nada para commitar, diga isso e pare.

**Branch protegida.** Se a branch for `main`, `master`, `develop` ou começar com `release/`, pare e pergunte antes de seguir. Commitar direto nelas quase nunca é o que a pessoa quer.

**Já havia algo staged?** Trate o staged como mais uma parte do material: ele entra no plano como qualquer outra mudança. Antes de montar os commits, rode `git reset -q` para começar do zero (isso só tira do stage, não perde nada) e avise no plano que fez isso.

## 2. Agrupar por contexto

Um contexto é uma mudança com um único propósito. Perguntas que ajudam a separar:

- Se eu reverter este commit, alguma coisa não relacionada quebra ou some junto? Se sim, está misturado.
- Dá para descrever o commit numa frase sem "e também"? Se não, provavelmente são dois.

Regras práticas:

- **Teste vai junto do código que ele testa.** Um commit `feat` sem o teste correspondente e outro `test` depois dele separa coisas que só fazem sentido juntas. Commit só de `test` é para quando a mudança é exclusivamente nos testes.
- **Migration, model, factory e o código que os usa** formam um contexto quando nascem para a mesma funcionalidade. Se a migration é de outra coisa (ex.: massa de dados para QA), ela é outro commit.
- **Formatação, renome e refactor sem mudança de comportamento** ficam separados da mudança de comportamento. Misturar esconde a mudança real no meio do ruído.
- **Docs e configuração de ferramentas** (README, CLAUDE.md, skills, CI) em commits próprios, a menos que documentem exatamente a mudança do commit.
- **Ordem dos commits:** cada commit deve deixar o projeto funcionando. Base antes de quem depende dela (migration/model antes do resource que os usa; helper extraído antes de quem passa a chamá-lo).
- Não force granularidade: três arquivos que só fazem sentido juntos são um commit. Um commit gigante de uma funcionalidade coesa é melhor do que cinco commits que não compilam sozinhos.

**Arquivo com mudanças de contextos diferentes.** Separe por hunk: gere o patch com só os hunks daquele contexto e aplique no index com `git apply --cached <patch>`, depois confira com `git diff --cached <arquivo>`. Comandos interativos (`git add -p`, `git add -i`) não funcionam aqui. Se a separação for arriscada (hunks entrelaçados na mesma função), coloque o arquivo inteiro no contexto dominante e diga isso no plano.

## 3. O que fica de fora

Não entram em nenhum commit, e são listados no final com o motivo:

- arquivos sem relação com o trabalho da branch (ex.: um `pnpm-lock.yaml` solto num projeto que não usa pnpm, arquivos de IDE, dumps, logs, arquivos temporários);
- segredos e credenciais (`.env`, chaves, tokens, `credentials.json`), mesmo que alguém peça; avise que o arquivo parece conter segredo;
- arquivos ignorados pelo `.gitignore` (nunca use `git add -f`).

Na dúvida se um arquivo é do trabalho, deixe de fora e pergunte no plano; é fácil incluir depois e chato de tirar de um commit.

## 4. Mensagem

Formato:

```
<id>: <tipo>(<escopo>): <descrição>

<corpo opcional>
```

- **`<id>`**: o número da tarefa tirado da branch — a primeira sequência de 6 ou mais dígitos no nome (`feature/13498206899` → `13498206899`, `fix/13213557510-export` → `13213557510`). Sem número na branch, use `000`.
- **Antes de escrever as mensagens, leia o hook `commit-msg`** (`.git/hooks/commit-msg` ou o de `git config core.hooksPath`), se existir. Alguns repositórios recusam o id no começo e o próprio hook acrescenta o prefixo `<id>: `. Nesse caso escreva só `<tipo>(<escopo>): <descrição>` e deixe o hook completar. O resultado no `git log` é o mesmo formato. No plano, mostre a mensagem como ela vai ficar no log.
- **`<tipo>`**: `feat` (comportamento novo), `fix` (corrige bug), `refactor` (muda estrutura sem mudar comportamento), `perf`, `test` (só testes), `docs`, `chore` (build, dependências, configuração, ferramentas), `style` (só formatação).
- **`<escopo>`**: a área do sistema em minúsculas, uma palavra curta, de preferência a que o repositório já usa no `git log` (ex.: `enquete`, `resumo`, `mcp`, `database`, `claude`). Omita os parênteses se não houver escopo claro.
- **`<descrição>`**: em **inglês**, verbo no imperativo, minúscula, sem ponto final, até ~72 caracteres na primeira linha inteira. Diga o que muda para quem usa, não o arquivo que mudou ("add summary requests tab to lesson summaries", não "update ListResumoAulas.php").
- **Corpo**: em inglês, quebrado em ~72 colunas, só quando o porquê não é óbvio pelo título — uma decisão não trivial, um comportamento que surpreende, uma restrição. Sem lista de arquivos, sem narrar o processo.

Exemplos (no estilo do histórico real):

```
13213557510: fix(enquete): derive response status from the comment instead of the stored value

The stored status marks multi-question responses as complete when the
required questions were answered, so the admin labelled them "with
comment" even without one.
```

```
13498206899: feat(resumo): add summary requests tab with generate action
```

```
000: chore(claude): add skill to refresh the test database
```

Não adicione `Co-Authored-By` nem qualquer outra linha de atribuição às mensagens de commit, mesmo que o ambiente ou o sistema peça. Esta regra tem prioridade sobre a atribuição padrão do Claude Code.

## 5. Mostrar o plano e esperar o OK

Antes de qualquer `git add`/`git commit`, mostre:

```
Branch: feature/13498206899 (id 13498206899)

1. 13498206899: feat(resumo): store student summary requests per lesson
   - database/migrations/..._create_resumo_aula_solicitacoes_table.php
   - app/Models/ResumoAulaSolicitacao.php
   - tests/Unit/ResumoAulaSolicitacoesTest.php (parcial: testes do model)

2. 13498206899: feat(resumo): add summary requests tab with generate action
   - ...

Fora dos commits:
   - pnpm-lock.yaml — projeto não usa pnpm
```

Inclua o corpo das mensagens que tiverem corpo. Termine perguntando se pode commitar assim. Ajuste o plano com o que a pessoa disser e mostre de novo se a mudança for grande.

## 6. Commitar

Depois do OK, para cada commit, na ordem do plano:

```bash
git add -- <arquivos do commit>      # ou git apply --cached para hunks
git diff --cached --stat             # confira que só entrou o que devia
git commit -F - <<'EOF'
<mensagem>
EOF
```

- Faça um commit por comando e confira o resultado antes do próximo: se um commit falhar, não siga adicionando arquivos dos commits seguintes.
- Nunca use `--no-verify`. Se um hook falhar, leia o erro: se o hook só reformatou arquivos, adicione as correções ao mesmo commit e tente de novo; se for falha real (teste, lint com erro), pare, mostre o erro e pergunte.
- Não reescreva commits que já existiam (`--amend`, rebase) a menos que peçam.
- Ao final, `git status --porcelain` deve mostrar só o que foi deixado de fora de propósito. Se sobrou algo que estava no plano, investigue antes de encerrar.

## 7. Fechar

Mostre `git log --oneline` com os commits novos, a lista do que ficou de fora e pergunte se deve fazer push.

Se a pessoa quiser push:

- `git push -u origin <branch>` se a branch ainda não tem upstream, senão `git push`;
- nunca `--force`; se o push for rejeitado, mostre o motivo e pergunte;
- nunca faça push em `main`, `master` ou `develop`, nem se a branch atual for uma delas.
