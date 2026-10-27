# task_20: Pomiar przed etapami 5–7: tor bohatera w bocie, czas realny dnia, test „złoty tydzień”

<!--
Zadanie narzędziowe z czatu Rolanda 2026-10-27; wymagania to jego słowa, nie edytować.
-->

Wymagania:
„Wprowadz propozycje Fable, nastepnie odswiez dokumentacje.” (Roland, czat 2026-10-27)
Propozycje: G4, G5, K5 z analizy projektu (kontekst poniżej).

Rodzaj: narzędzia · Zleca: Roland (czat, 2026-10-27)

Kontekst:
Źródło: przegląd projektu `docs/analizy/propozycje-projekt.md` (agent Fable 5.1, tylko odczyt, 2026-10-27). Ten plik zostaje usunięty po przeniesieniu propozycji do planu i zadań, więc cała treść potrzebna wykonawcy jest tutaj. Numery linii pochodzą z 2026-10-27 i mogą się przesunąć; trzeba je sprawdzić w kodzie. Wszystkie trzy pozycje to **narzędzia pomiaru bez zmiany rozgrywki**: nie zmieniają żadnej liczby balansu, kwestii ani sceny, więc nie wymagają reguły ⬜ w specyfikacji (zadanie narzędziowe, jak task_14 w części bota i raportu). Plan końcowy pozwala budować narzędzia pomiaru przed bramką PT0 (`docs/analizy/final-plan-human-readable.md`, etap 3). Etap planu: 4 (pomiar przed etapami 5–7). Koszt razem: S–M.

1. **G4. Bot balansu mierzy tor bohatera (poczytalność i zdrowie).**
   - *Problem.* Poczytalność bohatera startuje z 80 (`script/game_state.gd:38`), a pasmo „na krawędzi” zaczyna się poniżej 35 (`game_state.gd:638–645`). Noc kosztuje −3 (`script/story_director.gd:472`), gorączka −3 (`:477`), groza miejsc to łącznie 26 przy odwiedzeniu wszystkich (`07_balans.md:52` w specyfikacji), a ognisko oddaje +3…+6 co wieczór (`dialogue/ognisko.dialogue:38,55,75,92`). Żeby zejść poniżej 35, trzeba celowo zbierać każdą karę. Skutek: szepty (`story_director.gd:602–605`, tylko pasmo „na krawędzi” i tylko w tunelach) oraz winieta (`script/hud.gd:132–135`) to w praktyce martwy kod, więc jedyny element horroru poza tekstem nigdy nie startuje. Zdrowie podobnie: dwa źródła ran (−10 i −15), noc leczy +8, a śmierć wymaga wcześniejszej rany. Plan to wie (§8.1, D3 „najpierw pomiar”), ale bot (`tools/balance_sim.gd`) liczy tylko tempo żył i nie mierzy ani poczytalności, ani zdrowia bohatera (`07_balans.md:170` w specyfikacji, lista „Pominięte”).
   - *Propozycja.* Rozszerzyć bota o tor bohatera: groza odwiedzonych miejsc, noce, powrót po nocy, ognisko, przedmioty z trasy. Bot wypisuje linię w formacie istniejących `BALANCE[…]`, np. „BALANCE[styl, wariant]: poczytalność min. X w dniu D, pasmo …; zdrowie min. Y”. Dopiero z tą liczbą etap 6 stroi start i cenę nocy w `07_balans.md` (to zmiany istniejących liczb, nie nowe liczniki). Bot nadal **mierzy**: nie ma nowego progu, który psułby test (poza niezmiennikami, np. wartości w 0–100).
   - *Koszt:* S–M. *Priorytet analizy:* wysoki. *Etap:* 4, wyniki zasilają etap 6.

2. **G5. Raport przebiegu zapisuje czas realny dnia.**
   - *Problem.* Raport (`script/run_report.gd`, `GameState.time_log`) liczy minuty w grze, nie na zegarze ściennym. Ankieta sesji PT0 mówi „<1h” bez liczby dni; badanie z planu daje demu 15–60 min do punktu kulminacyjnego (`final-plan-human-readable.md:283`); `tools/release/CZYTAJ_MNIE.txt:43` obiecuje „1–3 godziny” na tydzień, ale to szacunek (`docs/human-tasks/playtest_template.md:8`). Cięcie dema (dni 1–3, D-13) będzie się odbywać bez wiedzy, ile to minut.
   - *Propozycja.* `GameState.record_dawn()` zapisuje `Time.get_ticks_msec()` i czas systemowy w nowym polu wpisu `dawn_log`; raport (Markdown i JSON) dodaje kolumnę „czas realny dnia” i sumę. To dane deweloperskie w pliku raportu, nie zegar w grze, więc zasada „bez zegara czasu rzeczywistego w grze” jej nie dotyczy, a gracz niczego nie widzi. Pole jest opcjonalne: wersja zapisu `SAVE_VERSION` (6) bez zmian, stary zapis i stary raport nadal się wczytują (kolumna pokazuje „brak danych”). Jedna linia w `dawn_log`.
   - *Koszt:* S. *Priorytet analizy:* wysoki. *Etap:* 4.

