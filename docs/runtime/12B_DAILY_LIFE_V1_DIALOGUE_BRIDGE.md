# Ambient Life v2 — Daily Life v1 Dialogue Bridge

Дата: 2026-04-05  
Статус: implementation foundation  
Назначение: зафиксировать безопасный мост между runtime-state Daily Life и реальными NWN2 `.dlg`/store-сценариями.

---

## 1) Главный принцип

Daily Life остаётся **источником истины** для разговоров.

`.dlg` не должен сам:
- вычислять schedule window;
- решать, работает ли NPC;
- решать, доступен ли сервис;
- выбирать override-режим;
- дублировать runtime-логику через набор разрозненных conditional scripts.

`.dlg` должен читать уже подготовленные Daily Life locals:
- `dl_current_directive`
- `dl_dialogue_mode`
- `dl_service_mode`
- `dl_current_anchor_group`

---

## 2) Добавленный foundation-layer

### 2.1 Include
- `scripts/daily_life/dl_dialogue_bridge_inc.nss`

Назначение:
- безопасно подготовить interaction state перед разговором;
- не ломать explicit states (`ABSENT`, `UNASSIGNED`);
- дать helper для проверки service/dialogue режимов;
- дать helper для открытия store через Daily Life service-gate.

### 2.2 Event scripts
- `scripts/daily_life/dl_on_conversation.nss`
- `scripts/daily_life/dl_conversation_end.nss`
- `scripts/daily_life/dl_conversation_abort.nss`

Назначение:
- на старте разговора делать safe refresh interaction state;
- на end/abort приводить interaction locals обратно к актуальному runtime-состоянию.

### 2.3 Condition scripts
- `scripts/daily_life/gc_dl_conversation_available.nss`
- `scripts/daily_life/gc_dl_service_available.nss`
- `scripts/daily_life/gc_dl_service_limited.nss`
- `scripts/daily_life/gc_dl_service_any.nss`
- `scripts/daily_life/gc_dl_dialogue_work.nss`
- `scripts/daily_life/gc_dl_dialogue_off_duty.nss`
- `scripts/daily_life/gc_dl_dialogue_inspection.nss`
- `scripts/daily_life/gc_dl_dialogue_lockdown.nss`
- `scripts/daily_life/gc_dl_dialogue_unavailable.nss`

### 2.4 Action scripts
- `scripts/daily_life/ga_dl_open_store.nss`

Назначение:
- открывать store только если Daily Life service-state реально допускает обслуживание.

---

## 3) Safe conversation contract

## 3.1 OnConversation

На NPC, который использует Daily Life dialogue bridge, нужно ставить:
- `OnConversation -> scripts/daily_life/dl_on_conversation`

Этот script делает только safe interaction refresh.

Он **не** должен:
- materialize-ить NPC заново;
- двигать NPC;
- переписывать explicit base-lost ветки.

## 3.2 Conversation End / Abort

В `.dlg` нужно использовать:
- `End Conversation Script -> scripts/daily_life/dl_conversation_end`
- `Abort Conversation Script -> scripts/daily_life/dl_conversation_abort`

Причина:
- в NWN2 разговор может завершаться нормально или обрываться через GUI / distance / combat / Escape;
- interaction-state должен возвращаться к актуальному Daily Life состоянию в обоих случаях.

---

## 4) Store integration contract

## 4.1 Главный принцип

Store не должен открываться просто потому, что NPC «торговец по профессии».

Store открывается только если:
- `dl_service_mode == DL_SERVICE_AVAILABLE`
- или `dl_service_mode == DL_SERVICE_LIMITED`

Если `service_mode = DISABLED/NONE`, диалог должен уводить игрока в разговорную ветку без открытия store.

## 4.2 Как привязать store

На NPC можно задать один из двух вариантов:
- `dl_conv_store_object` -> object-local store
- `dl_conv_store_tag` -> tag store-объекта

Опционально:
- `dl_conv_store_markup`
- `dl_conv_store_markdown`

## 4.3 Как открывать

Внутри `.dlg` action на реплике/ответе должен вызывать:
- `scripts/daily_life/ga_dl_open_store`

Не нужно открывать store в обход Daily Life-проверки.

---

## 5) Recommended `.dlg` pattern

### 5.1 Верхний gating

У корневой talk-ветки NPC рекомендуется использовать:
- `gc_dl_conversation_available`

Это режет ветки для `ABSENT/UNASSIGNED` без дублирования логики.

### 5.2 Ветки по dialogue mode

Рабочие condition scripts:
- `gc_dl_dialogue_work`
- `gc_dl_dialogue_off_duty`
- `gc_dl_dialogue_inspection`
- `gc_dl_dialogue_lockdown`
- `gc_dl_dialogue_unavailable`

### 5.3 Ветки по service mode

Для сервиса:
- `gc_dl_service_available`
- `gc_dl_service_limited`
- `gc_dl_service_any`

Рекомендация:
- `AVAILABLE` -> полная торговля/сервис;
- `LIMITED` -> ограниченный сервис или отдельный диалог;
- `DISABLED/NONE` -> только реплика без store.

---

## 6) Что этот foundation-layer сознательно НЕ делает

- не переписывает существующие `.dlg` автоматически;
- не вводит отдельную store-FSM;
- не заменяет реальные dialogue-conditional scripts module-specific логики;
- не materialize-ит NPC на старте разговора;
- не чинит сам по себе весь City Response / Legal / Trade слой.

---

## 7) Важное правило для multi-speaker сцен

Даже если `.dlg` использует Speaker Tag и строку произносит другой NPC, владельцем conversation scripts остаётся исходный conversation owner.

Следствие:
- `OBJECT_SELF` в bridge-скриптах должен пониматься как conversation owner;
- нельзя бездумно писать locals в «текущего говорящего» только потому, что строку произносит не owner.

---

## 8) Следующий cleanup-step после foundation

После подключения этого bridge-layer следующим шагом нужно:
1. привести конкретные `.dlg` NPC к чтению Daily Life locals;
2. проверить store-ветки на `AVAILABLE/LIMITED/DISABLED`;
3. отдельно вычистить конфликтные override-случаи (`FIRE`, `QUARANTINE`, base-lost) там, где directive/dialogue/materialization расходятся.
