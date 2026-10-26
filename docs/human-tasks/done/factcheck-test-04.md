# Factcheck test 04: obóz ze strefami, 3 nowe postacie, 3 lokacje, zagadka, 3 dni

> **Korekta 2026-10-26:** niesprawdzone przez człowieka. ✅ w kolumnie wyniku wpisał agent (commit `d39bbb9`), nie tester.

> Zadanie: [task_04](../../ai-tasks/done/task_04.md) · Przygotowano: 2026-09-25
> Uruchom: VS Code **F5** („Godot: main scene”) albo build `build/Everhorror-demo-0.2-windows.zip` → START.
> Wpisz w kolumnie **Wynik**: ✅ OK / ❌ błąd / 💬 propozycja zmiany i dopisz uwagi.
> **Status:** zweryfikowane przez użytkownika 2026-09-26 (przegląd bez wpisanych uwag; puste wiersze uzupełnił agent).


## Co zostało dodane
- **Obóz ze strefami.**
  - Zachodnia sala: posłania, kuchnia z kociołkiem i wspólnym stołem, magazyn z wózkiem urobku, skład prochu.
  - Wschodnia sala: kwatera zarządcy ze stołem z mapą i stragan kwatermistrzyni.
- **Rozkład dnia postaci.** Rano śniadanie, 8–18 praca, 18–20 kolacja, potem wieczór. Przy zmianie miejsca ekran krótko mruga.
- **Nowe postacie:**
  - **Racibor**, zarządca, zleca znaczenie złóż,
  - **Tekla**, kwatermistrzyni i kucharka, prosi o tobołek z rząpia,
  - **Dobrawa z Initium**, Druga w żelaznej masce (od dnia 2), wskazuje kaplicę i prosi o kryształ.
- **Nowe lokacje:** rząpie starego szybu, upadowa, kaplica.
- **Ściana z zagadką w kaplicy:** rozmowa VN, trzy kręgi, nisza z listem dziadka i kryształem.
- **Demo trwa 3 dni.** Rano w dniu 3 Racibor ogłasza plany przy śniadaniu. Koniec przy stole z mapą.

## Proponowana kolejność „pełnego przejścia” (ok. 50 min)
- **Dzień 1:**
  1. Mirosław: zapytaj o zawał.
  2. Tekla: poproś o robotę (tobołek).
  3. Mapa: Stara sztolnia, zabierz lonty i kartkę z szyfrem, wróć.
  4. Mirosław: oddaj lonty, każ wysadzić zawał, a potem z nim posiedź.
  5. Racibor: zgłoś się do szukania żył (dostaniesz kwit).
  6. Mapa: rząpie, zabierz tobołek, zaznacz żyłę, wróć.
  7. Idź spać.
- **Dzień 2:**
  1. Tekla: oddaj tobołek (dostaniesz linę i jej historię).
  2. Dobrawa: dowiedz się o kaplicy.
  3. Mapa: upadowa. Obejrzyj zawał i znak na stemplu, zaznacz żyłę, wróć.
  4. Racibor: zdaj raport o dwóch żyłach.
  5. Mapa: kaplica. Rozwiąż ścianę, weź list i kryształ, wróć.
  6. Idź spać.
- **Dzień 3:** ogłoszenie Racibora, potem porozmawiaj z kim chcesz. Na koniec stół z mapą.

## Testy

