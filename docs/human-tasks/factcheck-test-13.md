# Factcheck test 13: sny po odszyfrowaniu, kreski w noc 7, ryba bez pomp i bandaż dla Wszebora

Zadanie: [task_13](../ai-tasks/done/task_13.md) (ze specyfikacji `8d8c550`, zgłoszenie z wyrównania). Gałąź: `spec/2026-09-26-task13`.

## Co zostało dodane
- **Sen z listem dziadka** kończy sen pierwszej nocy po odszyfrowaniu — także po dniu 3–4, 5–6 i 7 (wcześniej tylko po nocach 1–2). Raz na grę.
- **Liczenie do czternastu** słychać też w ostatnim śnie (noc 7), zaraz po tym, jak dziadek pyta, czy policzyłeś.
- **Staw w Zalanym chodniku** jest pod wodą, dopóki pompy Nasira nie ruszą: Wszebor i Mirosław odmawiają łowienia i mówią dlaczego.
- **Bandaż dla Wszebora:** przy odmowie Wszebor proponuje, że za czysty bandaż (ma rozharataną rękę od kucia) wyciągnie rybę z rząpia. Oddajesz bandaż → rano odbierasz rybę („Jak tam ryba z rząpia?”). Dwa nowe wpisy w notesie.

## Test

| # | Co sprawdzić | Jak | Oczekiwany wynik | Wynik | Uwagi |
|---|---|---|---|---|---|
| 1 | List w śnie po późnym odszyfrowaniu | Zdobądź szyfr i klucz dopiero w dniu 3 lub później, idź spać | Sen kończy się kartką dziadka z odszyfrowanymi zdaniami „twoim pismem” | | |
| 2 | List tylko raz | Śpij kolejną noc | Kartka się nie powtarza | | |
| 3 | Kreski w noc 7 | „Czternaście kresek” aktywne (np. kreski w rząpiu), prześpij noc po dniu 7 | Dziadek pyta, czy policzyłeś, potem ktoś liczy do czternastu | | |
| 4 | Łowienie przed pompami — Mirosław | Zadanie „Ryba dla Hrapka” aktywne, pompy stoją: „Chodź ze mną na ryby do stawu. (4 h)” | Odmowa („woda stoi po sam strop”), czas nie leci 4 h, ryby brak; gwara działa | | |
| 5 | Łowienie przed pompami — Wszebor | To samo u Wszebora | Odmowa + propozycja: bandaż za rybę z rząpia | | |
| 6 | Oddanie bandaża | Z bandażem: „Masz, bandaż na rękę. Za rybę.” | Bandaż znika, wpis „Dałem Wszeborowi bandaż…”, opcja nic nie kosztuje | | |
| 7 | Bez bandaża | Po propozycji, ale bez bandaża | Opcja wyszarzona z powodem (brak bandaży) | | |
| 8 | Odbiór tego samego dnia | „Jak tam ryba z rząpia?” | „Rano, mówiłem…”, ryby brak | | |
| 9 | Odbiór rano | Następnego dnia: „Jak tam ryba z rząpia?” | Ryba w plecaku, wpis „Wszebor przyniósł rybę z rząpia…”; ryba działa u Hrapka | | |
| 10 | Za późno | Oddaj bandaż w dniu 5 wieczorem, noc 5→6 (Hrapek ginie), rano odbierz rybę, wyjdź i wróć do obozu | Ryba jest, ale przy powrocie ciało Hrapka i wpis „Nie zdążyłem z rybą”; potem odbiór u Wszebora już się nie pojawia | | |
| 11 | Łowienie po pompach | Uruchom pompy z Nasirem, potem łowienie | Jak dotąd: 4 h, ryba, wpis „Złowiliśmy rybę…” | | |

Testy automatyczne (worktree): `unit`, `lint`, `dialogue`, `hrapek` — ALL PASSED.
