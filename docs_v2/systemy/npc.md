# Postacie niezależne (NPC)

> Status: 🟢 zaimplementowane (demo, tydzień) · Właściciel: Roland · Aktualizacja: 2026-09-25 (task_05) · Filary: 2 (Ludzie się kruszą) · Źródło: GDD §4, §5

## Cel
Ekspedycja to drugi, obok czasu, zasób gry. Towarzysze dają informacje, przedmioty i umiejętności, ale sami się psują. Gracz nie dowodzi nimi, tylko zdobywa ich przychylność **[GDD]**.

## Doświadczenie gracza
„Znam tych ludzi. Widzę, że Mirosław jest coraz gorzej, a Nasir kaszle od rana. Czy mam czas im pomóc, skoro Racibor liczy żyły, a ja mam jedno lekarstwo?”

## Zasady
1. **Każdy NPC ma kartę** według [szablonu NPC](../szablony/npc.md). W grze to `NpcData` (`data/npc/*.tres`). Obsada: [Postacie](../swiat/postacie.md).
2. **Frakcje:** Drudzy / Ekspedycja / Inna. Więcej nie dodajemy **[GDD]**.
   - Ekspedycja: Mirosław, Bolko, Racibor, Wszebor, Sobek.
   - Inna: Tekla, Nasir, Hagiwara, Anzelm.
   - Drudzy: Dobrawa (Initium), Sabina, Ottokar, Hieronim, Welf (Exitium).
3. **Rola** decyduje o umiejętnościach. Niektóre akcje wymagają NPC o danej roli **[GDD]**:
   - wysadzenie: tylko Mirosław,
   - pompy: tylko Nasir,
   - kilof z obucha: tylko Wszebor,
   - opatrywanie: Anzelm (zioła) i Sabina (magia).
4. **Poczytalność.** Gdy spadnie do 0, uruchamia się unikalny efekt postaci **[GDD]**:
   - ✅ Mirosław w nocy wysadza się z beczką prochu i na stałe zasypuje zachodni chodnik (upadowa przepada, do kuźni i ślepego szybu da się zejść już tylko od dołu, przez galerię),
   - ✅ Dobrawa schodzi sama na dno i nie wraca,
   - ⬜ pozostali mają efekt tylko na karcie.
   Objawy działają u wszystkich: pasma *spokojny ≥ 40 / niespokojny ≥ 20 / na krawędzi > 0 / załamany 0* zmieniają dialogi i miejsce postaci.
5. **Maksymalna poczytalność zależy od postaci** (Mirosław 50, Drudzy 60, reszta 100) **[GDD]**.
6. **Zdrowie.** ✅
   - Nasir od trzeciej nocy ma gorączkę (−18 zdrowia co noc). Leczy go lekarstwo (dialog), a przy 10 zdrowia Racibor każe go wywieźć na górę.
   - Welf może zostać ranny w tunelach i potrzebuje bandaży.
   - Przedmioty działają na NPC jak na bohatera (`GameState.give_to_npc`). Zob. [Zdrowie i poczytalność](zdrowie_i_poczytalnosc.md).
7. **Obecność.** NPC pojawiają się w obozie i z niego znikają **[GDD]** ✅:
   - rozkład dnia (niżej),
   - stan fabuły (Dobrawa od dnia 2, Sabina po spotkaniu z Exitium),
   - odejścia (status `gone`, `dead`),
   - górnicy pracują za dnia w miejscach wypraw: Wszebor w starym wyrobisku, Nasir przy pompach (`FieldSchedule`).
8. **Drudzy z Exitium w tunelach.** ✅
   - W dniu 3 (albo na pierwszej wyprawie po nim) gracz spotyka całą wyprawę w miejscu, do którego dotarł. Scena VN, potem stoją tam, dopóki gracz nie odejdzie.
   - Sabina dołącza do obozu, kiedy gracz wróci.
   - Później przy każdym przybyciu jest 40% szans (raz na dzień), że w miejscu jest ktoś z trójki:
     - Hieronim: gdziekolwiek,
     - Ottokar: tylko głęboko (głębokość ≥ 3, kaplica, upadowa),
     - Welf: raz ranny w pierwszym głębokim miejscu, a jeśli go opatrzysz, potem zwykłe spotkania.
9. **Zadania** NPC nagradzają informacją, przedmiotem albo reputacją **[GDD]**. ✅ Zob. [Questy](questy.md).
10. **Pomoc w tunelach.** NPC nie idzie fizycznie z graczem, ale akcja kosztuje dużo czasu **[GDD]**. W demie: wysadzenie (4 h), pompy (2 h z Nasirem na miejscu).
11. **Reputacja** liczy się osobno u każdego NPC (−100..100, start 0). Frakcje jej nie mają **[decyzja 2026-09-25, MECHANICS §13 pkt 6]**. ✅
12. **Gracz nie widzi liczb.** ✅ Zakładka „Ludzie” w notesie opisuje słowami zdrowie, głowę i stosunek do bohatera każdej poznanej postaci **[decyzja 2026-09-25, MECHANICS §13 pkt 4]**.

## Rozkład dnia
Każdy NPC ma swoje miejsce zależne od pory dnia (`script/camp_schedule.gd`). Stan fabuły ma pierwszeństwo.

