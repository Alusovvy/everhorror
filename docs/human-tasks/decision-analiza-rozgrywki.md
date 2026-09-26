# Decyzje: analiza mechanik i odczucia z gry (po task_08)

> Przygotowano: 2026-09-26 · Na prośbę z czatu („Przeanalizuj obecne mechaniki i feeling rozgrywki…”) · Bez zadania w `ai-tasks/`. Po decyzjach zrobię z nich zadanie.
> Podstawa: specyfikacja (`00_gra`, `03_mechaniki/*`, `07_balans`, `04_tresc/miejsca`, `tydzien`), kod (`player.gd`, `story_director.gd`, `vn.gd`, `game_state.gd`, `expeditions.gd`), factchecki 01–08 i krótka sesja w grze w tle (wstęp, obóz, rozmowa z Mirosławem, Stara sztolnia, Kostnica, mapa [M]).
> **Status: czeka na Twoje decyzje.** Wpisz wybór w ostatniej kolumnie tabeli decyzji. Możesz też dopisać uwagi pod każdym punktem.

## Czego nie sprawdziłem
- Nie przeszedłem całego tygodnia. Liczby niżej wyliczyłem z tabel balansu i grafu dróg, a nie z prawdziwej rozgrywki.
- Odczucia z ruchu i dźwięku opisuję na podstawie kodu i zrzutów ekranu. Sam tego nie słyszę ani nie czuję pod myszką. **Punkty 5 i 6 najlepiej sprawdzić samemu w 10 minut gry.**
- Factchecki 03–07 mają same ✅ bez uwag. Sprawdzały, czy funkcje działają, a nie balans czy klimat. O tempie tygodnia nie mam więc żadnej informacji od testerów.

## Co działa i warto to zostawić
- **Pętla jest czytelna:** obóz → stół z mapą → wyprawa → podsumowanie → noc → poranne zdanie. Każdy dzień ma początek, środek i rozliczenie.
- **Rozmowy VN wyglądają dobrze.** Żywy portret, gwara i koszt przy opcji („Posiedzę z tobą przy ogniu. (1 h)”) sprawiają, że wybór w rozmowie ma wagę.
- **Mapa jak papier dziadka:** czerwona trasa, godziny, powód blokady. Bardzo czytelna.
- **Sieć kluczy** (lina, olej, kilof, łom, pompy, zawał) robi z grafu miejsc małą metroidvanię: każda rzecz otwiera nowe drogi.
- **Noc jako rozliczenie** (sen, jedno zdanie o poranku, autozapis) daje dobry rytm i poczucie, że świat żyje bez gracza.
- **Dźwięk** (kapanie, stukanie zza ściany, pogłos) testy przeszedł bez uwag. To najmocniejszy nośnik horroru w demie.

## Najważniejsze wnioski (od najważniejszego)

### 1. Norma jest za łatwa: presja czasu znika w połowie tygodnia
Gracz, który idzie tylko po żyły, ma 12 żył **około południa dnia 4** (koszty dzisiejsze, rozmowa 0,5 h):

| Dzień | Trasa | Żyły razem |
|---|---|---|
| 1 | Racibor, Wszebor, Mirosław → Stara sztolnia (2) → Stare wyrobisko (2, obuch) → obóz, lonty i obuch oddane ok. 20:30 | 4 |
| 2 | kilof od Wszebora przy śniadaniu, wybuch (4 h) → Rząpie (2, jedna kilofem) → Komora pomp (1) → obóz ok. 23:00 | 7 |
| 3 | Zawalony chodnik (1) → Kuźnia (1, łom) → obóz 16:00 → Przekop Grabca (1) → obóz po północy | 10 |
| 4 | Grzybowa grota (2) → Parująca szczelina (2) | **14** |

- Z rozmowami i zadaniami wychodzi mniej więcej dzień 5–6. W dniach 6–7 norma przestaje więc być zmartwieniem, a „Zostałeś sam” zobaczy tylko ktoś, kto ją zignoruje.
- **Punkt 6 z task_09 (5 minut za opcję) jeszcze bardziej to rozluźni.** Krótkie rozmowy będą kosztować 10–15 minut zamiast 30.
- Filar 1 obiecuje, że gracz kończy dzień z myślą „nie zdążyłem”. Dziś tak jest mniej więcej do dnia 4.

### 2. „Ludzie się kruszą” działa tylko u trzech postaci
Po siedmiu nocach bez szczególnych zdarzeń (tylko stały spadek i wstrząs) poczytalność wygląda tak. Próg „spokojny” u NPC to ≥ 40:

