# Decyzje do task 10: pierwsze spotkania w pomieszczeniach

> Zadanie: [task_10](../../ai-tasks/done/task_10.md) · Przygotowano: 2026-09-26
> **Status: rozstrzygnięte 2026-09-26.** Odpowiedzi w tabeli, wpisane do zadania.

**Kontekst:** pierwszego dnia w obozie są tylko Mirosław, Bolko, Tekla i Racibor. Pozostałą piątkę (Wszebor, Nasir, Hagiwara, Sobek, brat Anzelm) gracz spotyka losowo w pomieszczeniach, najwyżej dwie osoby w jednym.

## Decyzje

| # | Pytanie | Opcje | Rekomendacja | Twój wybór |
|---|---|---|---|---|
| 1 | **Co to jest „pierwsze piętro” i jego „pomieszczenia”?** | **A.** Miejsca wypraw o głębokości 1: **Stara sztolnia, Rząpie, Zawalony chodnik** (ten dopiero po wysadzeniu zawału). Dojście kosztuje czas jak zwykła wyprawa (2 h). Pasuje do dnia 1: gracz i tak idzie do sztolni po lonty, do rząpia po tobołek i na zachód po wybuchu. **B.** Nowe małe pomieszczenia przy samym obozie, do przejścia na nogach i za darmo: stare wejście z pierwszymi rekwizytami, boczne komory przy korytarzach, zachodni chodnik przed zawałem. Trzeba je zbudować w generatorze obozu. **C.** Pomieszczenia w miejscach głębokości 1 **i 2** (sztolnia, rząpie, wyrobisko, pompy, kuźnia, kaplica…) | **A**: bez nowego budowania, a spotkania wplatają się w zadania dnia 1 |A |
| 2 | **Pojemność w dniu 1** (przy A: otwarte są tylko sztolnia i rząpie, czyli 2 × 2 = 4 miejsca na 5 osób) | **a)** Losujemy też Zawalony chodnik. Kto tam trafi, czeka, aż gracz wysadzi zawał, a jeśli nie zdąży w dniu 1, spotyka go w obozie w dniu 2. **b)** Każde miejsce głębokości 1 ma 2 pomieszczenia (np. w sztolni korytarz i jaskinia z żyłami), czyli 6 pomieszczeń po najwyżej 2 osoby. **c)** Jedna osoba z piątki (wskaż kto) zostaje w obozie od dnia 1 | **a)**: najprostsze, a zawał ma kolejny powód, żeby go wysadzić |A |
| 3 | **Co z osobą, której gracz nie spotkał w dniu 1?** | **a)** Od rana w dniu 2 jest w obozie według zwykłego rozkładu, a pierwsza rozmowa ma wtedy powitanie „obozowe”. Wieczorem w dniu 1 jej nie ma („została na nocnej szychcie”). **b)** Czeka w swoim pomieszczeniu, aż gracz ją znajdzie, nawet przez cały tydzień. Zadania tej osoby (gorączka Nasira, zakład Sobka, leczenie u Anzelma) do tego czasu są zablokowane | **a)**: spotkania są wyzwaniem dnia 1, a wątki z dalszych dni się nie psują |A |
| 4 | **Czy losowanie jest czysto losowe?** | **a)** Czysto losowe (z ograniczeniem do 2 w pomieszczeniu). **b)** Losowe z sensem: każdy ma 1–2 pasujące miejsca (Nasir przy wodzie w rząpiu, Wszebor przy skale w sztolni, Anzelm tam, gdzie ktoś się zranił…), a los wybiera spośród nich | **b)**: dalej jest losowo, ale powitania mogą mówić, co ta osoba tam robi |A |

## Czego nie trzeba decydować (zrobię tak)
- **Losowanie** odbywa się raz, na starcie nowej gry. Ziarno jest zapisywane w stanie gry, więc wczytanie gry nie przestawia ludzi.
- **Po rozmowie** postać zostaje w pomieszczeniu do końca wizyty.
- **Dobrawa i Sabina** bez zmian (dzień 2 i Exitium).
- **Pierwsze powitania w terenie** robię w tym zadaniu w minimalnej wersji. Pełny przegląd tekstów pierwszego spotkania to [task_11](../../ai-tasks/done/task_11.md).
