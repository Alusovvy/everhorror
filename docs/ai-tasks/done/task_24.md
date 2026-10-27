# task_24: Dashboard — kolejka startów, automatyczne scalanie po arkuszu i wykrywanie konfliktów

<!--
Zadanie narzędziowe z czatu Rolanda 2026-10-27; wymagania to jego słowa, nie edytować.
-->

Wymagania:
Roland, czat 2026-10-27:
1. „Kolejke wdrozmy, ale dajmy scalanie automatycznie.”
2. Wybory w pytaniu koordynatora: kiedy scalać sam — „Po grze i arkuszu (Recommended)”; wypchnięcie i tag — „Push tak, tag ręcznie (Recommended)”.
3. „I te tree merge tez robimy”
4. Na propozycję gotowego importu Godota w nowej kopii gałęzi: „DopisZ”

Rodzaj: narzędzia · Zleca: Roland (czat, 2026-10-27)

Kontekst:
- Kolejka startów: jednym kliknięciem zlecić kilka przebiegów (np. „Analizuj wszystkie zaplanowane”); ruszają w wolne miejsca według limitów D-33, reszta czeka i startuje sama.
- Automatyczne scalanie ([D-35](../../archiwum/plan-historia-2026-10.md#decyzje-z-task_24-d-35)): dashboard scala gałąź sam, gdy przegląd kodu dał aktualne „gotowe”, testy przeszły, nie ma konfliktu i arkusz człowieka jest wypełniony bez ❌; potem wypycha master; tag wersji zostaje ręczny.
- „Tree merge”: wykrywanie konfliktów między otwartymi gałęziami i master przez `git merge-tree` (propozycja nr 4 agenta R4) zamiast zgadywania po ścieżkach.

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Co zostało zrobione
Kod w `master` specyfikacji (`205cf18`), agent Sonnet 5.5 max (wyjątkowo, na prośbę Rolanda), przegląd i scalenie: koordynator.
- **Kolejka startów:** „Analizuj wszystkie zaplanowane” i „Dodaj do kolejki” w oknie startu; kolejka zapisana na dysku, startuje w wolne miejsca według D-33, z powodem czekania; karta na Pracy i w Przebiegach (kolejność, usuwanie).
- **Scalanie automatyczne (D-35):** jedna funkcja warunków dla serwera i ekranu; dziennik decyzji, karta „Scalanie automatyczne” na Pracy z przełącznikiem; scala w imieniu osoby, która wypełniła arkusz, wypycha master, nie taguje. Wyłącznik: `EVERHORROR_AUTO_MERGE=0` albo przełącznik. Domyślnie włączone.
- **Konflikty przez `git merge-tree`:** odznaki na Pracy, w gałęzi, w oknie scalania i startu; prawdziwy konflikt blokuje równoległe wdrożenie bez potwierdzenia, czysta odpowiedź zdejmuje pytanie o „nieznane pliki”.
- **Pamięć importu Godota:** nowa kopia gałęzi dostaje `.godot/` z głównej kopii; pierwszy import trwa krótko.
- Przy okazji naprawiony błąd z task_23: okno startu nie pokazywało ramki „Pliki i trwające przebiegi”.
- Skille gry i `CLAUDE.md`: wyjątek D-35 od „scala tylko Roland”, pamięć importu.

## Decyzje i założenia
- „Testy przeszły” w warunkach D-35: ostatni przebieg wdrożenia albo poprawek zakończony `STATUS: ok`, aktualne „gotowe” z przeglądu kodu i aktualny build do ogrania głowy gałęzi (dashboard nie uruchamia pełnego zestawu testów gry).
- Arkusz ma wszystkie wymagane wiersze części zadania wypełnione, bez ❌ i bez ⏭; wypełniający musi być administratorem.

## Czego potrzebuję od Ciebie
- Jeśli wolisz najpierw obejrzeć auto-scalanie, uruchom dashboard raz z `EVERHORROR_AUTO_MERGE=0` albo wyłącz przełącznik na Pracy.

## Test
Automat (izolowane foldery): `npm test` 2275/2275, `npm run e2e` 40/40 w kilku powtórzeniach, build, lint 0. Bez przeglądarki i bez prawdziwego agenta/Godota (atrapy). Niestabilny test e2e nie odtworzył się w 10 przebiegach; dwa podejrzane miejsca wzmocnione.

## Podsumowanie
Dashboard sam uruchamia kolejne przebiegi z kolejki, sam scala gałąź po Twojej grze i arkuszu (z wyłącznikiem), widzi prawdziwe konflikty scalania i szybciej zakłada kopie gałęzi.