| Postać | Start | Po tygodniu | Pasmo na koniec |
|---|---|---|---|
| Racibor | 72 | 42 (bez normy od nocy 5: ok. 21) | spokojny (niespokojny) |
| Bolko | 80 | 64 | spokojny |
| Tekla | 85 | 69 (pod strażą ok. 0) | spokojny (**zero, ale bez skutku**) |
| Wszebor | 76 | 60 | spokojny |
| Nasir | 72 | 56 | spokojny (choruje na ciele) |
| Hagiwara | 80 | 64 | spokojny |
| Sobek | 84 | 68 | spokojny |
| Anzelm | 64 | ok. 38 (bez pogodzenia z Sabiną) | niespokojny |
| Sabina | 48 | ok. 36 | niespokojny |
| Dobrawa | 52 | ok. 20 | niespokojny |
| Mirosław | 38 | 0 bez opieki | ginie |

- **7 z 11 postaci w obozie przez cały tydzień jest „spokojnych”.** Ich dialogi i miejsca w obozie nigdy nie pokażą objawów, choć system to obsługuje.
- Jedyne upadki to Mirosław (świetnie działa), gorączka Nasira i odejście Dobrawy.
- Tekla pod strażą schodzi do zera w okolicy ostatniej nocy, a gra nic z tym nie robi, bo efekt przy 0 jest tylko na karcie.

### 3. Bohater rzadko dochodzi do „na krawędzi”, więc winieta i szepty są rzadkie
- Bez żadnych zdarzeń: 80 − 7 nocy × 3 = **59** na koniec tygodnia, czyli wciąż prawie „spokojny”.
- Groza wszystkich miejsc razem to 26, a obiekty i rozmowy dokładają ok. 20.
- Za to ognisko co wieczór oddaje +4…+6 (razem ok. 30), a nalewka +15 i świece po +6.
- Moja ocena: typowy gracz kończy tydzień jako „niespokojny”. Winietę i szepty (task_06) zobaczy ktoś, kto w jeden dzień zwiedzi kostnicę, galerię i grotę. To szacunek, trzeba go sprawdzić na prawdziwym przejściu.

### 4. Horror jest prawie tylko w tekście, a w FPP nic się nie dzieje
- Szepty na krawędzi to komunikaty w HUD („Ktoś wymawia twoje imię…”), a nie dźwięk.
- W miejscach wypraw nic nie dzieje się w czasie rzeczywistym. Chodzenie jest darmowe i bezpieczne, więc FPP sprowadza się do „podejdź do świecącego i wciśnij E”.
- Kostnica, najstraszniejsze miejsce, na zrzucie wygląda jak prostokątna sala z półkami (szablon `chamber()`). Przerażenie niesie tylko zdanie przy wejściu.
- Przy wejściu do Kostnicy wyskoczyło: „To miejsce cię przygniata. Czujesz się: spokojny.” Tekst przeczy sam sobie i gasi nastrój (zob. „Drobne poprawki”).

### 5. Ruch jest zbyt „growy” jak na horror
- Prędkość to **5 m/s** (lekki trucht), bez rozpędu i hamowania: postać rusza i staje w jednej klatce.
- Nie ma kołysania kamery. Jest jeden zapętlony dźwięk kroków, taki sam na desce, skale i w wodzie po kolana.
- Rana spowalnia tylko drogę na mapie (+1 h). W FPP ciężko ranny bohater biega tak samo szybko.
- W Amnesii i SOMIE chód to ok. 2,5–3,5 m/s. Wolniejszy krok sam buduje napięcie i sprawia, że małe miejsca wydają się większe.

### 6. Wszystko ma jedną, ciepłą barwę
- Obóz, Stara sztolnia i wejście do Kostnicy mają tę samą pomarańczową paletę latarń. Obóz wygląda przytulnie (to dobrze), ale tunele wyglądają tak samo przytulnie (to źle).
- Głębokość nie zmienia obrazu: poziom 1 i poziom 4 mają podobnie dużo światła.
- Błękit żył, który ma być „obcy”, ginie w ciepłej mgle.

### 7. Po 22:00 kara jest symboliczna
Powrót po nocy kosztuje −3 poczytalności, bez względu na to, czy to 22:30, czy 3:00, a rano i tak budzisz się o 6:00. Opłaca się więc zostać w tunelach „jeszcze jedną żyłę”, co osłabia koniec dnia jako granicę.