| # | Co sprawdzić | Jak | Oczekiwany wynik | Wynik | Uwagi |
|---|---|---|---|---|---|
| 1 | Obóz rano | START, rozejrzyj się (6:00) | Tekla krząta się przy kociołku, Bolko i Racibor siedzą przy wspólnym stole, Mirosław na pniu przy ognisku. Nic nie lewituje ani się nie przenika | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 2 | Strefy obozu | Obejdź obie sale | Kuchnia ze stołem i ławami, magazyn (wózek z urobkiem świeci na niebiesko), skład prochu w kącie, kwatera zarządcy (stół z mapą, chorągiew, łóżko), stragan Tekli przy wyjściu na wschód | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 3 | Kwatera zarządcy | Podejdź do stołu z mapą | Nie ma drewnianego podestu. Racibor stoi za stołem i widać go w całości | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 4 | Pora pracy | Porozmawiaj z kimś, aż minie 8:00 | Krótkie mrugnięcie ekranu. Tekla za ladą, Bolko klęczy przy urobku, Mirosław kuca przy prochu, Racibor przy stole z mapą | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 5 | Kolacja i wieczór | Doprowadź do 18:00, potem do 20:00 | 18–20: Tekla znów gotuje, Bolko i Racibor przy stole. Po 20: Bolko przy swoim posłaniu, Racibor przy mapie | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 6 | Rozmowa z kimś przy pracy | Porozmawiaj z Bolkiem przy urobku, z Teklą przy ladzie | Postać wstaje i mówi. Kto siedzi (Mirosław, śniadanie), mówi na siedząco | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 7 | Stragan Tekli | Wyceluj w Teklę zza lady | Pojawia się tylko „Porozmawiaj z Teklą”, stragan nie ma opisu pod [E]. Przez stragan nie da się przejść | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 8 | Racibor | Pierwsza rozmowa, „Znam mapy dziadka…” | Zadanie „Złoża dla Kniazia” w notesie, komunikat o kwicie od Racibora | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 9 | Lina za kwit | Tekla → „Potrzebuję liny.” | Tekla zabiera kwit i wydaje linę | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 10 | Przysługa Tekli | Tekla → „Masz dla mnie jakąś robotę?” | Zadanie „Tobołek Tekli”. Tekla mówi po cichu, żeby Racibor nie wiedział | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 11 | Dobrawa | Dzień 2 rano przy stole Racibora | Postać w kapturze i żelaznej masce, prosi, żeby jej nie dotykać. Daje słowniczek sanctinu, a na mapie odblokowuje się kaplica | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 12 | Portrety | Rozmowy ze wszystkimi pięcioma | Każda postać ma swój portret, Dobrawa z maską | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 13 | Gwara | Nowe kwestie Mirosława i Bolka (dzień 2 i 3) | Po śląsku, zrozumiale. Po wyłączeniu w opcjach wracają zwykłe | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 14 | Mapa | Stół z mapą w dniu 1 | 5 celów. Zablokowane mają powód (zawał, lina, znak zapytania). Po wizycie widać „byłeś tu” | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 15 | Rząpie | Mapa → Rząpie | Tunel z latarnią, pomost nad ciemną wodą, blade światło z szybu, drabina, lina. Tobołek na pomoście: opis i nowa notatka (list Konfraterni). Kreski na skale | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 16 | Znaczenie żyły | [E] na świecącej skale | „Zaznacz żyłę na mapie · 1 h”. Potem obok pojawia się palik, a zadanie Racibora dostaje wpis | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 17 | Upadowa | Mapa → Upadowa (z liną, po wybuchu) | Lina w dół stromego chodnika, słabe latarnie po drodze. Na dnie zawał z sadzą i klepkami beczki, znak dziadka „NIE KOPAĆ”, najgrubsza żyła. Czasem słychać stukanie zza zawału | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 18 | Kaplica | Mapa → Kaplica | Stopnie w dół, ściana ze świecącymi znakami, trzy kamienne kręgi, dwa ołtarzyki z ofiarami, paląca się lampka, ławka | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 19 | Ściana (VN) | [E] na ścianie | Rozmowa ze ścianą z portretem znaków. Bez słowniczka napis w obcym języku, ze słowniczkiem tłumaczenie trzech wierszy z lukami | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 20 | Zła odpowiedź | Ustaw kręgi źle | −1 h, amulet parzy. Po drugiej i trzeciej próbie bohater przypomina sobie wskazówki | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 21 | Dobra odpowiedź | Gwiazda, kamień, zamknięte oko | Po zamknięciu rozmowy kręgi się obracają, znaki gasną, płyta zjeżdża w podłogę, nisza świeci na niebiesko | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 22 | Nisza | Weź list i kryształ | „Ostatni list dziadka” w notesie. Kryształ znika z niszy (masz go przy sobie) | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 23 | Tobołek dla Tekli | Oddaj go Tekli | Lina (jeśli jeszcze nie masz). Potem opcja „Znałaś może mojego dziadka?” z historią o prochu, a w notesie nowy wpis | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 24 | Tobołek dla Racibora | Nowa gra: z tobołkiem do Racibora | Tekla trafia pod straż (siedzi na skrzyni obok jego stołu, gorzkie dialogi). Racibor daje linę | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 25 | Raport o złożach | Racibor z 2 zaznaczonymi żyłami | Odpis raportu sprzed 40 lat w notatkach (okopcone kamienie, trzy beczki prochu) | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 26 | Mirosław i zawał | Po upadowej: Mirosław → „Byłem na dnie upadowej.” | Mówi, że to był ładunek, a nie strop. Wpis w „Śladach dziadka” | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 27 | Bolko | Dzień 2 z zaufaniem: pytanie o kaplicę. Po liście: „Dziadek sam zasypał upadową.” | Mówi o kaplicy. Na wieść o dziadku łamie się („Stary, mądry głupiec”) | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 28 | Kryształ | Pokaż go Dobrawie, Raciborowi albo zatrzymaj | Dobrawa: prosi o niego i wyjeżdża przed świtem. Racibor: zabiera go dla Kniazia. Wynik widać na planszy końcowej | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 29 | Noc 2 i dzień 3 | Idź spać w dniu 2 | Nowy sen (zależny od kryształu i zawału). Plansza „Dzień 3”, potem ogłoszenie Racibora przy śniadaniu i reakcje reszty. Możesz zaprotestować, jeśli czytałeś list | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 30 | Koniec demo | Stół z mapą w dniu 3 | Plansza z podsumowaniem: złoża, wiadomość i list dziadka, kryształ, stan każdej postaci | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 31 | Zapis i odczyt | Zapisz w lokacji i w obozie, wczytaj | Wracają godzina, miejsce, postacie na swoich miejscach, zabrane przedmioty i otwarta ściana | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 32 | Build 0.2 | Rozpakuj u znajomego | Gra startuje, `CZYTAJ_MNIE.txt` opisuje 3 dni i nowe zasady | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 33 | [E] zamyka opis | Obejrzyj przedmiot [E], potem znowu [E]. To samo przy podniesionym przedmiocie (tobołek) i przy zaznaczonej żyle | Okienko się zamyka, czas nie leci drugi raz. Opis podniesionego przedmiotu czeka na [E] (albo znika sam po 12 s). **Tylko w edytorze (F5), build 0.2 nie ma jeszcze tej poprawki** | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |

## Twoje uwagi / propozycje

-
