# task_23: Dashboard — jeden pisarz buchalterii, dwa wdrożenia naraz i czytelniejsze polskie nazwy

<!--
Zadanie narzędziowe z czatu Rolanda 2026-10-27; wymagania to jego słowa, nie edytować.
-->

Wymagania:
Roland, czat 2026-10-27, odpowiedź na pytania koordynatora po task_19 (1: dostęp sesji terminalowych do `../everhorror-wt`, 2: R4 — dwa wdrożenia naraz, 3: R1 — reguła gałęzi `master` w GitHubie, 4: zgłoszenie „Czytelność nazw”): „Nie mają dostępu. 2. ok, 3. ok, 4 . ok”

Rodzaj: narzędzia · Zleca: Roland (czat, 2026-10-27)

Kontekst:
- R3 i R4 opisuje `specification/dashboard/ARCHITEKTURA.md` („Plan: jeden pisarz buchalterii”) oraz plan, [D-33](../../archiwum/plan-historia-2026-10.md#decyzje-z-task_23-d-33d-34). R4 bez R3 dawałby konflikty w `WDROZENIA.md`, więc najpierw R3.
- „Czytelność nazw”: `specification/zgloszenia/2026-10-27_czytelnosc-nazw.md` (wiersz 3 arkusza odbioru task_19, niski priorytet). Zasady i słowniczek: `specification/dashboard/UI.md`.
- R1 zrobione przez koordynatora: reguła GitHub `master — bez force push i usuwania (R1)` w repozytorium gry (id 25967090).
- Punkt 1: sesje terminalowe gry nie dostają dostępu do `../everhorror-wt` (`.claude/settings.json` bez zmian).

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Plan

| ID | Fala | Zakres | Model | Stan |
|---|---|---|---|---|
| R1 | — | Reguła gałęzi `master` gry w GitHubie: zakaz force push i usuwania | koordynator | zrobione |
| T23-r3 | 1 | R3: jeden pisarz buchalterii (`cli.ts ledger`, krótka blokada zapisu, dziennik, strażnik, skille) | Sonnet high | scalone do master specyfikacji (`94a1336`), skille gry zmienione |
| T23-nazwy | 1 | Czytelniejsze polskie nazwy w interfejsie według `UI.md` | Sonnet high | scalone do master specyfikacji (`2bc7a45`) |
| T23-kopia | 2 | „Kopia wdrożeniowa” → „kopia gałęzi” wszędzie (interfejs, kontrakt agenta, strażnik, dokumenty dashboardu, skille i `CLAUDE.md` gry); nieaktualne przypomnienie o etapach i PT0 w oknie startu przebiegu | Sonnet high | scalone (spec `6925179`, gra `db3fb68`) |
| T23-r4 | 3 | R4: do 3 analiz i do 3 wdrożeń albo poprawek naraz (rozłączne pliki), planowanie i domknięcie po jednym obok reszty, kolejka commitów w specyfikacji | Sonnet high | scalone (spec `c10bbda`, skille gry `db3b7a7`) |

## Co zostało zrobione
- **R1:** reguła GitHub „master — bez force push i usuwania (R1)” w repozytorium gry (aktywna; zwykłe pushe i scalenia działają).
- **R3, jeden pisarz buchalterii:** `WDROZENIA.md` zmienia tylko `node dashboard/cli.ts ledger <op>` (krótka blokada w katalogu git specyfikacji, dziennik operacji, audyt przypisuje zmiany przebiegowi); strażnik odrzuca ręczne edycje. Skille gry i `CLAUDE.md` mówią to samo (`9484ffe`).
- **Czytelniejsze nazwy:** 88 polskich komunikatów, lista w `dashboard/UI.md` §4; zgłoszenie „Czytelność nazw” z odpowiedzią.
- **„Kopia gałęzi”** zamiast „kopii wdrożeniowej” wszędzie (EN: „branch copy”) i aktualne przypomnienie w oknie startu przebiegu.
- **R4, przebiegi równolegle (D-33):** do 3 analiz albo przeglądów kodu i do 3 wdrożeń albo poprawek naraz; planowanie, domknięcie i próba po jednym; jeden przebieg na zadanie i na gałąź; nakładające się albo nieznane pliki wymagają potwierdzenia w oknie startu; commity w specyfikacji po kolei pod jedną blokadą (`cli.ts commit`, `ledger --message`); audyt rozróżnia przebiegi biegnące obok siebie; Przebiegi pokazują kilka aktywnych naraz. Limity zmienia `EVERHORROR_RUN_LIMITS` (np. `code=1` przywraca jedno wdrożenie naraz).

## Decyzje i założenia
- Pytania z „Czytelności nazw” (Roland, czat 2026-10-27: „Ta, skrócić. 2 zostawic 3 poprawic”): „kopia wdrożeniowa” skrócona do „kopia gałęzi”; „Wysiłek (effort)” zostaje; przypomnienie w oknie startu poprawione.
- Kolejność R3 → zmiana nazwy → R4, bo wszystkie dotykały kontraktu i strażnika.
- Przeglądy kodu dzielą 3 miejsca z analizami, próba ma własne miejsce (decyzja agenta, Roland może zmienić).
- R1 bez wymogu pull requestów: scalanie z dashboardu i commity procesowe idą z jednego konta.

## Czego potrzebuję od Ciebie
- Usunięcie bezczynnej starej kopii `everhorror-wdrozenie` i zdalnej gałęzi `agent/dashboard-ux` (już w master) zablokował klasyfikator uprawnień jako operacje niszczące; potrzebne wyraźne „tak” albo ręczne usunięcie.
- Wybór dalszych przyspieszeń z listy agenta R4 (rekomendacja: gotowy import Godota w nowej kopii, kolejka startów, wykrywanie konfliktów przez `git merge-tree`, powiadomienie na pulpicie).

## Test
Automat (izolowane foldery tymczasowe): `npm test` 2137/2137, `npm run e2e` 30/30 (jeden przebieg dał 29/30, dwa kolejne 30/30: niestabilny test, prawdopodobnie znana niestabilność testu blokady na Windows), build, lint 0. Prawdziwy agent nie był uruchamiany z nowym kontraktem: warto zacząć od „Sprawdź agenta” i jednego przebiegu analizy.

## Podsumowanie
Dashboard prowadzi teraz kilka przebiegów naraz (do 3 analiz i 3 wdrożeń) bez kolizji w księdze wdrożeń i w commitach specyfikacji, ma czytelniejsze polskie nazwy i jedną nazwę „kopia gałęzi”, a `master` gry jest chroniony przed force push i usunięciem. Zostają: niestabilny test e2e do namierzenia, wybór dalszych przyspieszeń oraz dwie usunięcia czekające na zgodę.
