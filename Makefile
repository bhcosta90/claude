CLAUDE_DIR ?= $(HOME)/.claude
REPO       ?= git@github.com:bhcosta90/claude.git
BRANCH     ?= main

# Skills de terceiros: "<repositório-github>:<nome-da-skill>"
# Instaladas via `npx skills` e ignoradas pelo git (ver .gitignore).
EXTERNAL_SKILLS := \
	obra/superpowers:brainstorming \
	vercel-labs/skills:find-skills

SKILLS_CLI := npx -y skills

.DEFAULT_GOAL := help
.PHONY: help install link-repo skills-install update skills-update status save

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

skills-install: ## Instala as skills externas listadas em EXTERNAL_SKILLS
	@for item in $(EXTERNAL_SKILLS); do \
		repo=$${item%%:*}; skill=$${item##*:}; \
		echo "==> $$skill ($$repo)"; \
		$(SKILLS_CLI) add $$repo --skill $$skill -g -a claude-code -y || exit 1; \
	done

update: ## Atualiza o repo (git pull) e as skills externas
	git -C "$(CLAUDE_DIR)" pull --ff-only origin $(BRANCH)
	$(MAKE) skills-update

skills-update: ## Atualiza só as skills externas
	$(SKILLS_CLI) update -g -y

status: ## Mostra alterações locais ainda não enviadas ao repo
	@git -C "$(CLAUDE_DIR)" status --short --branch

save: ## Commita e envia tudo que mudou (uso: make save MSG="mensagem")
	@test -n "$(MSG)" || { echo 'Informe a mensagem: make save MSG="..."'; exit 1; }
	git -C "$(CLAUDE_DIR)" add -A
	git -C "$(CLAUDE_DIR)" commit -m "$(MSG)"
	git -C "$(CLAUDE_DIR)" push origin $(BRANCH)
