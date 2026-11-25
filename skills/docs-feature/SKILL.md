---
name: docs-feature
description: Gera e atualiza a documentação de uma feature (negocio.md, tecnico.md, qa.md, rdm.md e pastas de outros repositórios) em docs-bhcosta90/<branch-ativa>/. Use SEMPRE ao concluir um brainstorming de implementação nova e SEMPRE ao concluir a implementação (para finalizar o qa.md e gerar o rdm.md), ou quando pedirem para criar, atualizar ou revisar a documentação, o roteiro de QA ou a RDM de uma feature.
---

# Documentação da feature
 
Gera os documentos de um card em dois momentos: ao final do brainstorming (`/brainstorming`) e ao final da implementação.
 
## Onde ficam
 
Tudo vai em `docs-bhcosta90/<branch-ativa>/`, na raiz do repositório atual.
 
- `<branch-ativa>` é o nome exato da branch (`git branch --show-current`), mantendo as barras, que viram subpastas. Sem data no caminho.
- Exemplo: na branch `bhcosta90/feature/oi`, o caminho fica `docs-bhcosta90/bhcosta90/feature/oi/`.
- Sem repositório git, ou com HEAD destacado, use um slug curto do card no lugar da branch e o diretório de trabalho atual como raiz.
- Todo arquivo em `docs-bhcosta90` é `.md`.
```
docs-bhcosta90/bhcosta90/feature/oi/
├── negocio.md          ← único, fonte das RNs
├── tecnico.md
├── qa.md               ← inclui os testes de ponta a ponta
├── rdm.md
├── pr.md               ← título e descrição do PR
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
| `pr.md` | Revisores do PR | Não cria | Cria |
| `<repo>/tecnico.md` | Devs do outro repo | Cria (Status `Pendente`) | Atualiza (Status `Aplicado`) |
| `<repo>/qa.md` | QA | Cria a versão inicial | Finaliza |
| `<repo>/rdm.md` | Gestão | Não cria | Cria |
 
O brainstorming só está concluído quando os documentos da coluna "No brainstorming" existirem.
 
## Modelos
 
### `negocio.md`
 
Escrito sem jargão técnico; um leitor de negócio precisa entender tudo. Regras numeradas RN01, RN02…, cada uma objetiva e verificável. Critérios de aceite em Dado / Quando / Então.
 
```markdown
# <Card>: documentação de negócio
 
## Contexto e problema
<!-- qual dor ou oportunidade motiva a mudança -->
 
## Objetivo
<!-- resultado esperado, mensurável quando possível -->
 
## Público / personas afetadas
 
## Escopo
 
### Entra
 
### Não entra
 
## Regras de negócio
 
- **RN01**: <regra objetiva e verificável>
 
## Fluxo do usuário
 
1. <passo, do ponto de vista de quem usa>
 
## Critérios de aceite
 
- **Dado** <contexto>, **quando** <ação>, **então** <resultado>.
 
## Métricas de sucesso
 
## Riscos, premissas e dependências
 
## Dúvidas em aberto
```
 
### `tecnico.md`
 
Cite caminhos reais do código quando existirem. Inclua as alternativas descartadas e o motivo. Mostre onde cada RNxx é implementada.
 
```markdown
# <Card>: documentação técnica
 
## Visão geral da solução
 
### Decisões de arquitetura
 
### Alternativas descartadas
 
| Alternativa | Motivo do descarte |
|---|---|
 
## Componentes afetados
<!-- arquivos, módulos, serviços, com caminhos reais do código -->
 
## Modelo de dados
<!-- tabelas/campos novos ou alterados, migrations -->
 
## Contratos de API
<!-- endpoints, payloads de request/response, códigos de erro -->
 
## Integrações externas e eventos
<!-- filas, webhooks, analytics -->
 
## Regras de negócio → implementação
 
| RN | Onde é tratada |
|---|---|
| RN01 | |
 
## Segurança e permissões
 
## Performance e escalabilidade
 
## Observabilidade
<!-- logs, métricas, alertas -->
 
## Estratégia de testes automatizados
 
## Plano de rollout e rollback
<!-- feature flag, migração de dados, ordem de deploy -->
 
## Débitos técnicos e pendências
```
 
### `qa.md`
 
O QA precisa executar sem ler o código. Tem duas etapas:
 
- **Versão inicial (brainstorming)**: casos de teste derivados das RNs, matriz de rastreabilidade e pré-requisitos. O que depende do código (nome de tela, texto exato de mensagem, flag) fica marcado como `A definir após implementação`.
- **Versão final (após a implementação)**: atualize passos e resultados esperados com o que foi construído, preencha tudo que estava `A definir após implementação` e ajuste os casos se a implementação divergiu do plano. Só então o roteiro está pronto para o QA.
```markdown
# <Card>: roteiro de QA
 
