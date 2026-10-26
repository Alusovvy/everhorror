# Zdrowie i poczytalność bohatera

> **Materiał referencyjny — nie aktualizować.** Źródło prawdy: specyfikacja (`C:/dev/gamedev/everhorror/specification`, `WORKFLOW.md`).

> Status: 🟢 zaimplementowane (demo) · Właściciel: Roland · Aktualizacja: 2026-09-25 (task_05) · Filary: 1, 2 · Źródło: MECHANICS §13 pkt 3, 4, 5

## Cel
Kopalnia zabiera zdrowie i rozum także bohaterowi. Rany i strach to kolejny koszt wypraw obok czasu. Śmierć przychodzi dopiero wtedy, gdy ktoś schodzi na dół już poraniony **[decyzja 2026-09-25, MECHANICS §13 pkt 3]**.

## Doświadczenie gracza
Nie ma pasków ani liczb. HUD dopisuje w rogu „ranny” czy „gorączka”, dopiero gdy coś jest nie tak. Ekwipunek opisuje stan zdaniami („Ranny. Rany pieką przy każdym kroku…”). Na krawędzi w tunelach słychać szepty.

## Zasady
1. **Zdrowie 0–100** (start 100), opisane pasmami ✅:

| Pasmo | Próg | Skutek |
|---|---|---|
| cały i zdrowy | ≥ 75 | — |
| poobijany | ≥ 45 | — |
| ranny | ≥ 20 | +1 h na każdy odcinek drogi |
| ciężko ranny | > 0 | jw., a kolejna rana może zabić |

2. **Śmierć** ✅: zdrowie spada do 0 tylko wtedy, gdy bohater był już ranny (poniżej 75). Zdrowy bohater po najgorszym ciosie ma 1. Po śmierci ekran „Nie żyjesz” z przyciskiem „RETRY FROM MORNING” (stan z poranka) albo powrotem do menu.
3. **Rany** ✅:
   - para w Parującej szczelinie przy drugiej żyle (−10),
   - upadek z półki w Ślepym szybie przy świecach (−15).
   Opisane są przy obiektach (`Interactable.wound`).
4. **Gorączka** ✅: po brodzeniu w Zalanym chodniku przychodzi w nocy. Każda noc z gorączką to −12 zdrowia (nie niżej niż 5, we śnie się nie umiera) i −3 poczytalności. Leczy ją lekarstwo.
5. **Leczenie** ✅:
   - bandaże +30 (0,5 h),
   - lekarstwo +15 i koniec gorączki,
   - Anzelm raz dziennie +25 (1 h),
   - Sabina raz dziennie +45 magią (kosztuje ją poczytalność),
   - noc bez gorączki +8.
6. **Poczytalność 0–100** (start 80), pasma ✅: spokojny ≥ 60, niespokojny ≥ 35, na krawędzi > 0, załamany 0. Na krawędzi w tunelach co 40–80 s pojawia się szept albo zjawa w komunikacie.
7. **Co zabiera poczytalność** ✅:
   - pierwsza wizyta w strasznych miejscach (`LocationData.dread`),
   - obiekty (czaszki, chleb dla zmarłych, zarodniki, zabranie świec zmarłym),
   - rozmowy (Hieronim, Ottokar, prawda Anzelma),
   - każda noc −3, powrót po nocy −3, wstrząs w piątą noc −3.
8. **Co ją przywraca** ✅: nalewka +15, świeca +6, pieśń Wszebora +6, kości z Sobkiem +5, opowieść o Długiej Nocy +3, wiersz Hagiwary +4, wieczór przy ognisku z Mirosławem +2.
9. **Winieta** ✅ **[decyzja 2026-09-25, task_06]**: na pasmie „na krawędzi” brzegi ekranu ciemnieją i powoli pulsują (siła 0,3–0,7, im mniej poczytalności, tym mocniej). Znika w rozmowach i na ekranach. Bez drżenia kamery.
10. **Załamanie** ✅ (poczytalność 0): „Uciekasz przed czymś, czego nie ma”. Ktoś przynosi bohatera do obozu, reszta dnia przepada, poczytalność wraca do 20.
11. **Zmęczenie** ✅ **[decyzja 2026-09-26, task_12]**: 0–100%. Rośnie o 8% na godzinę w tunelach (także w drodze) i o 2% na godzinę w obozie. Sen zdejmuje 60%, wieczór przy ognisku 15%. Przy 100% każdy marsz w głąb trwa dwa razy dłużej (powrót do obozu nigdy). Poniżej tylko słowa: od 75% „zmęczony”, od 90% „ledwo idziesz”, przy 100% „padasz z nóg” (róg ekranu, plecak), a mapa dopisuje „zmęczenie ×2”. Nie rusza zdrowia ani poczytalności. Kod: `GameState.player_fatigue`, `FATIGUE_*`, `_tire()`, `Expeditions.walk_hours()`.

## Dane i strojenie
| Parametr | Wartość | Gdzie |
|---|---|---|
| Start | zdrowie 100, poczytalność 80 | `GameState.PLAYER_MAX`, `PLAYER_START_SANITY` |
| Pasma | zob. wyżej | `GameState.health_band()`, `mind_band()` |
| Noc | −3 poczytalności; +8 zdrowia albo gorączka −12 zdrowia, −3 poczytalności | `StoryDirector._resolve_night()` |
| Szepty | co 40–80 s w tunelach, gdy na krawędzi | `StoryDirector.WHISPER_SECONDS` |

## Zależności
[Ekwipunek](ekwipunek.md) (leki), [NPC](npc.md) (Anzelm, Sabina), [Eksploracja](eksploracja_kopalni.md) (zagrożenia), [Czas](czas.md) (noc), [Zapis](zapis_i_opcje.md) (poranek do powtórki).

## Przypadki brzegowe
- Śmierć w trakcie sceny VN → ekran śmierci po zamknięciu rozmowy.
- Załamanie w tunelach → wyprawa się kończy bez podsumowania. Zdarzenie ma swój wpis w notatce wyprawy.
- Gorączka w noc przed rozliczeniem → zakończenie tygodnia i tak następuje.

## Implementacja
✅
- `GameState`:
  - `player_health`, `player_sanity`, `player_fever`,
  - `hurt_player`, `heal_player`, `change_player_sanity`, `set_fever`,
  - sygnały `player_died`, `player_broke`,
- HUD `Condition` w rogu (zegara na HUD nie ma od task_09) i winieta (`Vignette` + `shader/sanity_vignette.gdshader`),
- ekwipunek (opis stanu),
- `StoryDirector` (`_on_player_died`, `_on_player_broke`, szepty),
- `SaveManager.capture_morning()` / `retry_morning()`,
- `ScreenFade.show_end(summary, title, retry)`.

## Otwarte pytania
- ❓ Czy śmierć powinna mieć więcej przyczyn (Drudzy, zawały), czy zostać rzadka?