### 8. Podświetlenie NPC jest bardzo mocne
Mirosław na zrzucie świeci na żółto cały, od stóp do głów. Zespół zdecydował, że podświetlenie w demie zostaje. Pytam tylko, czy może być łagodniejsze.

### 9. Zakończenie zależy tylko od normy
Obie plansze końcowe wybiera liczba żył. Losy ludzi, dziadek i kryształ są tylko w tekście podsumowania. Skoro norma jest łatwa (punkt 1), prawie każdy zobaczy to samo zakończenie.

## Decyzje

| # | Pytanie | Opcje | Rekomendacja | Twój wybór |
|---|---|---|---|---|
| 1 | **Jak przywrócić presję normy w dniach 5–7?** | **a)** Norma etapami: Racibor chce np. 4 żył do wieczora dnia 3, 8 do dnia 5 i 14 do dnia 7. Każdy etap sprawdza przy śniadaniu (upomnienia już są). **b)** Wyższa norma (np. 16 z 25). **c)** Droższa żyła: zaznaczenie 2 h zamiast 1 h. **d)** Zostawić 12 i sprawdzić po task_09 | **a)**: presja co dwa dni zamiast jednej na końcu. Wykorzystuje istniejące upomnienia i nie zmienia mapy. Liczby dopasuję po przeliczeniu kosztów z task_09 | |
| 2 | **Jak sprawić, żeby kruszyło się więcej ludzi?** | **a)** Zdarzenia tygodnia mocniej uderzają we wszystkich: wstrząs −8 zamiast −2, odejście albo śmierć kogoś z obozu −5 dla pozostałych, praca w głębi −1 za noc. Do dnia 5 dwie, trzy osoby więcej wchodzą w „niespokojny”. **b)** Efekt przy zerze dla 2–3 kolejnych postaci, np. Tekla pod strażą ucieka nocą z zapasami, Racibor bez normy zaczyna fałszować księgę, Anzelm odmawia leczenia. **c)** Oba | **c)**, ale tylko dla trzech postaci: Tekli, Racibora i Anzelma, bo ich spadek już dziś wynika z decyzji gracza. Treść efektów to decyzja Ren i Rolanda, ja napiszę wersje [ROBOCZE] | |
| 3 | **Czy bohater ma częściej trafiać na krawędź?** | **a)** Najpierw zmierzyć: dziennik czasu z task_09 zapisuje też stan głowy i zdrowia, a po jednym Twoim przejściu tygodnia dostroję liczby. **b)** Od razu mocniej: groza miejsc ×1,5, noce od dnia 5 po −5. **c)** Od razu słabsze leczenie: ognisko +2…+3 | **a)**: to tanie, bo dziennik i tak powstaje w task_09. Zmiana na ślepo mogłaby przesadzić w drugą stronę | |
| 4 | **Horror w FPP: co dodać?** | **a)** Dźwięk zamiast tekstu: szepty na krawędzi jako dźwięk 3D za plecami (tekst tylko jako napis), stukanie zza ściany coraz bliżej z każdym dniem, lampa przygasa na krawędzi. **b)** Do tego jedno zdarzenie „coś widziałeś” w 1–2 miejscach (np. sylwetka na końcu Kostnicy albo Galerii, która znika, gdy podejdziesz). **c)** Nic, zostaje tekst | **a)** zawsze, a **b)** jako próba w Kostnicy. Oba zgodne z „niepokojem zbyt spokojnego miejsca”, bez jump scare'ów. Dźwięki z CC0 (Freesound) albo syntezator | |
| 5 | **Ruch bohatera** | **a)** Chód ok. 3,2 m/s z krótkim rozpędem i hamowaniem, lekkie kołysanie kamery (wyłączane w OPTIONS), kroki zależne od podłoża (deska, skała, woda), wolniejszy chód od pasma „ranny”. **b)** Tylko wolniej (3,2 m/s). **c)** Zostawić 5 m/s | **a)**: najtańsza zmiana, która najmocniej zmienia odczucie. Sprawdź ją sam przez 10 minut. Test `camp_walk` pilnuje, żeby wolniejszy gracz dalej wszędzie dochodził | |
| 6 | **Światło i barwa według głębokości** | **a)** Ciepły obóz, zimne tunele: z każdym poziomem mniej latarń, chłodniejsza i gęstsza mgła, a na poziomach 3–4 jedynym światłem jest lampa bohatera i błękit żył. **b)** Po prostu ciemniej wszędzie. **c)** Zostawić | **a)**: obóz jako bezpieczne ciepło, dół jako obcy błękit. To wzmacnia filar 3 („tajemnica w głąb”) bez nowych modeli, samymi generatorami | |
| 7 | **Kara za późny powrót** | **a)** Każda rozpoczęta godzina po 22:00 kosztuje −3 poczytalności, a po powrocie po północy budzisz się o 7:00 zamiast o 6:00. **b)** Jak dziś (−3 raz) | **a)**: koniec dnia znów jest granicą, a decyzja „jeszcze jedna żyła” ma cenę | |
| 8 | **Podświetlenie w demie (zostaje, pytanie o siłę)** | **a)** Łagodniej: przedmioty tylko delikatnym obrysem, NPC bez podświetlenia, tylko z napisem „[E] Porozmawiaj…”. **b)** Jak dziś | **a)**: spełnia decyzję „w demie zostaje”, a postaci przestają wyglądać jak w grze akcji | |
| 9 | **Czy zakończenie ma zależeć od czegoś więcej niż norma?** | **a)** Te same dwie plansze, ale ich tytuł i pierwszy akapit zmieniają się według losu ludzi (np. „Koniec tygodnia” / „Koniec tygodnia. Nie wszyscy wyjadą” przy dwóch albo więcej stratach). **b)** Trzecie zakończenie. **c)** Zostawić | **a)**: bez nowego kanonu, tylko odbicie decyzji w tekście. Treść do akceptacji przez Ren i Vitava | |
| 10 | **Kolejność prac** | **a)** Najpierw task_09, potem jedno zadanie „feeling” (punkty 4–8), a na końcu balans (1–3) z liczbami z dziennika. **b)** Najpierw balans, potem feeling. **c)** Wszystko w task_09 | **a)**: feeling można sprawdzić od razu w grze, a do balansu potrzebne są liczby z dziennika czasu, który powstaje w task_09 | |

