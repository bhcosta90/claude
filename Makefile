CLAUDE_DIR ?= $(HOME)/.claude
REPO       ?= git@github.com:bhcosta90/claude.git
BRANCH     ?= main

# Skills de terceiros: a fonte da verdade é o skills.lock.json, cópia versionada
# do lock que o `npx skills` mantém em ~/.agents/.skill-lock.json.
# Instalou ou removeu uma skill com `npx skills`? Rode `make skills-sync`.
# Skills próprias ficam em skills/ e precisam ser liberadas no .gitignore.
AGENTS_LOCK := $(HOME)/.agents/.skill-lock.json
REPO_LOCK   := $(CLAUDE_DIR)/skills.lock.json
SKILLS_JS   := node $(CLAUDE_DIR)/scripts/skills.mjs
SKILLS_CLI  := npx -y skills

# Origem padrão do `make skill-add` (a mesma do `npx claude-code-templates`)
SRC ?= davila7/claude-code-templates
# Aceita "categoria/nome" (formato do claude-code-templates) ou só "nome"
SKILL_NAME = $(notdir $(SKILL))

.DEFAULT_GOAL := help
.PHONY: help install link-repo skill-add skill-remove skills-install update skills-update skills-sync skills-check status save

help: ## Lista os comandos disponíveis
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "} {printf "  make %-15s %s\n", $$1, $$2}'

install: link-repo skills-install ## Primeira instalação: liga o ~/.claude ao repo e instala as skills externas

link-repo: ## Transforma o ~/.claude em clone do repo sem sobrescrever arquivos locais
	@if [ -d "$(CLAUDE_DIR)/.git" ]; then \
		echo "$(CLAUDE_DIR) já é um repositório git."; \
	else \
		mkdir -p "$(CLAUDE_DIR)" && cd "$(CLAUDE_DIR)" && \
		git init -q -b $(BRANCH) && \
		git remote add origin $(REPO) && \
		git fetch -q origin && \
		git reset -q origin/$(BRANCH) && \
		git branch -q --set-upstream-to=origin/$(BRANCH) && \
		git ls-files --deleted -z | xargs -0 -r git checkout -- && \
		echo "$(CLAUDE_DIR) ligado a $(REPO) ($(BRANCH))."; \
		git -C "$(CLAUDE_DIR)" status --short; \
	fi

skill-add: ## Instala uma skill externa e sincroniza (make skill-add SKILL=development/senior-qa [SRC=dono/repo])
	@test -n "$(SKILL)" || { echo 'Uso: make skill-add SKILL=<categoria/nome ou nome> [SRC=dono/repo]'; exit 1; }
	$(SKILLS_CLI) add $(SRC) --skill $(SKILL_NAME) -g -a claude-code -y < /dev/null
	@$(MAKE) -s skills-sync

skill-remove: ## Remove uma skill externa e sincroniza (make skill-remove SKILL=senior-qa)
	@test -n "$(SKILL)" || { echo 'Uso: make skill-remove SKILL=<nome>'; exit 1; }
	$(SKILLS_CLI) remove $(SKILL_NAME) -g -y < /dev/null
	@$(MAKE) -s skills-sync

skills-install: ## Instala as skills externas registradas no skills.lock.json
	@$(SKILLS_JS) | while read -r source skill; do \
		echo "==> $$skill ($$source)"; \
		$(SKILLS_CLI) add $$source --skill $$skill -g -a claude-code -y < /dev/null || exit 1; \
	done

update: ## Atualiza o repo (git pull) e as skills externas
	git -C "$(CLAUDE_DIR)" pull --ff-only origin $(BRANCH)
	$(MAKE) skills-install
	$(MAKE) skills-update

skills-update: ## Atualiza só as skills externas
	$(SKILLS_CLI) update -g -y

skills-sync: ## Registra as skills externas instaladas e faz commit + push direto na main
	@test "$$(git -C "$(CLAUDE_DIR)" branch --show-current)" = "$(BRANCH)" || { \
		echo "Mude para a $(BRANCH) antes: git -C $(CLAUDE_DIR) checkout $(BRANCH)"; exit 1; }
	@test -f "$(AGENTS_LOCK)" || { echo "Não encontrei $(AGENTS_LOCK)."; exit 1; }
	git -C "$(CLAUDE_DIR)" pull -q --ff-only origin $(BRANCH)
	cp "$(AGENTS_LOCK)" "$(REPO_LOCK)"
	git -C "$(CLAUDE_DIR)" add skills.lock.json
	@if git -C "$(CLAUDE_DIR)" diff --cached --quiet; then \
		echo "Nenhuma skill nova ou removida."; \
	else \
		git -C "$(CLAUDE_DIR)" commit -q -m "chore(skills): sync external skills" && \
		git -C "$(CLAUDE_DIR)" push -q origin $(BRANCH) && \
		echo "Skills externas sincronizadas e enviadas para a $(BRANCH)."; \
	fi

skills-check: ## Avisa se há skills externas instaladas e ainda não sincronizadas
	@if [ -f "$(AGENTS_LOCK)" ] && ! cmp -s "$(AGENTS_LOCK)" "$(REPO_LOCK)"; then \
		echo "Atenção: há skills externas não sincronizadas. Rode: make skills-sync"; \
	fi

status: skills-check ## Mostra alterações locais ainda não enviadas ao repo
	@git -C "$(CLAUDE_DIR)" status --short --branch

save: skills-check ## Commita e envia tudo que mudou (uso: make save MSG="mensagem")
	@test -n "$(MSG)" || { echo 'Informe a mensagem: make save MSG="..."'; exit 1; }
	git -C "$(CLAUDE_DIR)" add -A
	git -C "$(CLAUDE_DIR)" commit -m "$(MSG)"
	git -C "$(CLAUDE_DIR)" push origin $(BRANCH)
