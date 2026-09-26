# Questy i notes

> Status: 🟢 zaimplementowane (demo) · Właściciel: Roland · Aktualizacja: 2026-09-25 (task_05) · Filary: 1, 2, 3

## Cel
Dać graczowi pamięć tego, co obiecał, co wie i co mu ucieka, bez prowadzenia za rękę.

## Zasady
1. **Prosty notes z zapiskami questów** **[GDD]**, pod klawiszem **[J]** ✅. Ma zakładki *Zadania*, *Notatki* i *Ludzie*.
2. Wpis zawiera: tytuł, zleceniodawcę, stan (*aktywny / zakończony / nieudany*) i kolejne notatki dopisywane w miarę postępu ✅. Pod „Złożami dla Kniazia” jest bieżący stan normy i termin ✅.
3. Notes pisze bohater w pierwszej osobie, w tonie świata („Racibor chce wiedzieć, gdzie jest błękit…”) ✅.
4. W notesie są też **znalezione dokumenty**: notatka dowódcy, szyfr, klucz, odszyfrowana wiadomość, odpis z archiwum, list Konfraterni, słowniczek sanctinu, list dziadka, zeszyt sztygara Grabca, wiersz Hagiwary ✅.
5. Questy NPC nagradzają informacją, przedmiotem albo reputacją **[GDD]** ✅.
6. Linie questów prowadzą do złożonych zakończeń (np. Drudzy na dnie kopalni) **[GDD]**. W demie są ich zaczątki: kryształ dla Dobrawy albo dla Racibora.
7. **Zakładka „Ludzie”** ✅: poznane postacie z rolą i trzema zdaniami: zdrowie, głowa, stosunek do bohatera. Bez liczb **[decyzja 2026-09-25, MECHANICS §13 pkt 4]**.

## Questy w demie
| Quest | Zleceniodawca | Przebieg | Nagroda |
|---|---|---|---|
| **Ślady dziadka** | ja | szyfr → wskazówka Bolka → klucz → odszyfrowanie w nocy → raport z archiwum, proch od Hanusza, zawał od ładunku → list w kaplicy | prawda o dziadku |
| **Lonty dla Mirosława** | Mirosław | lonty ze Starej sztolni → wysadzenie zachodniego zawału | otwarty zachodni chodnik |
| **Złoża dla Kniazia** | Racibor | pierwsze 2 żyły → raport i odpis z archiwum; potem norma: 12 żył do wieczora dnia 7, upomnienia rano w dniach 4–7, rozliczenie rano w dniu 8 | odpis raportu sprzed 40 lat, zostajesz w ekspedycji albo zostajesz sam w kopalni |
| **Tobołek Tekli** | Tekla | tobołek z rząpia → oddać Tekli albo wydać Raciborowi | lina i historia ojca albo reputacja u Racibora |
| **Ściana w kaplicy** | Dobrawa | kaplica i słowniczek → zagadka → kryształ: Dobrawie, Raciborowi, Ottokarowi albo zatrzymać | wiedza. Skutek zależy od tego, komu gracz odda kryształ |
| **Kilof dla przewodnika** | Wszebor | obuch ze starego wyrobiska → Wszebor → kilof następnego dnia | kilof (żyły pod naciekiem) |
| **Pompy Nasira** | Nasir | olej do tłoków → następnego dnia za dnia pomoc przy korbie w komorze pomp (2 h) | zalany chodnik dostępny |
| **Gorączka Nasira** | Anzelm | od dnia 4 Nasir ma gorączkę → lekarstwo (Tekla, Hagiwara, Anzelm z grzyba, Sabina, Welf) → Nasir; bez leku wywożą go na górę | Daleki Klejnot, reputacja |
| **Wiersz o świetle** | Hagiwara | świecący grzyb z groty → Hagiwara | wiersz (notatka), lekarstwo |
| **Zakład z Sobkiem** | Sobek | 3 nowe żyły do jutra wieczora | nalewka albo śmiech Sobka |
| **Brat i czarownica** | Anzelm i Sabina | Anzelm o Sabinie → obietnica Sabiny → zgoda Anzelma | Sabina pomaga przy chorych, spokój w obozie |
| **Oferta z Exitium** | Ottokar | kryształ (2 żyły) albo mapy dziadka (1 żyła), albo odmowa | żyły na mapie; odmowa kosztuje poczytalność |
| **Odłamek dla Sabiny** | Sabina | odłamek z Kryształowej galerii → Sabina | lekarstwo, zaufanie |
| **Czternaście kresek** [ROBOCZE] | ja | kreski (rząpie, filar w wyrobisku) albo zeszyt Grabca zaczynają zapiski → chleb, lampka, pusta nisza, medalik po wstrząsie dopisują się → przy ≥ 4 śladach, od 5. nocy, ktoś zostawia przy posłaniu starą lampę przewodnika | lampa, wiersz w zakończeniach; demo nie mówi, kim jest Czternasty |
| **Ryba dla Hrapka** | Hrapek | pierwsze spotkanie z Hrapkiem → ryba od Tekli (po oddanym tobołku) albo 4 h łowienia ze Wszeborem lub Mirosławem w stawie w Zalanym chodniku → Hrapek, przed jego śmiercią w nocy 5→6 | informacje o NIM i o dziadku, zaufanie Hrapka |

Dane: `data/quests/*.tres` i `data/notes/*.tres`, generowane przez `tools/generators/write_story_data.js`.

## Zależności
[NPC](npc.md), [Czas](czas.md) (terminy), [Dialogi](dialogi_vn.md) (efekty: start, wpis, zakończenie), [Fabuła](../swiat/fabula.md).

## Przypadki brzegowe
- Coś zrobione przed przyjęciem zadania (np. żyła zaznaczona przed rozmową z Raciborem) → wpis dopisuje się przy przyjęciu zadania ✅.
- Zleceniodawca ginie albo odchodzi → wpis w notesie (Nasir wywieziony: „Nie zdążyłem”) ✅.
- Termin normy mija → rozliczenie rano w dniu 8, zob. [Eksploracja](eksploracja_kopalni.md#złoża-i-norma) ✅.
- Zakład z Sobkiem przegrany → quest „nieudany” ✅.

## Implementacja
✅
- `QuestData` i `NoteData` (`Resource`),
- stan w `GameState` (`start_quest`, `quest_log`, `complete_quest`, `fail_quest`, `add_note`),
- ekran `scene/ui/notebook.tscn` pod [J],
- komunikaty w HUD o nowych wpisach i notatkach.

## Otwarte pytania
- ❓ Czy zakładka „Ludzie” ma pokazywać też krótką historię postaci, gdy gracz ją pozna z rozmów?