## Drobne poprawki (zrobię przy najbliższym zadaniu, bez decyzji)
- **Sprzeczny komunikat** „To miejsce cię przygniata. Czujesz się: spokojny.”: stan głowy dopiszę tylko wtedy, gdy zmieni się pasmo. Samo przygniatające zdanie zostaje.
- **Etykiety na mapie nachodzą na siebie**: „Stare wyrobisko” i „Kaplica” zlewają się na rysunku mapy.
- **Przejście przez nieodwiedzone miejsce**: trasa ze Starej sztolni do Kostnicy prowadzi przez Kaplicę, a Kaplica zostaje „nowa”, choć bohater przez nią przeszedł. Na planszy przybycia dopiszę „przez: Kaplica”, żeby gracz wiedział, którędy szedł. Zasady rozpoznania nie zmieniam.
- **Ostrzeżenia o błędnych UID** w scenach paczki `MineAndCavesSet` przy każdym starcie. Nie szkodzą, a paczki nie edytujemy. Zostawiam, piszę tylko dla porządku.

## Pytania do zespołu (nie blokują)
- **Roland:** czy zmiana normy na etapy (decyzja 1a) pasuje do opowieści Racibora? Etapy mogą być „wozem z góry co dwa dni”, który zabiera raport.
- **Ren i Roland:** jakie efekty przy zerze dla Tekli, Racibora i Anzelma (decyzja 2)? Na kartach są propozycje, ale nie wiem, które są kanonem.
- **Ren:** czy „coś widzianego” w Kostnicy (decyzja 4b) nie wchodzi w kanon Pierwszego albo „Czternastu kresek”? Jeśli tak, zrobię coś neutralnego (ruch cienia, zgaśnięcie świecy).

## Podsumowanie
Demo ma solidny szkielet: czytelną pętlę dnia, dobre rozmowy VN, mapę i noce, które dają rytm. Słabsze są trzy obietnice z filarów. **Presja czasu** znika około dnia 4–5, bo norma 12 z 25 żył jest łatwa. **Ludzie się nie kruszą**, bo 7 z 11 postaci jest spokojnych przez cały tydzień. **Horror** jest głównie w tekście, a nie w FPP: szybki ruch bez bezwładności, jedna ciepła paleta od obozu po dno i szepty jako komunikaty. Rekomenduję po task_09 jedno zadanie „feeling” (ruch, światło według głębokości, dźwięk zamiast tekstu, łagodniejsze podświetlenie, kara za noc), a potem balans normy i poczytalności na podstawie liczb z dziennika czasu. **Status: czeka na Twoje decyzje w tabeli.**
