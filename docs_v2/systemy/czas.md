# Upływ czasu

> Status: 🟢 zaimplementowane (demo, tydzień) · Właściciel: Roland · Aktualizacja: 2026-09-25 (task_05) · Filary: 1 (Czas to waluta)

## Cel
Sprawić, by każda decyzja miała koszt. Gracz nie zdąży zrobić wszystkiego, więc musi wybierać między rozmową, wyprawą, leczeniem a snem.

## Doświadczenie gracza
Spokojna eksploracja bez stopera, ale z ciągłą świadomością, że *ta rozmowa* odbierze czas na *tamtą wyprawę*. Presja rośnie z dnia na dzień, bo do wieczora siódmego dnia Kniaź chce dwunastu żył.

## Zasady
1. **Czas płynie tylko po akcjach, nie w czasie rzeczywistym.** **[GDD]** ✅
2. **Koszty akcji** **[GDD]**:

| Akcja | Kosztuje czas? |
|---|---|
| Chodzenie po obozie i po miejscu wyprawy | nie |
| Rozmowa z NPC | **tak: 5 minut za każdą wybraną opcję**; zagadać, pożegnać się i oddać przedmiot — za darmo **[decyzja 2026-09-26, task_09]** |
| Podróż do miejsca, dalej przez [M] i z powrotem | **tak** |
| Pierwsze rozpoznanie nowego miejsca | **tak** |
| Badanie niektórych rzeczy, znaczenie żył | **czasami** |
| Użycie przedmiotu (bandaże, świeca) | **czasami** |
| Pomoc NPC (wysadzenie, praca przy pompach, opatrywanie) | **tak, dużo** |
| Sen | **tak**, kończy dzień |

