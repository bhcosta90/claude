---
name: docs-feature
description: Gera e atualiza a documentação de uma feature (negocio.md, tecnico.md, qa.md, rdm.md e pastas de outros repositórios) em docs-bhcosta90/<branch-ativa>/. Use SEMPRE ao concluir um brainstorming de implementação nova e SEMPRE ao concluir a implementação (para finalizar o qa.md e gerar o rdm.md), ou quando pedirem para criar, atualizar ou revisar a documentação, o roteiro de QA ou a RDM de uma feature.
---

# Documentação de feature

Gera os documentos de uma feature em dois momentos: ao final do brainstorming e ao final da implementação.

## Onde ficam

Tudo vai em `docs-bhcosta90/<branch-ativa>/`, na raiz do repositório atual.

- `<branch-ativa>` é o nome exato da branch (`git branch --show-current`), mantendo as barras. As barras viram subpastas.
- Exemplo: na branch `bhcosta90/feature/oi`, o caminho fica `docs-bhcosta90/bhcosta90/feature/oi/`.
- Sem repositório git, ou com HEAD destacado, use um slug curto da feature no lugar da branch e o diretório de trabalho atual como raiz.

```
docs-bhcosta90/bhcosta90/feature/oi/
├── negocio.md          ← único, fonte das RNs
├── tecnico.md
├── qa.md               ← inclui os testes de ponta a ponta
├── rdm.md
├── api-pagamentos/     ← uma pasta por outro repositório afetado
│   ├── tecnico.md
│   ├── qa.md
│   └── rdm.md
└── app-mobile/
    ├── tecnico.md
    ├── qa.md
    └── rdm.md
```

## Quando gerar cada documento

| Documento | Público | No brainstorming | Após a implementação |
|---|---|---|---|
| `negocio.md` | PO, stakeholders, áreas de negócio | Cria | Atualiza se o escopo mudou |
| `tecnico.md` | Devs, Tech Lead | Cria | Atualiza se a implementação divergiu |
| `qa.md` | QA | Cria a versão inicial | Finaliza |
| `rdm.md` | Gestão, aprovadores da mudança | Não cria | Cria |
| `<repo>/tecnico.md` | Devs do outro repo | Cria (Status `Pendente`) | Atualiza (Status `Aplicado`) |
| `<repo>/qa.md` | QA | Cria a versão inicial | Finaliza |
| `<repo>/rdm.md` | Gestão | Não cria | Cria |

O brainstorming só está concluído quando os documentos da coluna "No brainstorming" existirem.

## Como preencher

Use os modelos de `templates/` (caminho relativo a esta skill) como estrutura de cada arquivo:

- `templates/negocio.md`: escrito sem jargão técnico; um leitor de negócio precisa entender tudo. Regras numeradas RN01, RN02…, cada uma objetiva e verificável. Critérios de aceite em Dado / Quando / Então.
- `templates/tecnico.md`: cite caminhos reais do código quando existirem. Inclua as alternativas descartadas e o motivo. Mostre onde cada RNxx é implementada.
- `templates/qa.md`: o QA precisa executar sem ler o código. Ver "Duas etapas do qa.md" abaixo.
- `templates/rdm.md`: descreve o que **de fato** foi feito, nunca o planejado. O resumo é sempre em nível de negócio.
- `templates/tecnico-repo.md`: `tecnico.md` das pastas de outros repositórios.

### Duas etapas do `qa.md`

- **Versão inicial (brainstorming)**: casos de teste derivados das RNs, matriz de rastreabilidade e pré-requisitos. O que depende do código (nome de tela, texto exato de mensagem, flag) fica marcado como `A definir após implementação`.
- **Versão final (após a implementação)**: atualize passos e resultados esperados com o que foi construído, preencha tudo que estava `A definir após implementação` e ajuste os casos se a implementação divergiu do plano. Só então o roteiro está pronto para o QA.

### Outros repositórios

Se a feature exigir mudanças em outro repositório, crie uma pasta com o nome dele (ex.: `api-pagamentos/`).

- **Não crie `negocio.md` nas pastas de repositório.** O `negocio.md` da raiz é a única fonte das RNs; os outros documentos só fazem referência a elas.
- O `qa.md` do repositório cobre os testes dele. Testes de ponta a ponta, que passam por mais de um repositório, ficam no `qa.md` da raiz.
- O `rdm.md` do repositório trata do deploy e do rollback daquele repositório.
- Quando a alteração for aprovada e executada a partir do repositório atual, atualize o `<repo>/tecnico.md`: Status para `Aplicado` e seção **Alterações realizadas** preenchida.

## Regras gerais

- Os documentos devem ser **consistentes entre si**, inclusive os das pastas de repositórios: mesmos IDs de regras (RNxx), mesma nomenclatura e mesmo escopo.
- O que ainda não foi definido vai para **Dúvidas em aberto**. Não invente.
- Se o brainstorming mudar de direção depois que os documentos existirem, atualize todos.
- Ao final, liste os caminhos dos arquivos gerados ou atualizados.
