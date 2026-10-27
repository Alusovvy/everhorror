# Factcheck test 16: Żyły w Starej sztolni i licznik żył

> Zadanie: [task_16](../../ai-tasks/task_16.md) · Przygotowano: 2026-10-27 · Gałąź: `spec/2026-10-27-task16`
> Kolumny „wynik” i „uwagi” wypełnia człowiek; agent niczego w nich nie wpisuje, a puste pole znaczy „nie sprawdzono”. Znaczniki wyniku: ✅ ok, ❌ błąd, 💬 propozycja, ⏭ pominięte, potem krótki opis.
> Wyniki człowieka: Roland (dashboard), 2026-10-27 14:14
> Zamknięcie: Roland (dashboard), 2026-10-27 14:14

## Co zostało dodane
- Stara sztolnia ma teraz dokładnie dwie żyły (ZYL-1) i obie da się zaznaczyć (ZYL-2). Wcześniej w jaskini świeciło sześć skał, a zaznaczyć dało się tylko dwie; jedna z pozostałych nazywała się „Żyła błękitnego żelaza” i miała tylko opis.
- Cztery skały bez żyły (dwa filary na środku, dwie skały przy ścianach) są zwykłym kamieniem, bez błękitnego pulsu. Opis „Przez skałę biegną cienkie żyłki…” zniknął razem z fałszywą żyłą.
- Błękitne światła stoją przy dwóch prawdziwych żyłach, trzecie, między filarami, zostało dla nastroju.
- Licznik (ZYL-4): w kodzie po pierwszej żyle wychodzi 1 z 12 (komunikat, mapa, ekwipunek, notes, podsumowanie). Zgłoszone „0 po pierwszej żyle” najpewniej wynikało z próby zaznaczenia fałszywej żyły; sprawdź to w grze.

## Test

Zacznij nową grę (albo dzień 1 po rozmowie z Raciborem), idź na wschód do Starej sztolni.

| # | co sprawdzić | jak | oczekiwany wynik | wynik | uwagi |
|---|---|---|---|---|---|
| 1 | W jaskini świecą dokładnie dwie skały | wejdź do jaskini za korytarzem i rozejrzyj się | dwie skały pulsują błękitem (ściana wschodnia i południowo-zachodni róg), pozostałe skały i filary są szare | ✅ |  |
| 2 | Pierwszą żyłę da się zaznaczyć | podejdź do skały na ścianie wschodniej, [E] „Zaznacz żyłę na mapie · 1 h” | mija godzina, obok skały stoi palik, pojawia się komunikat | ✅ |  |
| 3 | Licznik po pierwszej żyle | po pkt 2 przeczytaj komunikat | komunikat mówi „Żyły błękitu: 1 z 12”, nie 0 | ✅ |  |
| 4 | Licznik w innych miejscach | otwórz mapę [M], ekwipunek [I], notes [J] (zadanie „Złoża dla Kniazia”) | wszędzie 1 z 12; przy Starej sztolni na mapie „żyły: 1 z 2 zaznaczone” | ✅ |  |
| 5 | Drugą żyłę da się zaznaczyć | podejdź do skały w południowo-zachodnim rogu jaskini, [E] | jak w pkt 2; licznik 2 z 12; na mapie „2 z 2 zaznaczone” | ✅ |  |
| 6 | Zwykłe skały nie udają żył | podejdź do filarów na środku i skał przy północnej oraz wschodniej ścianie (bliżej wejścia) | nie świecą, [E] nic nie proponuje | ✅ |  |
| 7 | Podsumowanie wyprawy | wróć do obozu | w podsumowaniu „Nowe żyły na mapie: 2” (albo tyle, ile zaznaczono) | ✅ |  |
| 8 | Klimat jaskini | oceń oświetlenie po zmianie | jaskinia nadal wygląda niepokojąco i jest dość jasna, by się poruszać | ✅ |  |

## Wyniki automatu (agent)
Testy uruchomione przez agenta w kopii wdrożeniowej, na gałęzi `spec/2026-10-27-task16`. To nie jest weryfikacja człowieka.

| Test | Polecenie | Wynik | Raport |
|---|---|---|---|
| unit | `tools/run_tests.sh unit` | ALL PASSED | `reports/tests/unit.log` |
| lint | `tools/run_tests.sh lint` | ALL PASSED | `reports/tests/lint.log` |
| dialogue | `tools/run_tests.sh dialogue` | ALL PASSED | `reports/tests/dialogue.log` |
| expedition | `tools/run_tests.sh expedition` | ALL PASSED (w tym nowy krok task_16: dwie świecące skały, dwa `VeinMark_*`, `east_1` → „1 z 12”, mapa „1 z 2”) | `reports/tests/expedition.log` |
| day1 | `tools/run_tests.sh day1` | ALL PASSED | `reports/tests/day1.log` |

Nie zagrano w grze: wygląd jaskini (pkt 1, 6, 8) i „0” z zgłoszenia ocenia człowiek.

## Uwagi ogólne (wypełnia człowiek)

<!-- odpowiedź człowieka -->
-
<!-- /odpowiedź człowieka -->
