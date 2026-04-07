# Ambient Life v2 — Runtime Binding Preflight (Daily Life v1)

Дата: 2026-04-07  
Статус: active companion preflight  
Назначение: быстрый целевой preflight для критичного operational риска runtime-контура — неполной привязки NPC lifecycle/event hooks, прежде всего `OnUserDefined`.

---

## 1) Зачем нужен отдельный preflight

Свежий аудит runtime-контура зафиксировал, что типовой провал owner-run чаще связан не с resolver/materialization логикой, а с неполной binding-настройкой hooks в Toolset, особенно `OnUserDefined`.

Этот preflight не заменяет `dl_smoke_milestone_a`, а дополняет его:
- smoke-runbook отвечает за сценарии `A–G`;
- binding preflight отвечает за быстрый ответ на вопрос: **проходит ли NPC runtime-контур через `OnUserDefined` dispatcher вообще**.

---

## 2) Как запускать

Запустить:
- `scripts/daily_life/dl_smoke_runtime_binding_preflight.nss`

Скрипт:
1. обходит все area модуля;
2. находит NPC, распознанных как Daily Life;
3. делает live-probe через `DL_SignalNpcUserDefined(..., DL_UD_RESYNC)`;
4. проверяет, что NPC действительно получил `resync pending` c причиной `DL_RESYNC_WORKER`;
5. пишет summary в лог и в module locals:
   - `dl_binding_preflight_checked`
   - `dl_binding_preflight_warnings`
   - `dl_binding_preflight_errors`

---

## 3) Что именно считается PASS / FAIL

### PASS
Для Daily Life NPC live-probe через `OnUserDefined` наблюдается корректно:
- после сигнала ставится `dl_resync_pending = TRUE`;
- причина становится `DL_RESYNC_WORKER`.

### FAIL
Для одного или более Daily Life NPC probe не даёт ожидаемого эффекта:
- это сильный индикатор, что `OnUserDefined` не привязан;
- либо привязан не `scripts/daily_life/dl_npc_onud`;
- либо slot перекрыт legacy/runtime-несовместимым скриптом.

---

## 4) Что preflight проверяет вручную, а не автоматически

Скрипт намеренно делает live-check только для `OnUserDefined`, потому что это:
- критический dispatcher path;
- безопасно проверяется без убийства/переспавна NPC;
- даёт самый сильный сигнал по event-driven контуру.

Следующие binding’и остаются обязательными, но подтверждаются manual checklist:
- `OnSpawn -> scripts/daily_life/dl_npc_onspawn`
- `OnDeath -> scripts/daily_life/dl_npc_ondeath`

---

## 5) Как использовать вместе с основным smoke

Рекомендуемый порядок перед owner-run:

1. Запустить `dl_smoke_runtime_binding_preflight`.
2. Продолжать только если в summary `errors=0`.
3. Затем запускать `dl_smoke_milestone_a`.
4. После этого фиксировать `A–G` в acceptance journal.

Такой порядок режет самый частый ложный сценарий:
«документация описывает корректный event-driven контур, но runtime фактически не проходит через обязательный dispatcher path».
