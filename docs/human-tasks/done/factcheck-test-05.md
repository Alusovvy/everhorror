# Factcheck test 05: ekwipunek, wyprawy z [M], 25 żył i norma, 10 nowych miejsc, 9 nowych postaci, tydzień

> **Korekta 2026-10-26:** niesprawdzone przez człowieka. ✅ w kolumnie wyniku wpisał agent (commit `d39bbb9`), nie tester.

> Zadanie: [task_05](../../ai-tasks/done/task_05.md) · Przygotowano: 2026-09-25
> Uruchom: VS Code **F5** („Godot: main scene”) → START. Albo build 0.3: `build/Everhorror-demo-0.3-windows.zip` (rozpakuj, uruchom `Everhorror.exe`).
> Wpisz w kolumnie **Wynik**: ✅ OK / ❌ błąd / 💬 propozycja zmiany i dopisz uwagi.
> **Status:** zweryfikowane przez użytkownika 2026-09-26 (przegląd bez wpisanych uwag; puste wiersze uzupełnił agent).


## Co zostało dodane
- **Ekwipunek [I].** Lista rzeczy z opisami, „UŻYJ” przy lekach i świecach, a na górze stan bohatera słowami i postęp normy.
- **Przedmioty (17).** Bandaże, lekarstwo, nalewka, świeca, olej, łom, obuch, kilof, grzyb, odłamek, Daleki Klejnot, amulet dziadka i dawne klucze. Część działa i na ciebie, i na NPC (lekarstwo dla Nasira, nalewka dla Mirosława, bandaże dla Welfa).
- **Stół z mapą.** Graf dróg z trasą, licznik żył wobec normy i przycisk **WYRUSZ** („Onward”). W chodnikach **[M]** (albo drogowskaz) prowadzi dalej albo z powrotem do obozu. Po powrocie wyskakuje **podsumowanie wyprawy**.
- **25 żył w 15 miejscach.** Trzy z nich są pod naciekiem i trzeba je odkuć kilofem. **Norma Kniazia:** 12 żył do wieczora dnia 7. Racibor upomina przy śniadaniu. Rano w dniu 8 liczy żyły: z normą koniec „Koniec tygodnia”, bez niej „Zostałeś sam”.
- **10 nowych miejsc:** Stare wyrobisko, Komora pomp, Kuźnia starej ekipy, Grzybowa grota, Przekop Grabca, Zalany chodnik, Ślepy szyb, Kostnica, Parująca szczelina, Kryształowa galeria.
- **5 postaci obozu:** Wszebor (Hawiar), Nasir (Sułtanat), Hagiwara (Cesarstwo), Sobek (Egzarcha), brat Anzelm (były Zakon).
- **Wyprawa Drugich z Exitium w dniu 3:** Ottokar, Sabina (dołącza do obozu), Hieronim, Welf. Potem spotyka się ich losowo w tunelach.
- **Zdrowie, poczytalność i gorączka bohatera.** Rany, śmierć tylko po wcześniejszych ranach, z opcją „od rana”. Załamanie zabiera resztę dnia.
- **Zakładka „Ludzie” w notesie**, gwara dla nowych kwestii górników, przegląd tekstów.

## Proponowana kolejność testu (skrót tygodnia, ok. 2–3 h)
- **Dzień 1:**
  1. Racibor: zadanie żył.
  2. Wszebor: „Potrzebuję porządnego kilofa”.
  3. Nasir: pompy.
  4. Wyprawa: Stara sztolnia, potem [M] do Starego wyrobiska (żyły i obuch) i powrót.
  5. Wszebor: obuch.
  6. Mirosław: lonty i wybuch.
  7. Sen.
- **Dzień 2:**
  1. Wszebor: kilof.
  2. Tekla: olej.
  3. Nasir: olej.
  4. Wyprawa: rząpie (żyła pod naciekiem kilofem), potem [M] do Komory pomp.
  5. Kuźnia (łom), jaskinia przy starym wejściu (skrzynia łomem).
