# task_23: Dashboard — jeden pisarz buchalterii, dwa wdrożenia naraz i czytelniejsze polskie nazwy

<!--
Zadanie narzędziowe z czatu Rolanda 2026-10-27; wymagania to jego słowa, nie edytować.
-->

Wymagania:
Roland, czat 2026-10-27, odpowiedź na pytania koordynatora po task_19 (1: dostęp sesji terminalowych do `../everhorror-wt`, 2: R4 — dwa wdrożenia naraz, 3: R1 — reguła gałęzi `master` w GitHubie, 4: zgłoszenie „Czytelność nazw”): „Nie mają dostępu. 2. ok, 3. ok, 4 . ok”

Rodzaj: narzędzia · Zleca: Roland (czat, 2026-10-27)

Kontekst:
- R3 i R4 opisuje `specification/dashboard/ARCHITEKTURA.md` („Plan: jeden pisarz buchalterii”) oraz plan, [D-33](../analizy/final-plan-human-readable.md#decyzje-z-task_23-d-33d-34). R4 bez R3 dawałby konflikty w `WDROZENIA.md`, więc najpierw R3.
- „Czytelność nazw”: `specification/zgloszenia/2026-10-27_czytelnosc-nazw.md` (wiersz 3 arkusza odbioru task_19, niski priorytet). Zasady i słowniczek: `specification/dashboard/UI.md`.
- R1 zrobione przez koordynatora: reguła GitHub `master — bez force push i usuwania (R1)` w repozytorium gry (id 25967090).
- Punkt 1: sesje terminalowe gry nie dostają dostępu do `../everhorror-wt` (`.claude/settings.json` bez zmian).

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Plan

| ID | Fala | Zakres | Model | Stan |
|---|---|---|---|---|
| R1 | — | Reguła gałęzi `master` gry w GitHubie: zakaz force push i usuwania | koordynator | zrobione |
| T23-r3 | 1 | R3: jeden pisarz buchalterii (`cli.ts ledger`, krótka blokada zapisu, dziennik, strażnik, skille) | Sonnet high | w pracy |
| T23-nazwy | 1 | Czytelniejsze polskie nazwy w interfejsie według `UI.md` | Sonnet high | scalone do master specyfikacji (`2bc7a45`) |
| T23-kopia | 2 | „Kopia wdrożeniowa” → „kopia gałęzi” wszędzie (interfejs, kontrakt agenta, strażnik, dokumenty dashboardu, skille i `CLAUDE.md` gry); nieaktualne przypomnienie o etapach i PT0 w oknie startu przebiegu | Sonnet high | czeka na R3 |
| T23-r4 | 3 | R4: dwa wdrożenia albo poprawki naraz, na rozłącznych plikach | Sonnet high | czeka na R3 i T23-kopia |

## Co zostało zrobione

## Decyzje i założenia
- Pytania z „Czytelności nazw” (Roland, czat 2026-10-27: „Ta, skrócić. 2 zostawic 3 poprawic”): „kopia wdrożeniowa” skracamy do „kopia gałęzi” wszędzie; „Wysiłek (effort)” w oknie startu zostaje; przypomnienie „Etapy 4–9 ruszają dopiero na hasło Rolanda; PT0…” w oknie startu poprawiamy na aktualne.
- Kolejność R3 → zmiana nazwy → R4, bo zmiana nazwy i R4 dotykają kontraktu i strażnika, nad którymi pracuje R3.

## Czego potrzebuję od Ciebie

## Test

## Podsumowanie
