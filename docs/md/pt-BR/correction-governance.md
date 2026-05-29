# Correção e governança

O HMG usa um **modelo de correção e governança apenas com acréscimo**. Os átomos nunca são sobrescritos silenciosamente. As correções criam novos átomos com relacionamentos explícitos, e as transições de governança preservam o histórico completo.

## Estados do ciclo de vida dos átomos

### Polaridade

| Polaridade | Significado |
|---|---|
| `positive` | O átomo é afirmado como verdadeiro |
| `negative` | O átomo foi negado ou substituído |
| `neutral` | Informativo — sem afirmação de verdade |

### Status epistêmico

| Status | Significado |
|---|---|
| `claimed` | Afirmação não verificada |
| `confirmed` | Verificado por evidência ou autoridade |
| `deprecated` | Não mais relevante, mas não falso |
| `unknown` | Informações insuficientes para classificar |

### Estado de exposição (governança)

| Estado | Recuperável | Significado |
|---|---|---|
| `normal` | ✅ Recuperação normal | Estado padrão |
| `quarantined` | ❌ Oculto da recuperação | Em revisão por sensibilidade |
| `sealed` | ❌ Oculto, imutável | Restrição legal ou de política |
| `tombstoned` | ❌ Oculto, payload opcional | Marcado para remoção |
| `lesson` | ✅ Apenas lição | Payload sensível substituído por lição segura |

## Fluxo de correção

As correções criam arestas `Supersedes` explícitas entre átomos:

```text
Átomo original (positive)
    │
    ├── negate ──→ Novo átomo (negative) + aresta Supersedes
    ├── confirm_actual ──→ Polaridade original confirmada + aresta Supersedes
    ├── confirm_necessary ──→ Necessidade original confirmada
    ├── demote ──→ Status epistêmico original rebaixado
    └── replace ──→ Novo átomo (positive) + aresta Supersedes + novo conteúdo
```

### Ações de correção

| Ação | Efeito |
|---|---|
| `negate` | Cria átomo de polaridade negativa que substitui o alvo |
| `confirm_actual` | Confirma a precisão factual do átomo |
| `confirm_necessary` | Confirma que o átomo permanece relevante |
| `demote` | Rebaixa o status epistêmico (ex: confirmed → deprecated) |
| `replace` | Cria novo átomo com conteúdo atualizado, substitui o antigo |


## Fluxo de governança

```text
normal → quarantined (em revisão)
quarantined → sealed (bloqueado, imutável)
quarantined → tombstoned (removido da recuperação)
quarantined → normal (liberado, restaurado)
qualquer → derive_lesson (substituir payload por resumo seguro)
```

### Ações de governança

| Ação | De → Para | Caso de uso |
|---|---|---|
| `quarantine` | normal → quarantined | Conteúdo suspeito de sensibilidade |
| `seal` | quarantined → sealed | Retenção legal, conformidade |
| `tombstone` | quarantined → tombstoned | Remover da recuperação |
| `derive_lesson` | qualquer → lesson | Extrair lição segura, remover payload sensível |


## Histórico de instantâneos

Cada ação de correção e governança cria um instantâneo imutável. A ferramenta `memory_history` retorna a cadeia completa.

## Visões de recuperação

| Visão | Mostra | Caso de uso |
|---|---|---|
| `normal` | Apenas átomos ativos | Uso diário do agente |
| `governance` | + Átomos em quarentena/lacrados | Revisão de conformidade |
| `audit` | + Todos os átomos incluindo tombstonados | Investigação forense |