- **Versão**: Inicial | Final
 
## Pré-requisitos
 
- **Ambiente**:
- **Usuários / perfis de teste**:
- **Massa de dados**:
- **Flags habilitadas**:
 
## Casos de teste
 
<!--
Cobertura obrigatória: caminho feliz; cenários negativos e mensagens de erro;
casos de borda (valores limite, campos vazios, caracteres especiais, volume alto);
permissões (cada perfil); regressão de funcionalidades vizinhas;
plataformas (web/mobile/navegadores), quando aplicável.
-->
 
### CT01: <título>
 
- **Objetivo**:
- **Regra de negócio coberta**: RN01
- **Prioridade**: Alta | Média | Baixa
- **Pré-condições**:
- **Passos**:
  1.
- **Resultado esperado**:
 
## Matriz de rastreabilidade
 
| RN | Casos de teste |
|---|---|
| RN01 | CT01 |
 
## Checklist de smoke test pós-deploy
 
- [ ]
```
 
Toda RN precisa de pelo menos um CT.
 
### `rdm.md`
 
Descrição para a RDM. Descreve o que **de fato** foi feito, nunca o planejado. A descrição é sempre em nível de negócio.
 
```markdown
# <Card>: requisição de mudança
 
## Descrição
<!-- o que foi feito, em nível de negócio e sem jargão técnico -->
 
## Possível impacto
<!-- quem/o que pode ser afetado -->
 
## Prova do impacto ou de que não há impacto
<!-- evidência: testes, consultas, comparação antes/depois, escopo isolado -->
 
## Solução
<!-- como o problema foi resolvido -->
 
## Plano de implementação
 
## Plano de rollback
```
 
### `pr.md`
 
Título e descrição do PR, prontos para colar.
 
```markdown
# Título
 
<título curto do PR>
 
# Descrição
 
## O que muda
 
## Por quê
<!-- referência às RNs do negocio.md -->
 
## Como testar
<!-- resumo; o roteiro completo está no qa.md -->
 
## Observações
```
 
### `<repo>/tecnico.md`
 
```markdown
# <Card>: impacto em <nome-do-repositorio>
 
- **Repositório**: <nome, URL ou caminho local>
- **Branch de referência**: <branch>
- **Status**: Pendente | Aplicado
 
## Motivo
<!-- por que este repo precisa mudar e quais RNxx (do negocio.md da raiz) motivam a mudança -->
 
## Dependências e ordem de deploy
 
## Riscos de compatibilidade
<!-- breaking changes, versionamento de API, retrocompatibilidade -->
 
<!-- A partir daqui, as mesmas seções do tecnico.md da raiz -->
 
## Visão geral da solução
## Componentes afetados
## Modelo de dados
## Contratos de API
## Integrações externas e eventos
 
## Regras de negócio → implementação
 
| RN | Onde é tratada |
|---|---|
 
## Segurança e permissões
## Performance e escalabilidade
## Observabilidade
## Estratégia de testes automatizados
## Plano de rollout e rollback
## Débitos técnicos e pendências
 
## Alterações realizadas
<!-- preencher quando o Status virar Aplicado: branch criada neste repo, commits/PR, arquivos modificados e desvios em relação ao planejado -->
```
 
## Outros repositórios
 
Se o card exigir mudanças em outro repositório, crie uma pasta com o nome dele (ex.: `api-pagamentos/`).
 
- **Não crie `negocio.md` nem `pr.md` nas pastas de repositório.** O `negocio.md` da raiz é a única fonte das RNs; os outros documentos só fazem referência a elas.
- O `qa.md` do repositório segue o modelo do `qa.md` e cobre os testes dele. Testes de ponta a ponta, que passam por mais de um repositório, ficam no `qa.md` da raiz.
- O `rdm.md` do repositório segue o modelo do `rdm.md` e trata do deploy e do rollback daquele repositório.
- Quando a alteração for aprovada e executada a partir do repositório atual, atualize o `<repo>/tecnico.md`: Status para `Aplicado` e seção **Alterações realizadas** preenchida.
## Regras gerais
 
- Os documentos devem ser **consistentes entre si**, inclusive os das pastas de repositórios: mesmos IDs de regras (RNxx), mesma nomenclatura e mesmo escopo.
- O que ainda não foi definido vai para **Dúvidas em aberto** do `negocio.md`. Não invente.
- Se o brainstorming mudar de direção depois que os documentos existirem, atualize todos.
- Ao final, liste os caminhos dos arquivos gerados ou atualizados.
