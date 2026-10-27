<!--
Szablon arkusza dla człowieka (factcheck). Zasady: INFO.md w tym folderze.
Agent kopiuje go jako docs/human-tasks/factcheck-test-NN.md (NN = numer zadania) w GŁÓWNEJ kopii gry, nigdy na gałęzi spec/*; arkusz zatwierdza dashboard. Gdy otwarty arkusz innego zadania nie jest jeszcze wypełniany, nie kopiuj szablonu: dopisz na końcu tamtego arkusza część `## Część: task_NN — <tytuł>` (podsekcje „Co zostało dodane”, „Test”, „Wyniki automatu (agent)” poziomu `###`) i dopisz zadanie do linii `> Zadania:` (reguły: INFO.md, „Arkusz kilku zadań”). Do całej sesji gry na buildzie służy playtest_template.md.
Sekcję „Raport przebiegu” (przed „Uwagami ogólnymi”) dodaj tylko, gdy build zapisuje raport przebiegu (znacznik nad tabelą i dopisek „(człowiek)” w nagłówkach są obowiązkowe: bez nich formularz tabeli nie pokaże); w przeciwnym razie usuń ją z szablonu.
Zamień NN i RRRR-MM-DD i wypełnij tylko część opisową: „Co zostało dodane” oraz kolumny „co sprawdzić”, „jak” i „oczekiwany wynik”. W nagłówku zamień „task_NN” na link do pliku zadania, jak w poprzednich arkuszach (zadanie z done/ leży o poziom niżej).
Kolumny „wynik” i „uwagi” oraz sekcję „Uwagi ogólne” wypełnia człowiek: zostaw je puste. Własne wyniki agenta idą do raportu zadania albo pod „Wyniki automatu (agent)”, z prawdziwymi nazwami, poleceniami i wynikami.
Usuń ten komentarz po wypełnieniu.
-->

# Factcheck test NN: <krótki tytuł zadania>

> Zadanie: task_NN · Przygotowano: RRRR-MM-DD · Gałąź: `spec/RRRR-MM-DD-taskNN`
> Kolumny „wynik” i „uwagi” wypełnia człowiek; agent niczego w nich nie wpisuje, a puste pole znaczy „nie sprawdzono”. Znaczniki wyniku: ✅ ok, ❌ błąd, 💬 propozycja, ⏭ pominięte, potem krótki opis.

## Co zostało dodane
- <co się zmieniło, językiem gracza; ID reguł ze specyfikacji>

## Test

| # | co sprawdzić | jak | oczekiwany wynik | wynik | uwagi |
|---|---|---|---|---|---|
| 1 | <co sprawdzić> | <kroki w grze> | <co ma być widać> | | |
| 2 | <…> | <…> | <…> | | |

## Wyniki automatu (agent)
Testy uruchomione przez agenta, z prawdziwymi wynikami. To nie jest weryfikacja człowieka.

| Test | Polecenie | Wynik | Raport |
|---|---|---|---|
| <scenariusz> | `tools/run_tests.sh <scenariusz>` | <ALL PASSED albo opis błędu> | `reports/tests/<scenariusz>.log` |

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
