# Follow Up

Приложение за follow up по стълбицата **Prospect → Interested → Close**.
Влиза се със същия акаунт като AKTIV90; контактите са общи (Supabase, таблица `contacts`, полета `fu_*`).

## Как работи

1-ви follow up → 2-ри follow up → Фаза 1 → Фаза 2 → Фаза 3.
След всяко пратено съобщение приложението пита на следващия ден (след Фаза 3 — след 2 дни):
„Върна ли се в разговора, или е време за следващото?“. „Върна се“ започва цикъла отначало.

## Файлове

| Файл | Какво е |
|---|---|
| `index.html` | Цялото приложение |
| `supabase.js`, `591.supabase.js` | Библиотеката за връзка със Supabase |
| `manifest.webmanifest`, `sw.js`, `icon*` | За инсталиране на телефона като приложение |
| `AKTIV90-handoff.md`, `aktiv90/` | Бележка и макет за агента на AKTIV90 |

## Пускане

GitHub: **Settings → Pages → Build and deployment → Source: Deploy from a branch → Branch: `main`, папка `/ (root)` → Save.**
След минута-две приложението е на `https://mishakaas623.github.io/Follow-up/`.

Текстовете на фазите са в `index.html`, в `PHASES` в началото на скрипта.
