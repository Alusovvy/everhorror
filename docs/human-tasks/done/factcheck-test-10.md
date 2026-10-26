# Factcheck test 10: pierwszy dzień, ludzie na szychcie w pomieszczeniach

> **2026-10-26:** zastąpione arkuszem PT0 [factcheck-test-14.md](../factcheck-test-14.md) (decyzja planu końcowego, etap 3). Wpisy człowieka (wiersze 1–2 i uwaga „Reszta spoko”) zostają bez zmian; pozostałe kolumny człowieka są puste.

> Zadanie: [task_10](../../ai-tasks/done/task_10.md) · Decyzje: [decision-task-10](decision-task-10.md) · Przygotowano: 2026-09-26 · Czas: ~25 min
> Graj z edytora (F5). Build tylko na Twoją prośbę. Nowa gra; najszybciej: dzień 1, Stara sztolnia, Rząpie, wybuch u Mirosława i Zawalony chodnik, potem noc i ranek dnia 2.
> Rozstawienie jest losowe, więc przy każdej nowej grze ludzie mogą stać gdzie indziej. Zapisz w uwagach, kto gdzie był.

## Co się zmieniło
- **Dzień 1 w obozie:** są tylko Mirosław, Bolko, Tekla i Racibor. Wstęp mówi, że reszta ekipy jest na szychcie w chodnikach najbliżej obozu.
- **Wszebor, Nasir, Hagiwara, Sobek i brat Anzelm:**
  - w dniu 1 pracują w pomieszczeniach pierwszego poziomu: Stara sztolnia, Rząpie starego szybu, Zawalony chodnik,
  - najwyżej dwoje w jednym miejscu, losowo przy każdej nowej grze,
  - kto trafi za zawał, czeka, aż Mirosław go wysadzi.
- **Powitania w terenie** [ROBOCZE]: każdy z piątki mówi, co robi na szychcie i że wraca do obozu jutro. Kto jest za zawałem, pokazuje szparę pod stropem, którą tam wszedł.
- **Wieczór dnia 1:** piątki nie ma w obozie. Przy ognisku: „Połowa ekipy została na nocnej szychcie…”.
- **Dzień 2:** od rana wszyscy są w obozie według zwykłego rozkładu. Kogo nie spotkałeś w dniu 1, poznajesz tam, z powitaniem obozowym.

## Testy

| # | Co sprawdzić | Jak | Oczekiwany wynik | Wynik | Uwagi |
|---|---|---|---|---|---|
| 1 | Wstęp | Nowa gra | Wstęp mówi, że w obozie zostali tylko zarządca, kwatermistrzyni i dwaj górnicy, a reszta jest na szychcie | Spoko | |
| 2 | Obóz w dniu 1 | Obejdź obóz rano i w dzień | Tylko Mirosław, Bolko, Tekla, Racibor. Nie ma Wszebora, Nasira, Hagiwary, Sobka ani Anzelma (Sobka nie ma też przy wschodnim wyjściu) | Spoko, ale ta sama opcja dialogowa typu "potrzebuje oleju do lamp" nie powinna juz zuzywac 5 minut.| |
| 3 | Stara sztolnia | Wyprawa do Starej sztolni | 0, 1 albo 2 osoby z piątki, przy robocie (górnicy i Anzelm klęczą, Hagiwara i Sobek stoją). Nikt nie stoi w ścianie ani w drugiej osobie | | |
| 4 | Rząpie | Wyprawa do rząpia | Jak wyżej. Razem ze sztolnią i zawałem widać całą piątkę | | |
| 5 | Powitanie na szychcie | Porozmawiaj z każdym spotkanym | Opis pasuje do tunelu (nie „przy stole”, nie „przy księdze”). Mówi, że wraca jutro. Sobek nie mówi „widziałem cię przy śniadaniu” | | |
| 6 | Po rozmowie | Porozmawiaj, potem rozejrzyj się | Postać zostaje na miejscu, nie znika | | |
| 7 | Za zawałem | Wysadź zawał (lonty dla Mirosława), idź do Zawalonego chodnika | Jeśli ktoś tam był: stoi w chodniku, a przy pierwszej rozmowie narracja mówi o szparze pod stropem | | |
| 8 | Wieczór dnia 1 | Wróć po 20:00, usiądź przy ognisku | Piątki nie ma w obozie. Przy ogniu: „Połowa ekipy została na nocnej szychcie…”. Wszebor nie śpiewa, Nasir i Sobek się nie odzywają | | |
| 9 | Ranek dnia 2 | Prześpij noc | Cała piątka jest w obozie na swoich miejscach (przy stole, Anzelm się modli) | | |
| 10 | Niespotkani w dniu 1 | Porozmawiaj w dniu 2 z kimś, kogo nie spotkałeś | Zwykłe powitanie obozowe (przy stole, przy modlitwie…), bez zdań o szychcie | | |
| 11 | Spotkani w dniu 1 | W dniu 2 porozmawiaj z kimś, kogo już znasz | Nie przedstawia się drugi raz | | |
| 12 | Losowość | Zacznij drugą nową grę | Ludzie stoją gdzie indziej (może się zdarzyć ten sam układ, ale rzadko). Nigdy trzech w jednym miejscu | | |
| 13 | Zapis i odczyt | W dniu 1 zapisz, wczytaj, idź do tego samego miejsca | Te same osoby w tym samym miejscu co przed zapisem | | |

Reszta spoko
## Odpowiedź agenta (2026-09-26)
- **Punkt 2, „ta sama opcja nie powinna już zużywać 5 minut”:** zrobione w ramach task_11. Opcję wybraną już raz u tej samej osoby (np. „Wiesz coś o pompach…”, „Jak tam mój kilof?”) gra zapamiętuje i każde kolejne wybranie jest darmowe. Zapamiętane opcje są w zapisie gry. Pierwsze wybranie dalej kosztuje 5 minut, a akcje z własnym kosztem (kości, pompy, wybuch) kosztują swoje jak dotąd. Specyfikacja: DIA-5.
- **Pozostałe punkty:** dziękuję. Jak ustaliliśmy, resztę sprawdzimy w większym teście po task_11 i task_12.
