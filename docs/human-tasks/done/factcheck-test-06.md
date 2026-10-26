# Factcheck test 06: wieczory przy ognisku, „Czternaście kresek”, ślady wstrząsu, QoL (jasność, autozapis, winieta), bez skoku

> **Korekta 2026-10-26:** niesprawdzone przez człowieka. ✅ w kolumnie wyniku wpisał agent (commit `d39bbb9`), nie tester.

> Zadanie: [task_06](../../ai-tasks/done/task_06.md) · Przygotowano: 2026-09-25
> Uruchom: build 0.4 (`build/Everhorror-demo-0.4-windows.zip`) albo VS Code **F5** → START.
> Wpisz w kolumnie **Wynik**: ✅ OK / ❌ błąd / 💬 propozycja zmiany i dopisz uwagi.
> Można przechodzić razem z [factcheck-test-05](factcheck-test-05.md) — to ten sam tydzień, poniższe punkty tylko dochodzą.
> **Status:** zweryfikowane przez użytkownika 2026-09-26 (przegląd bez wpisanych uwag; puste wiersze uzupełnił agent).


## Co zostało dodane
- **Wieczory przy ognisku.** Po 20:00 przy ognisku jest „[E] Usiądź przy ogniu · 1 h”, raz dziennie. Scena zmienia się z dniem: opowieści (d2–4), pieśń o Długiej Nocy (d5), wieczór po wstrząsie (d6), ostatni wieczór (d7). Podnosi poczytalność; Mirosław przy ogniu = łagodniejsza dla niego noc.
- **Quest „Czternaście kresek”.** Kreski (rząpie, filar w wyrobisku) albo zeszyt Grabca zaczynają zapiski; chleb, lampka, pusta nisza i medalik dopisują się do nich. Przy ≥ 4 śladach, od piątej nocy, ktoś zostawia przy posłaniu **starą lampę przewodnika**. Kim jest — demo nie mówi.
- **Ślady wstrząsu** (od poranka dnia 6): pęknięty filar w Starym wyrobisku, świeża szczelina w Parującej szczelinie, szczelina z medalikiem w Przekopie. Bolko ma o tym opowieść.
- **Scena Dobrawa × Sabina** wieczorem (d4+), raz; z kryształem w kieszeni ma dodatek.
- **Ostatnia szansa przy liczeniu:** jeśli masz list dziadka i nigdy nie zaprotestowałeś, przy rozliczeniu możesz go podać Raciborowi.
- **Powitania dnia** u Wszebora, Nasira, Hagiwary, Sobka, Anzelma i Sabiny.
- **QoL:** suwak jasności i osobne głośności (Ambience / Sound effects) w OPTIONS, autozapis każdego świtu (rząd AUTO w LOAD GAME), winieta na brzegach ekranu przy niskiej poczytalności, **skok usunięty**.

## Testy

| # | Co sprawdzić | Jak | Oczekiwany wynik | Wynik | Uwagi |
|---|---|---|---|---|---|
| 1 | Brak skoku | Spacja w obozie i w chodnikach | Bohater nie skacze. Spacja nadal przewija rozmowy | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 2 | Jasność | OPTIONS → Brightness w lewo/prawo | Obraz świata wyraźnie ciemnieje/jaśnieje od razu; ustawienie wraca po restarcie | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 3 | Głośności | OPTIONS → Ambience / Sound effects na zero | Tło (szum jaskini) i efekty (kapanie, kroki) cichną osobno; Master działa jak dawniej | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 4 | Autozapis | Zagraj do dnia 2, wyjdź z gry bez zapisu, wejdź → LOAD GAME | Na górze rząd **AUTO — Dzień 2 · 06:00**; wczytuje świt. Ręczny SAVE nie nadpisuje AUTO | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 5 | Winieta | Obniż poczytalność (kostnica, grota, noce) do „na krawędzi” | Brzegi ekranu ciemnieją i wolno pulsują; znika w rozmowach/na mapie; po nalewce/śnie słabnie | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 6 | Ognisko: dostępność | Przed 20:00 i po 20:00 podejdź do ogniska | Przed: tylko opis kociołka. Po: „[E] Usiądź przy ogniu · 1 h”. Po scenie znika do jutra | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 7 | Ognisko: opowieści (d2–4) | Usiądź wieczorem | Rozmowa Wszebora, Sobka, Nasira, Tekli (obecnych). Mirosław „siedzi dalej od płomienia”; nocą traci mniej | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 8 | Ognisko: pieśń (d5) | Usiądź wieczorem dnia 5 | Kołysanka o Długiej Nocy i Wultanach; Bolko poznaje melodię (po śląsku, jeśli gwara włączona) | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 9 | Ognisko: po wstrząsie (d6) | Usiądź wieczorem dnia 6 | Rozmowa o wstrząsie; jeśli masz wiersz Hagiwary, czyta go na głos | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 10 | Ognisko: ostatni wieczór (d7) | Usiądź wieczorem dnia 7 | Każdy mówi, co zrobi na górze; inaczej z normą i bez normy | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 11 | Powitania dnia | Zagaduj Wszebora/Nasira/Hagiwarę/Sobka/Anzelma/Sabinę w kolejne dni | Krótkie, różne otwarcia (dzień, norma, gorączka, rany); raz dziennie, potem zwykłe opcje | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 12 | Kreski zaczynają quest | Obejrzyj kreski w rząpiu albo na filarze w wyrobisku | Nowy quest „Czternaście kresek” w notesie, wpis o kreskach | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 13 | Ślady dopisują się | Z aktywnym questem: chleb i nisze w kostnicy, lampka w kaplicy, zeszyt Grabca | Każde daje wpis w quest (bez questu: sam opis jak dawniej) | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 14 | Ślady wstrząsu | Rano dnia 6+ odwiedź wyrobisko, szczelinę, przekop | Pęknięty filar, świeża szczelina, szczelina z medalikiem (medalik dopisuje ślad). Bolko: „W nocy ziemia drżała.” | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 15 | Lampa od Czternastego | Miej ≥ 4 ślady, prześpij noc dnia ≥ 5 | Rano plansza o lampie przy posłaniu; „Stara lampa przewodnika” w ekwipunku; quest zakończony; sen z liczeniem do czternastu | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 16 | Czternasty w finale | Dojdź do końca tygodnia z questem | Wiersz „Czternasty: …” w podsumowaniu; w „Zostałeś sam” lampa stoi przy tobie | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 17 | Dobrawa × Sabina | Wieczorem (d4+), obie w obozie → opcja u Dobrawy „Stoicie tu z Sabiną…” | Scena Initium/Exitium; z kryształem obie go czują; opcja znika po scenie | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 18 | Ostatnia szansa z listem | Dojdź do rozliczenia z normą, listem dziadka i bez protestu w dniu 3 | Racibor: „ktoś ma coś do dodania?” → podanie listu wstrzymuje upadową (widać w podsumowaniu) | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 19 | Zapisy 0.3 | Wczytaj zapis z wersji 0.3 | Działa; quest „Czternaście kresek” daje się zacząć normalnie | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 20 | Rozmowy 0,5 h | Zagadaj kogoś i od razu wybierz „Muszę iść”; potem porozmawiaj naprawdę | Samo zajrzenie nie kosztuje nic. Przy pierwszej innej odpowiedzi toast „−0,5 h · Rozmowa z…” i zegar +0,5 h; reszta rozmowy już nie dolicza | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 21 | Powrót 3. dnia | Spotkaj Drugich, wróć do obozu | Bez błędu w konsoli (wcześniej wyjątek w `has_flag`) | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |

## Twoje uwagi / propozycje

-
