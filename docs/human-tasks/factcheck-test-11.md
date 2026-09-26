# Factcheck test 11: pierwsze spotkania, darmowe powtórzone opcje

> Zadanie: [task_11](../ai-tasks/done/task_11.md) · Decyzje: [decision-task-11](done/decision-task-11.md) · Przygotowano: 2026-09-26 · Czas: ~15 min
> Graj z edytora (F5). Można przejść razem z [factcheck-test-10](factcheck-test-10.md) i [factcheck-test-12](factcheck-test-12.md): nowa gra, dzień 1 i 2.

## Co się zmieniło
- **Zdanie o pomieszczeniu:** każdy z piątki (Wszebor, Nasir, Hagiwara, Sobek, Anzelm) przy pierwszym spotkaniu na szychcie w dniu 1 mówi jedno zdanie o miejscu, w którym stoi: o sztolni, o rząpiu albo o przejściu za zawał [ROBOCZE].
- **Powtórzona opcja jest darmowa** (Twoja uwaga z factchecku 10): opcja wybrana już raz u tej samej osoby nic nie kosztuje. Gra pamięta to w zapisie.
- **Test automatyczny** pilnuje, żeby każde miejsce z rozkładu dnia miało pasujące powitanie.
- **Wzmianki o ludziach, których jeszcze nie znasz:** przejrzane. Mogą padać, ale opisowo, a opcje „Co myślisz o X?” pojawiają się dopiero po poznaniu X. Nic nie trzeba było zmieniać.

## Testy

| # | Co sprawdzić | Jak | Oczekiwany wynik | Wynik | Uwagi |
|---|---|---|---|---|---|
| 1 | Sztolnia | Dzień 1, Stara sztolnia, porozmawiaj z kimś z piątki | Po przedstawieniu się jedno zdanie o sztolni (stemple, sucho, nacięcia, mech…) | | |
| 2 | Rząpie | Dzień 1, rząpie | Zdanie o wodzie („Woda gada”, „Nie lubię wody, której dna nie widać”…) | | |
| 3 | Za zawałem | Dzień 1, po wybuchu, Zawalony chodnik (jeśli ktoś tam jest) | Narracja o szparze pod stropem i zdanie o przejściu albo o powietrzu za zawałem | | |
| 4 | Brzmienie | Przeczytaj wszystkie spotkane | Zdania pasują do postaci i miejsca, nic nie brzmi dziwnie | | |
| 5 | Powtórzona opcja | Dzień 2: Nasir → „Wiesz coś o pompach…”, wyjdź, zagadaj znowu i wybierz to samo | Za pierwszym razem −5 min, za drugim zegar stoi | | |
| 6 | Inna osoba, ta sama opcja | Zapytaj o to samo kogoś innego (jeśli ma taką opcję) | Kosztuje 5 min, bo to inna osoba | | |
| 7 | Zapis | Zapisz, wczytaj, wybierz znowu tę samą opcję | Dalej darmowa | | |
| 8 | Akcje z ceną | Kości z Sobkiem (1 h) dwa dni z rzędu | Za każdym razem 1 h (akcje kosztują swoje, darmowe jest tylko 5 minut za rozmowę) | | |