- **Dzień 3:** ogłoszenie Racibora, pierwsza wyprawa: spotkanie z Drugimi, powrót: Sabina w obozie.
- **Dni 4–7:**
  - gorączka Nasira i lekarstwo,
  - pompy z Nasirem, Zalany chodnik, Kryształowa galeria (olej),
  - grota i grzyby,
  - Ottokar i Welf w głębi,
  - pilnuj normy.
- **Rano w dniu 8:** rozliczenie.

## Testy

| # | Co sprawdzić | Jak | Oczekiwany wynik | Wynik | Uwagi |
|---|---|---|---|---|---|
| 1 | Ekwipunek | [I] w obozie i w chodnikach | Okno z listą, opisem i stanem bohatera słowami. [I] albo [Esc] zamyka. Amulet dziadka (złoty, z kawałkiem błękitnej stali) jest od początku | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 2 | Użycie przedmiotu | Zraniony (np. para w szczelinie) → [I] → Bandaże → UŻYJ | −0,5 h, opis opatrywania, stan się poprawia. Przy pełnym zdrowiu UŻYJ jest wyłączone z podpowiedzią | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 3 | Stół z mapą | Stół w kwaterze Racibora | Rysunek grafu, trasa czerwonym atramentem, licznik „Żyły błękitu: X z 12 · termin…”, lista z czasem i „nowe”/„żyły 1/2”, **WYRUSZ** | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 4 | Pierwsza wizyta | WYRUSZ do nowego miejsca | Droga + 1 h rozpoznania, plansza z nazwą, zdanie o miejscu. Straszne miejsca obniżają poczytalność | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 5 | [M] w chodnikach | W miejscu wyprawy [M] (albo drogowskaz) | „Dokąd dalej?”: sąsiednie miejsca z godzinami i WRACAJ DO OBOZU. [M]/[Esc] zostaje. W obozie [M] tylko podpowiada | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 6 | Podsumowanie wyprawy | Wróć do obozu | Okno: godziny, miejsca, nowe żyły i norma, przyniesione rzeczy, zdarzenia, stan, zdanie komentarza. [E] zamyka | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 7 | Żyły | Zaznacz żyłę (1 h) | Palik, komunikat „Żyła na mapie. …”, kreska na mapie, licznik rośnie | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 8 | Żyła pod naciekiem | Rząpie, upadowa albo kaplica: biały naciek | Bez kilofa: komunikat, czas nie leci. Z kilofem: 2 h, naciek znika, żyła zaznaczona | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 9 | Kilof | Wszebor → zadanie → obuch z wyrobiska → Wszebor → następny dzień | Tego samego dnia „Jutro, mówiłem”. Następnego dnia kilof | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 10 | Pompy | Nasir → olej → następny dzień w Komorze pomp (8–18) → „Pomogę ci przy korbie (2 h)” | Nasir klęczy przy pompie. Po korbie Zalany chodnik dostępny na mapie | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 11 | Zalany chodnik | Wejdź i idź spać | Woda po kolana. Rano gorączka (HUD: „gorączka”), co noc gorzej, lekarstwo leczy | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 12 | Kryształowa galeria | Mapa bez oleju / z olejem | Bez oleju zablokowana z powodem. Z olejem: jasne błękitne ściany, kolumny, 3 żyły, odłamek | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 13 | Łom | Kuźnia → łom → skrzynia w jaskini przy starym wejściu i skrytka na końcu Przekopu Grabca | Skrzynia: 2 bandaże, 2 świece, nalewka (skrzynia zostaje otwarta). Skrytka: olej i „Zeszyt sztygara Grabca” | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 14 | Gorączka Nasira | Dzień 4 | Plansza „Nasir kaszle od świtu”, Nasir na skrzynce przy posłaniu Anzelma. Anzelm zaczyna zadanie | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 15 | Lekarstwo: komu? | Źródła: Tekla (dług albo wymiana), Hagiwara (grzyb), Anzelm (warzy grzyb do rana), Sabina (odłamek), Welf | Oddane Nasirowi: wyzdrowieje i da Klejnot. Bez leku przy ≤ 10 zdrowia wywiozą go na górę | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 16 | Wszebor | Rozmowa rano, w wyrobisku, przy ognisku wieczorem | Głośny Hawiar. Brat Bogdal, Długa Noc, pieśń przy ognisku, nalewka | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 17 | Hagiwara | Przy księdze, wieczorem w kąciku | Uprzejmy wygnaniec. Nagate i Szarzy, Dzień Morza, stan normy z księgi. W dniu 6+ nie dopisze żył | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 18 | Sobek | Przy wyjściu na wschód, kości przy kolacji | Zaklęty miecz świeci, zakład o 3 żyły (nalewka), ostrzeżenie przed von Brühlem | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 19 | Anzelm | Izba chorych | Opatrzy raz dziennie (1 h), da bandaż raz dziennie. Historia z Zakonu. Niechęć do Sabiny | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 20 | Spotkanie z Drugimi | Dzień 3, pierwsza wyprawa | Czworo w płaszczach i maskach przy wejściu, scena VN z Ottokarem. Potem stoją, dopóki nie odejdziesz | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 21 | Sabina w obozie | Po powrocie | Komunikat o Sabinie. Leczy magią (+ ból), wyczuwa żyły, prosi o odłamek. Z Anzelmem można ją pogodzić | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 22 | Drudzy w tunelach | Dni 4–7, głębokie miejsca | Czasem Hieronim (zagadki, świeca, bandaż), Ottokar (oferta: kryształ za 2 żyły, mapy za 1), raz ranny Welf (bandaże) | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 23 | Upomnienie | Rano w dniu 4–7 z mało żyłami | Racibor przy śniadaniu wylicza braki. Odpowiedź do wyboru | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 24 | Koniec bez normy | Rano w dniu 8 bez 12 żył | Scena pustego obozu i plansza „Zostałeś sam” z podsumowaniem | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 25 | Koniec z normą | Rano w dniu 8 z 12+ żyłami | Racibor liczy kreski, plansza „Koniec tygodnia” | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 26 | Śmierć | Będąc rannym weź świece z półki w Ślepym szybie albo zaznacz żyłę przy parze | „Nie żyjesz”, **RETRY FROM MORNING** wraca do poranka tego dnia | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 27 | Załamanie | Niska poczytalność (kostnica, grota, noce) | „Uciekasz przed czymś, czego nie ma”, budzisz się na posłaniu następnego ranka. Na krawędzi w tunelach słychać szepty | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 28 | Mirosław przez tydzień | Nie dbaj o niego / posiedź przy ogniu i daj nalewkę | Bez opieki w którąś noc wysadza się z prochem i zachodni chodnik zamyka się na zawsze. Z opieką trzyma się | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 29 | Notes „Ludzie” | [J] → Ludzie | Poznane postacie z rolą i trzema zdaniami (zdrowie, głowa, do ciebie), bez liczb | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 30 | Gwara | Nowe kwestie Mirosława i Bolka (siedzenie przy ogniu, nalewka, Wszebor, Sabina) | Po śląsku. Po wyłączeniu w opcjach wracają zwykłe | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 31 | Zapis i odczyt | Zapisz w trakcie wyprawy i w obozie, wczytaj | Wraca godzina, miejsce, spotkani Drudzy, stan bohatera, przedmioty. Stary zapis z 0.2 też się wczytuje | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 32 | Teksty | Czytaj opisy i rozmowy | Nic nie brzmi sztucznie. Zapisz zdania, które zgrzytają | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |
| 33 | Trasa omija zamknięte miejsca | Bez liny, z olejem i po uruchomieniu pomp wybierz przy stole Kryształową galerię. Jeśli Mirosław zginął, wybierz Kuźnię albo Ślepy szyb | Czerwona trasa idzie przez rząpie, pompy i zalany chodnik, a nie przez Ślepy szyb czy zasypany chodnik. Upadowa po śmierci Mirosława jest zamknięta z powodem | ✅ | sprawdzone przez użytkownika, bez uwag (2026-09-26) (wpis agenta, nie testera — 2026-09-26) |

## Twoje uwagi / propozycje

-
