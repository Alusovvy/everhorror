<!--
Szablon arkusza buildu (D-36): jeden arkusz dla człowieka na build, z częścią na każde zadanie poziomu `rozgrywka`. Zasady: INFO.md w tym folderze.
Agent kopiuje go jako docs/human-tasks/factcheck-build-<sha7>.md w GŁÓWNEJ kopii gry, nigdy na gałęzi spec/*; <sha7> to pierwsze 7 znaków commita głowy gałęzi po commitach wdrożenia (`git -C <kopia gałęzi> rev-parse --short=7 HEAD`). Arkusz zatwierdza dashboard.
Gdy w docs/human-tasks/ leży już otwarty arkusz, którego człowiek jeszcze nie zaczął wypełniać (żadnego wyniku, żadnej linii `Wyniki człowieka`, `Zwolnienie`, `Zamknięcie`), nie kopiuj szablonu: dopisz na KOŃCU tamtego arkusza kolejną część `## Część: task_NN — <tytuł>` (podsekcje „Co zostało dodane”, „Test”, „Wyniki automatu (agent)” poziomu `###`) i dopisz zadanie do linii `> Zadania:`. Nigdy nie wstawiaj części w środek pliku ani nie ruszaj istniejących wierszy.
Zadania poziomów `tekst` i `narzędzia` nie mają arkusza i nie dostają tu części.
Linii `> Build:` nie wpisujesz: dodaje ją serwer przy zapisie wpisów człowieka (zagrany build); agent, który ją wpisze, narusza arkusz.
Sekcję „Raport przebiegu” zostaw tylko, gdy build zapisuje raport przebiegu (znacznik nad tabelą i dopisek „(człowiek)” w nagłówkach są obowiązkowe: bez nich formularz tabeli nie pokaże); w przeciwnym razie usuń ją z szablonu.
Zamień NN, <sha7> i RRRR-MM-DD i wypełnij tylko część opisową: „Co zostało dodane” oraz kolumny „co sprawdzić”, „jak” i „oczekiwany wynik”. W linii `> Zadania:` zamień „task_NN” na link do pliku zadania, jak w poprzednich arkuszach (zadanie z done/ leży o poziom niżej).
Kolumny „wynik” i „uwagi” oraz sekcję „Uwagi ogólne” wypełnia człowiek: zostaw je puste. Własne wyniki agenta idą do raportu zadania albo pod „Wyniki automatu (agent)”, z prawdziwymi nazwami, poleceniami i wynikami.
Usuń ten komentarz po wypełnieniu.
-->

# Build <sha7>: arkusz do ogrania

> Zadania: task_NN · Przygotowano: RRRR-MM-DD · Gałąź: `spec/RRRR-MM-DD-taskNN`
> Kolumny „wynik” i „uwagi” wypełnia człowiek; agent niczego w nich nie wpisuje, a puste pole znaczy „nie sprawdzono”. Znaczniki wyniku: ✅ ok, ❌ błąd, 💬 propozycja, ⏭ pominięte, potem krótki opis. Każda część poniżej to jedno zadanie z tego buildu; arkusz jest zamknięty, gdy zamknięte są wszystkie części.

## Raport przebiegu: dołącz plik
Po zakończeniu tygodnia kliknij w dashboardzie „Dołącz raport przebiegu”: para plików z folderu raportów gry trafia obok arkusza (`raporty/`), a linki do niej do tabeli. Jeśli raport nie powstał, zapisz to w uwagach.

<!-- człowiek -->
| Plik `.md` (człowiek) | Plik `.json` (człowiek) | Uwagi (człowiek) |
|---|---|---|
| | | |

## Uwagi ogólne (wypełnia człowiek)

<!-- odpowiedź człowieka -->
-
<!-- /odpowiedź człowieka -->

## Część: task_NN — <krótki tytuł zadania>

### Co zostało dodane
- <co się zmieniło, językiem gracza; ID reguł ze specyfikacji>

### Test

| # | co sprawdzić | jak | oczekiwany wynik | wynik | uwagi |
|---|---|---|---|---|---|
| 1 | <co sprawdzić> | <kroki w grze> | <co ma być widać> | | |
| 2 | <…> | <…> | <…> | | |

### Wyniki automatu (agent)
Testy uruchomione przez agenta, z prawdziwymi wynikami. To nie jest weryfikacja człowieka.

| Test | Polecenie | Wynik | Raport |
|---|---|---|---|
| <scenariusz> | `tools/run_tests.sh <scenariusz>` | <ALL PASSED albo opis błędu> | `reports/tests/<scenariusz>.log` |
