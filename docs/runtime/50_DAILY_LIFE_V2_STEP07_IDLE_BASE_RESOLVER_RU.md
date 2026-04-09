# 50 — Daily Life v2 Step 07: IDLE_BASE Fallback (RU)

> Дата: 2026-04-09  
> Статус: implementation slice in progress

## 1) Цель шага

Добавить безопасный fallback после `SLEEP` и `WORK`.

## 2) Что добавлено

- директива `IDLE_BASE`
- fallback helper
- расширенный basic resolver: `SLEEP -> WORK -> IDLE_BASE`

## 3) Ключевой архитектурный принцип

Resolver теперь построен как **цепочка условий**:

1. sleep rule
2. work rule
3. fallback

Это означает, что новые условия в будущем добавляются так:

```
if (NEW_CONDITION)
    return NEW_DIRECTIVE;
```

**между существующими слоями**, без переписывания логики.

## 4) Почему это важно

- нет жёсткой связки логики
- легко вставлять новые правила (base, override, события)
- не ломается существующее поведение

## 5) Smoke

Проверяет:
- sleep работает
- work работает
- остальное время → idle_base

## 6) Следующий шаг

Добавление новых условий в resolver без переписывания текущей цепочки.
