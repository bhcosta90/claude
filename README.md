# Configuração do Claude Code

Minha configuração global do [Claude Code](https://claude.com/claude-code), versionada para ter o mesmo setup em qualquer máquina. Este repositório **é** o `~/.claude`.

## O que tem aqui

| Caminho | Conteúdo |
|---|---|
| `CLAUDE.md` | Instruções globais: fluxo de implementação nova e regras de Git |
| `skills/docs-feature/` | Skill própria: documentação de feature (negócio, técnico, QA, RDM) |
| `skills/commit/` | Skill própria: commits separados por contexto |
| `commands/` | Comandos personalizados (ex.: `/cherry-pick-release`) |
| `skills.lock.json` | Lista das skills de terceiros (nome e origem), instaladas via `npx skills` |
| `Makefile` | Comandos para instalar, atualizar e salvar a configuração |
| `scripts/skills.mjs` | Apoio do Makefile para ler o `skills.lock.json` |

Todo o resto do `~/.claude` (credenciais, `settings.json`, histórico, sessões, cache) é ignorado pelo `.gitignore`, que funciona como lista de permissão: só entra o que está liberado explicitamente.

## Pré-requisitos

- `git`, com chave SSH cadastrada no GitHub
- `make`
- Node.js (para o `npx`)
- Claude Code instalado

## Instalação em uma máquina nova

O `~/.claude` normalmente já existe (o Claude Code cria ao ser instalado), então não dá para clonar direto nele. Clone em uma pasta temporária e deixe o `make install` fazer a ligação:

```bash
git clone git@github.com:bhcosta90/claude.git /tmp/claude-setup
make -C /tmp/claude-setup install
rm -rf /tmp/claude-setup
```

O `make install`:

1. Transforma o `~/.claude` em um clone deste repositório **sem sobrescrever nenhum arquivo local**.
2. Instala as skills de terceiros listadas no `skills.lock.json`.

Se já existia um `CLAUDE.md` (ou outro arquivo versionado) diferente na máquina, ele é mantido e aparece como modificado no `git status`. Para ficar com a versão do repositório:

```bash
git -C ~/.claude checkout -- CLAUDE.md
```

### Alias `ccm`

Para não digitar `make -C ~/.claude` toda vez, adicione ao `~/.zshrc` (ou `~/.bashrc`):

```bash
# Configuração do Claude Code (~/.claude): make skill-add, save, update...
alias ccm="make --no-print-directory -C ~/.claude"
```

Depois rode `source ~/.zshrc`. Os exemplos abaixo usam o alias; sem ele, troque `ccm` por `make -C ~/.claude`.

## Uso

| Comando | O que faz |
|---|---|
| `ccm help` | Lista os comandos disponíveis |
| `ccm skill-add <categoria/nome>` | Instala uma skill do claude-code-templates e sincroniza |
| `ccm skill-add <dono/repo> <nome>` | Instala uma skill de outro repositório e sincroniza |
| `ccm skill-remove <nome>` | Remove uma skill de terceiros e sincroniza |
| `ccm save "mensagem"` | `git add` + commit + push de tudo que mudou |
| `ccm status` | Mostra o que mudou e avisa se há skills não sincronizadas |
| `ccm update` | `git pull` + instala skills novas + atualiza as existentes |
| `ccm skills-sync` | Registra no repositório as skills instaladas por fora do `skill-add` |
| `ccm install` | Primeira instalação (ver acima) |

Os comandos que fazem commit (`skill-add`, `skill-remove`, `skills-sync` e `save`) enviam **direto para a `main`**.

## Skills

Há dois tipos de skill, tratados de formas diferentes.

### Skills de terceiros

Não são copiadas para o repositório. O `skills.lock.json` guarda só o nome e a origem de cada uma, e o `make` reinstala a partir disso.

**Instalar:**

```bash
# Do claude-code-templates: use o mesmo valor do --skill
ccm skill-add development/senior-qa

# De outro repositório: origem primeiro, depois o nome
ccm skill-add obra/superpowers brainstorming
```

O `skill-add` instala com `npx skills`, atualiza o `skills.lock.json` e faz commit + push.

**Equivalência com o claude-code-templates:**

```bash
# em vez de
npx claude-code-templates@latest --skill development/senior-qa
# use
ccm skill-add development/senior-qa
```

O `npx claude-code-templates` não registra a skill em lugar nenhum, então ela se perderia em uma máquina nova. O `skill-add` usa como origem padrão o repositório do claude-code-templates (`davila7/claude-code-templates`).

**Descobrir a origem de uma skill:**

```bash
npx skills find <nome>
```

O resultado mostra `dono/repo@nome`. A parte antes do `@` é a origem. Também dá para procurar em [skills.sh](https://skills.sh).

**Remover:**

```bash
ccm skill-remove senior-qa
```

> Não copie skills de terceiros direto para `~/.claude/skills/`: elas ficam fora do `skills.lock.json` e são ignoradas pelo git. Se instalou com `npx skills add` direto, rode `ccm skills-sync` depois. O `ccm status` avisa quando há algo não sincronizado.

### Skills próprias

São versionadas inteiras no repositório.

1. Crie a skill em `~/.claude/skills/<nome>/SKILL.md`.
2. Libere a pasta no `.gitignore`, junto das outras skills próprias:

   ```gitignore
   !skills/<nome>/
   !skills/<nome>/**
   ```

3. Salve:

   ```bash
   ccm save "feat(skills): add <nome>"
   ```

## Manter atualizado

```bash
ccm update   # traz mudanças feitas em outra máquina e atualiza as skills
ccm status   # confere se ficou algo para enviar
```

## Regras do `CLAUDE.md`

Resumo do que o Claude segue em todos os projetos:

- **Implementação nova**: se a branch for `main`, `master` ou `develop`, cria `bhcosta90/feature/<slug>` a partir da `main`/`master`; começa pela skill `brainstorming`.
- **Documentação** (skill `docs-feature`), em `docs-bhcosta90/<branch>/` no repositório do projeto:
  - no brainstorming: `negocio.md`, `tecnico.md`, `qa.md` (versão inicial) e uma pasta por outro repositório afetado;
  - após a implementação: `qa.md` (versão final) e `rdm.md`.
- **Git**: a `develop` nunca entra em outra branch. "Merge com a develop" significa levar a branch **para** a `develop`.