3. **Dzień ma budżet 16 godzin** (06:00–22:00). ✅ Gdy godzin brakuje, dalsze wyprawy i znaczenie żył są niedostępne z podpowiedzią „(za późno)”. Rozmowę można zacząć zawsze; jej koszt widać w zegarze okna rozmowy i w dymku po jej zamknięciu.
4. **Gracz zawsze wraca na noc do obozu**, ale może przy tym zmarnować dużo czasu **[decyzja 2026-09-25, MECHANICS §13 pkt 8]**. ✅ Powrót jest możliwy nawet po 22:00, kosztuje wtedy trochę poczytalności.
5. **Koszt jest widoczny przed akcją** („[E] Zaznacz żyłę na mapie · 1 h”, na mapie: droga, rozpoznanie i godzina przybycia), a przy rozmowach zegar w oknie VN przesuwa się o 5 minut przy każdej opcji, a po rozmowie jeden dymek podaje sumę („−15 min · Rozmowa z Teklą”). ✅ **[decyzja 2026-09-26]**
6. **Tydzień.** ✅ Gra trwa 7 dni. Rano ósmego dnia Racibor liczy żyły ([Eksploracja](eksploracja_kopalni.md#złoża-i-norma)):
   - co najmniej 12 żył: zakończenie „Koniec tygodnia”,
   - mniej: wyprawa wyjeżdża bez gracza, a on zostaje sam w kopalni („Zostałeś sam”) **[decyzja 2026-09-25, MECHANICS §13 pkt 2]**.
7. **Sen uruchamia rozliczenie nocy** ✅:
   - poczytalność NPC (zob. [NPC](npc.md#dane-i-strojenie)),
   - gorączka Nasira od trzeciej nocy,
   - odejścia (Dobrawa z kryształem albo na dno, Nasir wywieziony na górę, Mirosław przy zerze),
   - wstrząs w piątą noc,
   - stan bohatera: −3 poczytalności co noc, odpoczynek +8 zdrowia albo gorączka −12 zdrowia (zob. [Zdrowie i poczytalność](zdrowie_i_poczytalnosc.md)),
   - odszyfrowanie wiadomości dziadka, jeśli gracz ma szyfr i klucz,
   - podarunek „Czternastego” (od 5. nocy, przy ≥ 4 śladach questu): lampa przy posłaniu,
   - sen bohatera: inny w noce 1, 2, 3–4, 5–6 i 7, a w gorączce z dodatkiem.
8. **Poranki** ✅:
   - plansza z nowiną nocy („Nasir kaszle od świtu”, „W nocy ziemia drżała”),
   - zapis stanu poranka (do „spróbuj od rana” po śmierci),
   - w dniu 3 ogłoszenie Racibora,
   - w dniach 4–7 upomnienie, jeśli norma się spóźnia.
9. **Rytm dnia w obozie** ✅: rano (do 8:00) śniadanie, 8–18 praca, 18–20 kolacja, potem wieczór. Od 20:00 przy ognisku scena zbiorowa „Usiądź przy ogniu” (1 h, raz dziennie, treść wg dnia; task_06). Postacie zmieniają miejsca, gdy mija pora (zob. [NPC](npc.md#rozkład-dnia)).

## Dane i strojenie
| Parametr | Wartość | Gdzie |
|---|---|---|
| Godziny w dniu | 16 (06:00–22:00) | `GameState.DAY_START_HOUR`, `DAY_LENGTH_HOURS` |
| Rozmowa z NPC | 5 min za opcję; darmowe pożegnania (`[#leave]`) i oddanie przedmiotu (`[#free]`); opcja z własną ceną nie dolicza 5 min | `VN.TALK_MINUTES` |
| Podróż | wg grafu miejsc: 2 h obóz ↔ sąsiednie, 1–1,5 h dalej | `data/locations/*.tres` (`links`) |
| Rozpoznanie nowego miejsca | +1 h | `Expeditions.SCOUTING_HOURS` |
| Ciężko ranny / ranny | +1 h na każdy odcinek drogi | `Expeditions.WOUNDED_EXTRA_HOURS` |
| Wysadzenie zawału | 4 h | `StoryDirector.BLAST_HOURS` |
| Zaznaczenie żyły / żyły pod naciekiem | 1 h / 2 h | `Interactable.time_cost_hours` |
| Praca przy pompach z Nasirem | 2 h | `dialogue/nasir.dialogue` |
| Opatrywanie u Anzelma, kości z Sobkiem | 1 h | dialogi |
| Bandaże, świeca | 0,5 h | `data/items/*.tres` (`use_hours`) |
| Błędna próba przy ścianie w kaplicy | 1 h | `dialogue/sciana.dialogue` |
| Termin normy / koniec gry | wieczór dnia 7 / rano dnia 8 | `GameState.QUOTA_DAY`, `LAST_DAY` |
| Upomnienie Racibora | rano w dniach 4–7, gdy żył mniej niż ⌊12·(dzień−1)/7⌋−1, i zawsze w dniu 7 bez normy | `StoryDirector._quota_lags()` |

## Zależności
- **[NPC](npc.md)**: rozliczenie nocy, rozkład dnia.
- **[Eksploracja](eksploracja_kopalni.md)**: koszty podróży, norma.
- **[Zdrowie i poczytalność](zdrowie_i_poczytalnosc.md)**: noc leczy albo pogarsza.
- **[Interakcje](interakcje.md)**: pole `time_cost_hours` w obiektach.
- **[Zapis](zapis_i_opcje.md)**: dzień i godzina są częścią zapisu, poranek jest zapamiętywany.

## Przypadki brzegowe
- Akcja kosztuje więcej, niż zostało w dniu → niedostępna, podpowiedź „(za późno)”, komunikat „Już za późno. Pora odpocząć.” ✅
- Wyprawa kończy się po 22:00 → powrót i tak jest możliwy, a następnego dnia start o 6:00 ✅.
- Bohater się załamie (poczytalność 0) → reszta dnia przepada, budzi się rano na posłaniu ✅.
- Zapis w nocy albo w trakcie sceny VN → zapis tylko w FPP (pauza nie działa w VN) ✅.

## Implementacja
✅
- autoload `GameState` (`day`, `hour`, `advance_time()`, `can_afford()`, `part_of_day()`, `days_to_deadline()`, sygnał `time_advanced`),
- zegar w notesie (zakładka „Czas” z dziennikiem dni: `GameState.time_log`, zapis v4) i w oknie VN; w rogu ekranu zegara nie ma **[decyzja 2026-09-26, task_09]**,
- rozliczenie nocy i poranki w `StoryDirector` (`_resolve_night()`, `_morning_events()`, `_week_end()`),
- rytm dnia w `CampSchedule`.

## Otwarte pytania
- ✅ ~~Czas w świecie?~~ Zespół (2026-09-26): zegar w notesie zamiast w rogu i dziennik czasu. Zrobione w task_09.
- ✅ ~~Czy po tygodniu gra trwa dalej?~~ Zespół (2026-09-26): demo kończy się na podsumowaniu.
