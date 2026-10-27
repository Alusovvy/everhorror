<!--
Szablon sesji gry (playtestu) dla człowieka. Zasady: INFO.md w tym folderze.
Agent kopiuje go jako docs/human-tasks/factcheck-test-NN.md (NN = numer zadania, którego build oceniamy) w GŁÓWNEJ kopii gry, nigdy na gałęzi spec/*; arkusz zatwierdza dashboard. Do zwykłego sprawdzenia zadania służy factcheck_template.md.
Zamień NN, RRRR-MM-DD, <numer> (kolejna sesja: PT0, PT1, …) i <wersja>. Wypełnij tylko części opisowe: „Co nowego”, „Jak zdobyć build” oraz kolumny „co sprawdzić”, „jak” i „oczekiwany wynik”. W nagłówku zamień „task_NN” na link do pliku zadania, jak w poprzednich arkuszach.
Wszystko, co wypełnia człowiek, zostaw puste: kolumny „wynik” i „uwagi”, tabelę „Dane sesji” (nad nią stoi znacznik „człowiek” w komentarzu HTML), tabele skal, tabelę dni i odpowiedź między znacznikami odpowiedzi człowieka.
Do 15 wierszy w „Sprawdzeniach”, tylko to, co ocenia człowiek: odczucie, czytelność, ton, obraz. Mechanikę pilnują testy automatyczne; ich wyniki idą do raportu zadania albo pod „Wyniki automatu (agent)”, nigdy do kolumn człowieka. Pięć pytań ankiety i jedno otwarte zostają bez zmian, żeby sesje dało się porównywać.
Gdy otwarty arkusz innego zadania nie jest jeszcze wypełniany, nie kopiuj szablonu: dopisz na końcu tamtego arkusza część `## Część: task_NN — <tytuł>` i dopisz zadanie do linii `> Zadania:` (reguły: INFO.md, „Arkusz kilku zadań”).
Sekcję „Raport przebiegu” (na końcu) dodaj tylko, gdy build zapisuje raport przebiegu (znacznik nad tabelą i dopisek „(człowiek)” w nagłówkach są obowiązkowe: bez nich formularz tabeli nie pokaże); w przeciwnym razie usuń ją z szablonu (wzór: PT0, factcheck-test-14.md).
Czas sesji podajemy jedną liczbą („1–3 h”), tą samą co w CZYTAJ_MNIE.txt, do czasu PT0, który pokaże rzeczywisty.
Minimum ważności sesji (zasada w INFO.md): sesja liczy się do celów K tylko z wypełnionym „Dotarcie do” i dołączonym raportem przebiegu. Wiersze dni powyżej „Dotarcie do” zostają puste (dashboard wpisze ⏭ przy zamknięciu).
Usuń ten komentarz po wypełnieniu.
-->

# PT<numer>: sesja gry na buildzie <wersja>

> Zadanie: task_NN · Przygotowano: RRRR-MM-DD · Czas: 1–3 h
> Kolumny „wynik” i „uwagi”, pola ankiety i odpowiedź otwartą wypełnia człowiek. Agent niczego tu nie wpisuje: puste pole znaczy „nie sprawdzono”.

## Co nowego w <wersja>
- <poprawki i funkcje widoczne dla gracza, z ID reguł ze specyfikacji>

## Jak zdobyć build
- <archiwum albo gałąź, jak uruchomić, gdzie odczytać napis z wersją>

## Dane sesji (wypełnia człowiek)

Napis z menu głównego skopiuj w całości, tak jak stoi w prawym dolnym rogu (wersja i skrót specyfikacji). „Dotarcie do” jest obowiązkowe: bez niego sesja nie liczy się do celów.

<!-- człowiek -->
| Data sesji | Napis z menu głównego | Łączny czas gry | Dotarcie do (dzień albo zakończenie) |
|---|---|---|---|
| | | | |

## Jak grać
Zacznij nową grę (START) i graj normalnie, najlepiej cały tydzień (dni 1–7). Nie trzeba szukać błędów na siłę: ważne, co czuć, co jest jasne, a co nie. Wiersze poniżej idą mniej więcej w kolejności, w jakiej się na nie trafia, więc nie trzeba ich robić osobno. Wieczorem każdego dnia, tuż przed snem, wpisz liczbę do tabeli „Dziś zabrakło mi czasu” (niżej, pytanie 3). Dni, do których nie dotarło się w grze, zostaw puste: przy zamknięciu arkusza dashboard oznaczy je jako pominięte. Na koniec dołącz raport przebiegu; sesja bez raportu albo bez „Dotarcie do” jest tylko wskazówką kierunku, nie pomiarem.

## Sprawdzenia (tylko to, co ocenia człowiek)

| # | co sprawdzić | jak | oczekiwany wynik | wynik | uwagi |
|---|---|---|---|---|---|
| 1 | <odczucie, czytelność, ton albo obraz do oceny> | <kroki w grze> | <jak wygląda dobry wynik> | | |
| 2 | <…> | <…> | <…> | | |
| 3 | <…> | <…> | <…> | | |

## Ankieta (skala 1–7)
Pytania 1, 2, 4 i 5 wypełnij raz, po zakończeniu gry (albo po ostatnim dniu, do którego udało się dotrzeć). Pytanie 3 wypełniaj po każdym dniu. Jedna liczba w polu, uwagi są dowolne. Przy jednym testerze ankieta pokazuje tylko kierunek, nie dowód.

| # | pytanie | skala | wynik | uwagi |
|---|---|---|---|---|
| 1 | Napięcie w tunelach | 1 = brak napięcia, 7 = bardzo silne | | |
| 2 | Rozumiem, co kosztuje czas | 1 = zupełnie nie, 7 = w pełni | | |

**3. „Dziś zabrakło mi czasu”.** Wpisz liczbę wieczorem, tuż przed snem, po każdym dniu gry. 1 = czasu było aż nadto, 7 = zabrakło wyraźnie. W uwagach można zapisać, co zjadło czas.

| Dzień | wynik (1–7) | uwagi |
|---|---|---|
| 1 | | |
| 2 | | |
| 3 | | |
| 4 | | |
| 5 | | |
| 6 | | |
| 7 | | |

| # | pytanie | skala | wynik | uwagi |
|---|---|---|---|---|
| 4 | Przywiązanie do ludzi z obozu | 1 = obojętni, 7 = bardzo mi na nich zależy | | |
| 5 | Ciekawość „co niżej” | 1 = żadna, 7 = bardzo chcę wiedzieć | | |

## Gdzie było nudno albo trudno się połapać?

<!-- odpowiedź człowieka -->
-
<!-- /odpowiedź człowieka -->

## Raport przebiegu: dołącz plik
Po zakończeniu tygodnia kliknij w dashboardzie „Dołącz raport przebiegu”: para plików z folderu raportów gry trafia obok arkusza (`raporty/`), a linki do niej do tabeli. Jeśli raport nie powstał, zapisz to w uwagach.

<!-- człowiek -->
| Plik `.md` (człowiek) | Plik `.json` (człowiek) | Uwagi (człowiek) |
|---|---|---|
| | | |