3. **K5. Test „złoty tydzień” teraz, przed etapami 5–7.**
   - *Problem.* Plan przewiduje test „złoty tydzień” dopiero w etapie 7, krok 1 (`final-plan-human-readable.md:232–234`), jako zabezpieczenie przepisania nocy na dane. Ale etap 5 (światło, dźwięk) i etap 6 (cena nocy, pokusa żył, norma etapami) też dotykają `_resolve_night()` i `_morning_events()`. Dziś `tools/tests/test_week.gd` sprawdza wybrane noce, nie całość, więc każda zmiana może po cichu przestawić losy ludzi.
   - *Propozycja.* Nowy scenariusz `golden_week` (`tools/tests/test_golden_week.gd`, dopisany do `tools/run_tests.sh` i do tabeli w `tools/README.md`): deterministyczne wejście (ziarno losowości, lista akcji dnia w stylu bota), siedem nocy przez `_resolve_night()` na gołym `StoryDirector` (jak `_task14_arrival` w `unit_test.gd`), a wynik (poczytalność, zdrowie, status i flagi każdej postaci po każdej nocy) porównany z plikiem `tools/tests/golden/week.json`. Zmiana zamierzona to świadome odświeżenie pliku złotego w tym samym commicie; różnica niezamierzona kończy test czerwono z listą rozbieżności (postać, noc, pole, było → jest).
   - *Koszt:* S–M. *Priorytet analizy:* wysoki. *Etap:* 4 (przeniesione z 7).

Kryteria akceptacji:
- `tools/run_tests.sh balance` wypisuje dla każdego stylu i wariantu linię z minimalną poczytalnością i dniem jej wystąpienia, pasmem oraz minimalnym zdrowiem; wynik jest powtarzalny między uruchomieniami. Żadna liczba balansu w grze się nie zmienia, a test balansu nadal tylko mierzy tempo.
- Raport przebiegu (`.md` i `.json`) ma kolumnę i sumę czasu realnego; `unit` sprawdza to na świeżym przebiegu oraz na starym zapisie (brak danych, bez błędu). `SAVE_VERSION` bez zmian.
- `tools/run_tests.sh golden_week` przechodzi dwa razy z rzędu na tym samym kodzie; umyślna zmiana jednej liczby nocy (próba robocza, cofnięta) daje czerwony wynik z czytelną listą rozbieżności. Plik `tools/tests/golden/week.json` jest w repozytorium, a sposób jego odświeżenia opisany w `tools/README.md`.
- Pole czasu realnego nie wchodzi do pliku złotego (inaczej test nigdy by nie był stały).
- Krótkie testy przechodzą: `unit lint dialogue balance golden_week`. Pełny zestaw tylko za zgodą Rolanda.
- `tools/README.md` opisuje nowe wyjście bota, kolumnę raportu i scenariusz `golden_week`; `docs/agent/README.md` (sekcja „Run report”) wspomina o czasie realnym.

Poza zakresem:
- Strojenie liczb (start poczytalności, cena nocy, norma): to etap 6, po pomiarze.
- Naprawa połkniętego załamania bohatera w nocy (K3), plansza z wieloma nowinami (G3), nowe podpowiedzi sterowania (G2).
- Powtórzenie sesji PT0 (G1/PT0b) i zmiany w szablonie sesji (osobne zadanie narzędziowe, P3).
- Jakakolwiek zmiana widoczna dla gracza; zegar czasu rzeczywistego w interfejsie gry.
- Zmiana `07_balans.md` w specyfikacji (lista „Pominięte” zaktualizuje się osobnym wpisem po wdrożeniu).

Priorytet: wysoki · Etap planu: 4 · Kolejność: najlepiej przed etapami 5–7; niezależne od task_16–19

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Co zostało zrobione
<!-- Osobna podsekcja dla każdego punktu z Wymagań. -->

## Decyzje i założenia
<!-- Co agent przyjął sam, bo nie wynikało z wymagań. -->

## Czego potrzebuję od Ciebie
<!-- Pytania, decyzje, pliki, dostęp, klucze API. -->

## Test
<!-- Jeśli zadanie zawiera implementację: link do docs/human-tasks/factcheck-test-XX.md -->

## Podsumowanie
