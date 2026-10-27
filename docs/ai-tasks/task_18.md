<!--
Zadanie narzędziowe z uwag Rolanda do przebiegu planowania w dashboardzie (spec-tasks, 2026-10-27). Wymagania to cytat słów Rolanda; nie edytować.
-->

# task_18: Dashboard — „Zmiany do wdrożenia” pod przyciskiem „Zaplanuj zadania”

Wymagania:
1. Roland, dashboard 2026-10-27: „Dodatkowo w zakładce Praca "Zmiany do wdrożenia" dałbym pod panelem "do zaplanowania i pod "zapalnuj zadania" bo inaczej to sugeruje że będzimy planować to co jest do wdrożenia.”

Rodzaj: narzędzia
Zleca: Roland (dashboard, 2026-10-27)

Kontekst:
- Kod dashboardu leży w repozytorium specyfikacji (`C:/dev/gamedev/everhorror/specification/dashboard`), tak jak przy task_15. Zadanie nie zmienia rozgrywki, więc nie dostaje wiersza w „W zadaniach” w `WDROZENIA.md`.

Kryteria akceptacji:
- W widoku Praca karta „Do zaplanowania” pokazuje najpierw liczniki, potem przycisk „Zaplanuj zadania (agent, Opus)”, a dopiero pod nim zwijaną listę „Zmiany do wdrożenia”.

Poza zakresem:
- Logika liczenia zmian (`derive.ts`, `semanticDiff`) i treść przycisku.

Priorytet: niski · Kolejność: —

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Analiza wstępna
- `dashboard/src/views/Work.tsx`, funkcja `PlanCard` (ok. linii 600–659): `<details className="wk-changes">` z listą „Zmiany do wdrożenia” stoi dziś przed `<ActionRow action={plan} …/>`. Wystarczy zamienić kolejność tych dwóch elementów; ewentualnie dopasować odstęp w `dashboard/src/views/work.css` (sekcja „Do zaplanowania”, ok. linii 290).
- Niejasność: „pod panelem "do zaplanowania" i pod "zaplanuj zadania"” czytam jako „pod licznikami karty i pod przyciskiem”. Gdyby Roland chciał osobnej karty pod całą kartą „Do zaplanowania”, to też drobna zmiana. Wykonawca wybiera pierwsze odczytanie i opisuje je w raporcie.
- Opcjonalnie, w duchu uwagi: nagłówek listy mógłby brzmieć „Zmiany w specyfikacji od ostatniego planowania”, ale wymaganie mówi tylko o położeniu, więc tekst zostaje, chyba że Roland poprosi.
- Sprawdzenie: testy dashboardu, które dotyczą widoku Praca (bez sieci i bez npm; uruchomić tylko to, co działa lokalnie), oraz zrzut albo opis widoku. Commit w specyfikacji po lincie, z komunikatem `[agent] proces: dashboard — …`.
