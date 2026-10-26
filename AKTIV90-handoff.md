# За агента на AKTIV90: полета на Follow Up в таблицата `contacts`

Follow Up е отделно приложение (https://mishakaas623.github.io/Follow-up/, код: github.com/mishakaas623/Follow-up), което ползва **същия Supabase проект** (`avyfzcevzmcknsidizuo`),
**същите акаунти** и **същата таблица `contacts`**. Нищо в AKTIV90 не е променено и то продължава да работи както досега.

## Какво е добавено в базата (миграция `followup_columns_on_contacts`)

Само нови колони в `public.contacts` (RLS политиката `contacts_own` важи и за тях):

| Колона | Тип | Стойности |
|---|---|---|
| `fu_stage` | text, null | `prospect`, `interested`, `close`, `client`, `later`, `lost`; `null` = още не е разпределен |
| `fu_network` | text, null | `instagram`, `tiktok`, `facebook`, `viber`, `live` |
| `fu_source` | text, null | „Откъде е дошъл“: `Социални мрежи`, `Реклама`, `Събитие`, `Познат`, `Препоръка`, `Друго` |
| `fu_msgs` | smallint, default 0 | пратени обикновени follow up-и в текущия цикъл (0–2) |
| `fu_phase` | smallint, default 0 | последната пратена фаза (0–3) |
| `fu_next` | date, null | кога Follow Up ще пита „върна ли се в разговора?“ (или датата за напомняне при `later`) |
| `fu_last` | date, null | кога последно е писано на човека |
| `fu_back` | text, null | стъпалото, към което се връща човек от `later` / `lost` |
| `fu_log` | jsonb, default `[]` | история на действията |
| `fu_updated` | timestamptz, null | последна промяна от Follow Up |

Follow Up ползва и общите полета `name`, `info` (профил, линк или телефон) и `note`.

## Какво да добавиш във формата „Нов контакт“ в AKTIV90

Как трябва да изглежда: `aktiv90/form-desktop.png`, `aktiv90/form-phone.png` и макетът `aktiv90/form-mockup.html`.
Под реда „Име / Соц. мрежа / +“ се добавя блок „За Follow Up (по желание)“ с три реда бутончета. Нищо не е задължително;
ако нищо не е избрано, контактът се записва точно както досега.

Три незадължителни избора, за да отива контактът директно във Follow Up:

1. **Стъпало**: Prospect / Interested / Close → записва `fu_stage` (`prospect`, `interested`, `close`).
2. **Социална мрежа**: Instagram / TikTok / Facebook / Viber / На живо → `fu_network`.
3. **Откъде е дошъл**: Социални мрежи / Реклама / Събитие / Познат / Препоръка / Друго → `fu_source` (записва се текстът, напр. `"Препоръка"`).

Пример за insert:

```js
await sb.from("contacts").insert({
  user_id, name, info, note,
  fu_stage: "prospect",      // или null, ако не е избрано
  fu_network: "instagram",   // или null
  fu_source: "Препоръка"     // или null
});
```

Ако стъпало не е избрано, контактът се появява във Follow Up в „Нови от AKTIV90“ и там се разпределя с едно натискане.

## Важно: в AKTIV90 тези избори само се записват

- Не ги показвай никъде другаде в AKTIV90: нито в списъка с контакти, нито в картата на контакта, нито в отчетите.
- Модулите на AKTIV90 (контактиран, поканен, изпратен и т.н., полето `done`) остават както са и нямат връзка с Follow Up.
- След натискане на „+“ бутончетата се изчистват заедно с името и полето за профил.

## Контакти, създадени във Follow Up: да се броят като „+“ в AKTIV90

Когато някой добави контакт във Follow Up, той трябва да се отчете в AKTIV90 **точно както при натискане на „+“**
(записът в `contacts` и всичко, което „+“ прави по дневния брояч в `days.counts`).

Направи го с една функция в базата, която прави точно това, което прави „+“:

```sql
create or replace function public.add_contact(
  p_name text, p_info text default '', p_note text default '',
  p_fu_stage text default null, p_fu_network text default null, p_fu_source text default null
) returns public.contacts
language plpgsql security invoker set search_path = public as $$
declare c public.contacts;
begin
  insert into public.contacts (user_id, name, info, note, fu_stage, fu_network, fu_source)
  values (auth.uid(), p_name, coalesce(p_info, ''), coalesce(p_note, ''), p_fu_stage, p_fu_network, p_fu_source)
  returning * into c;
  -- ТУК: същото, което „+“ прави по days.counts за днешния ден (ако прави нещо)
  return c;
end $$;
grant execute on function public.add_contact(text, text, text, text, text, text) to authenticated;
```

- Follow Up вече вика `add_contact`, ако я има; ако я няма, просто записва реда в `contacts` (тогава контактът се вижда в списъка на AKTIV90, но не се брои като „+“).
- По желание и „+“ в AKTIV90 може да ползва същата функция — така логиката е на едно място.

## Какво да НЕ се прави

- Не трий и не преименувай колоните `fu_*`.
- Не презаписвай `fu_log` с празен масив при редакция на контакт. Ако AKTIV90 прави `update` на целия ред, нека пропуска полетата `fu_*`.
