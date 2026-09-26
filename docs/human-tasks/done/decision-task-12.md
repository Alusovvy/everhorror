# Decyzje do task 12: zmęczenie i powrót za pół drogi

> Zadanie: [task_12](../../ai-tasks/done/task_12.md) · Przygotowano: 2026-09-26
> **Status: rozstrzygnięte 2026-09-26.** Odpowiedzi w tabeli, wpisane do zadania.
> Wszystkie liczby trafią do `07_balans.md` i łatwo je potem zmienić. Tu chodzi o zasadę.

## Decyzje

| # | Pytanie | Opcje | Rekomendacja | Twój wybór |
|---|---|---|---|---|
| 1 | **Co podnosi zmęczenie?** | **a)** Każda godzina w tunelach (droga, rozpoznanie, praca na miejscu) **+8%**, a każda godzina w obozie **+2%**. Po ok. 12 h w tunelach bohater ma 100%. **b)** Tylko godziny drogi, **+12,5%** za godzinę (8 h marszu to 100%). **c)** Każda godzina bez względu na miejsce, **+6%** (100% pod koniec długiego dnia) | **a)**: męczą głównie tunele, a dzień w obozie przy rozmowach męczy mało |A |
| 2 | **Co obniża zmęczenie?** | **a)** Sen **−60%**, więc zmęczenie narasta z dnia na dzień, jeśli gracz co dzień chodzi daleko. Wieczór przy ognisku **−15%**. **b)** Sen zeruje zmęczenie, więc to presja tylko w obrębie jednego dnia. **c)** Jak a), ale z nową akcją „Zdrzemnij się” na posłaniu w dzień: 2 h, −30% | **a)**: „narasta” działa w skali tygodnia, a ognisko dostaje drugi sens |A |
| 3 | **Czy coś dzieje się poniżej 100%?** | **a)** Nic poza ostrzeżeniem słowami (75%: „zmęczony”, 90%: „ledwo idziesz”). Dopiero 100% podwaja drogę. **b)** Stopniowo: od 50% droga +25%, od 75% +50%, przy 100% ×2 | **a)**: dokładnie jak w wymaganiu, a gracz ma czas zareagować |A |
| 4 | **Co dokładnie się podwaja przy 100%?** | **a)** Tylko czas marszu po odcinkach mapy. Rozpoznanie (+1 h) i dodatek za ranę (+1 h na odcinek) doliczamy po podwojeniu. **b)** Cały koszt dojścia razem z rozpoznaniem i raną | **a)**: „koszt podróży” to marsz, a pozostałe koszty mają własne powody | A|
| 5 | **Jak gracz widzi zmęczenie?** | **a)** Słowami, jak zdrowie i poczytalność (NPC-13: bez liczb): stan w plecaku [I], linijka stanu na HUD od 75%, a na mapie przy koszcie „· zmęczenie ×2”. **b)** Procentem albo paskiem (w plecaku i w notesie) | **a)**: spójne z resztą stanu bohatera. Jeśli „100%” w wymaganiu miało być widoczne dla gracza, wybierz b) | A|
| 6 | **Czy zmęczenie wpływa na coś jeszcze?** | **a)** Nie, tylko na czas drogi. **b)** Przy 100% dodatkowo −poczytalność przy każdym odcinku („ciemność zaczyna mówić”) | **a)**: jedna czytelna konsekwencja. Resztę można dodać po testach |A |

## Powrót do obozu: jak rozumiem wymaganie (potwierdź albo popraw)
- **Powrót kosztuje 50% czasu drogi, którą bohater faktycznie przeszedł od wyjścia z obozu do tego miejsca.**
  - Sumuję odcinki z wyprawy, także te podwojone zmęczeniem i wydłużone raną.
  - Nie liczę rozpoznania ani czasu spędzonego na miejscu (żyły, rozmowy, akcje).
  - Wynik zaokrąglam w górę do 5 minut.
- Przykład: obóz → sztolnia (2 h) → wyrobisko (1 h) → grota (1,5 h) = 4,5 h dojścia, więc powrót trwa **2 h 15 min** (dziś 4,5 h).
- Kiedy bohater kluczy (sztolnia → kaplica → z powrotem do sztolni → wyrobisko), każdy odcinek się liczy, więc powrót jest dłuższy niż połowa najkrótszej drogi.
- **Powrót nigdy nie jest podwajany**, nawet przy 100% zmęczenia.

Jeśli miało to znaczyć „połowa najkrótszej drogi z obozu do tego miejsca”, napisz. To prostsza wersja, ale kluczenie przestaje kosztować.

## Czego nie trzeba decydować (zrobię tak)
- Zmęczenie jest w zapisie gry. Starsze zapisy zaczynają od 0.
- Mapa i godzina przybycia na mapie zawsze pokazują koszt z uwzględnieniem zmęczenia, więc to, co widać, zgadza się z tym, co się stanie.
- Wpływ na balans tygodnia sprawdzę scenariuszem i opiszę w `07_balans.md`, zanim oddam zadanie.