| NPC | Rano (do 8) | Dzień (8–18) | 18–20 | Wieczór (20+) | Wyjątki |
|---|---|---|---|---|---|
| Mirosław | ognisko (siedzi) | skład prochu (kuca) | ognisko | ognisko | na krawędzi (dzień 2+): ciemny kąt; martwy: nie ma go |
| Bolko | wspólny stół | magazyn (klęczy przy urobku) | wspólny stół | przy swoim posłaniu | dzień 2+: zaufanie ≥ 10, rano przy posłaniu gracza; zaufanie < 0, odwrócony |
| Racibor | wspólny stół | stół dowódcy | wspólny stół | stół dowódcy | |
| Tekla | kociołek | lada | kociołek | lada | wydana Raciborowi: pod strażą przy jego stole |
| Dobrawa | stół dowódcy (do 9) | 9–12 stare wózki, 12–16 w tunelach, od 16 na uboczu | na uboczu | na uboczu | dzień 1: nie ma jej; po odejściu: nie ma jej |
| Wszebor | wspólny stół | **w starym wyrobisku** (klęczy przy ścianie) | ognisko (śpiewa) | ognisko | |
| Nasir | wspólny stół | beczka z wodą; od dnia po oleju **przy pompach** | wspólny stół | na ziemi przy wodzie | gorączka: na skrzynce przy posłaniu dla chorych |
| Hagiwara | wspólny stół | pulpit z księgą | wspólny stół | swój kącik z herbatą | |
| Sobek | przy wyjściu na wschód (miecz) | przy wyjściu | kości przy wspólnym stole | przy wyjściu | |
| Anzelm | modlitwa w kącie | izba chorych | izba chorych | izba chorych | przy gorączce Nasira nie modli się rano |
| Sabina | z boku, w kwaterze zarządcy | przy wózku z urobkiem; przy chorych, jeśli Anzelm pozwolił | na uboczu przy Dobrawie | jw. | przed spotkaniem: w tunelach |

- Zmiana miejsca następuje po akcji, która przesuwa czas (rozmowa, powrót). Krótkie mrugnięcie ekranu zasłania przeskok.
- Postać przy pracy wstaje do rozmowy, a siedząca mówi na siedząco. Kto trzyma kostur albo miecz, zostaje w swojej postawie.
- Dialogi znają miejsce postaci (`npc_place()`), np. inaczej wita się Wszebor przy ognisku, a inaczej w wyrobisku (`"teren"` = spotkany w tunelach).

## Dane i strojenie
| Parametr | Wartość | Gdzie |
|---|---|---|
| Poczytalność max / start | Mirosław 50/38, Bolko 100/80, Racibor 100/72, Tekla 100/85, Dobrawa 60/52, Wszebor 100/76, Nasir 100/72, Hagiwara 100/80, Sobek 100/84, Anzelm 100/64, Sabina 60/48, Ottokar 60/54, Hieronim 60/10, Welf 60/44 | `data/npc/*.tres` |
| Pasma objawów | ≥ 40 / ≥ 20 / > 0 / 0 | `GameState.sanity_band()` |
| Reputacja | −100..100, start 0 | `GameState.change_rep()` |
| Nocny spadek poczytalności | Mirosław −4 (+ skutki wybuchu, +2 po wieści o ładunku, −4 mniej po wieczorze w towarzystwie), Bolko −2 (−5 po prawdzie o dziadku), Racibor −4 (−7 od piątej nocy bez normy), Tekla −2 (−10 pod strażą), Dobrawa −5 od drugiej nocy, nowi −2, Anzelm dodatkowo −2, dopóki nie pogodzi się z Sabiną, wstrząs w piątą noc −2 wszystkim | `StoryDirector._resolve_night()` |
| Gorączka Nasira | od trzeciej nocy, −18 zdrowia co noc, wywiezienie przy ≤ 10 | `_resolve_new_people()` |
| Szansa spotkania Drugiego | 40% przy przybyciu, raz na dzień | `StoryDirector.DRUDZY_CHANCE` |

## Zależności
- **[Czas](czas.md)**: rozmowy i pomoc kosztują czas, noc rozlicza stany, rozkład dnia.
- **[Dialogi](dialogi_vn.md)**: warunki i efekty opcji zmieniają reputację, poczytalność i zdrowie.
- **[Ekwipunek](ekwipunek.md)**: przedmioty dla NPC (lekarstwo, nalewka, bandaże, obuch, olej).
- **[Eksploracja](eksploracja_kopalni.md)**: miejsca wymagające roli, spotkania w tunelach.
- **[Fabuła](../swiat/fabula.md)**: zakończenia zależą od stanu NPC.

## Przypadki brzegowe
- NPC potrzebny do zadania odchodzi → zadanie przepada (Nasir wywieziony: pomp nikt nie uruchomi).
- Jedyny NPC o danej roli znika → miejsca wymagające tej roli są zablokowane na stałe. To zamierzona konsekwencja (Mirosław i zachodni chodnik).
- Gracz odchodzi od rannego Welfa bez pomocy → Welf przepada (`welf_lost`).
- NPC jest nieobecny → nie da się z nim rozmawiać, znika też jego kolizja.

## Implementacja
✅
- `NpcData` (karta), rejestr i stan w `GameState` (poczytalność, zdrowie, reputacja, status, miejsce, gorączka `fever_<id>`),
- `Npc` (model, kolizja, rozmowa naliczana przez VN: 0,5 h przy pierwszej realnej odpowiedzi, pozy),
- `CharacterModel`:
  - części Quaterniusa na wspólnym szkielecie, kobiece i męskie ciało,
  - kolor skóry,
  - maska na kości głowy, kostur albo miecz w dłoni,
  - zapętlone pozy pracy,
- `CampSchedule` (obóz), `FieldSchedule` (tunele: górnicy przy pracy, Drudzy),
- `StoryDirector.apply_world_state()` (rozstawienie postaci) i losowanie spotkań.

⬜ Efekty przy 0% dla Racibora, Tekli, Bolka, nowych postaci.

## Otwarte pytania
- ❓ Czy Drudzy z Exitium mają zostać w pełnej grze (Ren)? To robocze postacie z task_05.
- ❓ Ilu NPC w pełnej grze?
