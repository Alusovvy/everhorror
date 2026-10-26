# Dialogi (tryb Visual Novel)

> **Materiał referencyjny — nie aktualizować.** Źródło prawdy: specyfikacja (`C:/dev/gamedev/everhorror/specification`, `WORKFLOW.md`).

> Status: 🟢 zaimplementowane (demo) · Właściciel: Roland · Aktualizacja: 2026-09-25 (task_05) · Filary: 2, 3

## Cel
Główny nośnik fabuły, relacji i decyzji. Tryb VN pozwala opowiadać gęsto (monologi, opisy zmysłowe), czego w FPP nie da się zrobić tanio.

## Doświadczenie gracza
Rozmowa jest wyborem z kosztem, a nie przerwą w grze. Gracz widzi, że wcześniejsze decyzje mają znaczenie: inne powitania, nowe opcje, postacie, które pamiętają.

## Zasady
1. **Ekran VN:** rozmyty obraz gry w tle, żywy portret 3D postaci (gestykuluje, kiedy mówi), imię, tekst wpisujący się litera po literze, opcje po prawej, zegar **[GDD]** ✅.
2. **Opcje zależą od reputacji, przedmiotów, flag, poczytalności, pory i miejsca postaci** **[GDD]** ✅. Niespełnione opcje są ukryte, a zawsze jest opcja wyjścia.
3. **VN służy też do narracji bez NPC**: wstęp, sen, pytanie o sen przy posłaniu, poranne ogłoszenie, ściana w kaplicy **[GDD]** ✅. Narracja jest w wyciszonym kolorze.
4. **Efekty opcji:**
   - reputacja i poczytalność ±,
   - przedmioty, notatki, wpisy zadań, flagi,
   - czas (`advance_time`),
   - akcje świata po rozmowie („sleep”, „blast”) ✅.
5. **Koszt rozmowy: 5 minut za każdą wybraną opcję** **[decyzja 2026-09-26, task_09]**. Za darmo: zagadanie, pożegnania (`[#leave]`), proste oddanie przedmiotu (`[#free]`) i opcja wybrana już wcześniej u tej samej osoby (**[decyzja 2026-09-26, factcheck 10]**, pamiętane w zapisie). Opcja z własną ceną (kości 1 h, pompy 2 h, wysadzenie 4 h, ryby 4 h) nie dolicza 5 minut. Sceny fabularne (sny, ogłoszenia, ściana, ognisko, Hrapek) nic nie kosztują ✅.
5a. **Wyszarzone opcje** ✅ **[decyzja 2026-09-26]**: opcja, której brakuje tylko zaufania albo przedmiotu, jest widoczna, szara, z powodem w nawiasie („(potrzebne: lina)”, „(Bolko jeszcze ci nie ufa)”). Opcje na dalszy etap historii zostają ukryte. Przełącznik „Show locked choices” w opcjach, domyślnie włączony.
6. **Mówcy, którzy nie są postacią, mogą mieć statyczny portret** (ściana w kaplicy: świecące znaki sanctinu) ✅.
7. **Gwara śląska górników:**
   - Mirosław i Bolko mówią z elementami gwary, także w scenach innych postaci ✅.
   - Oryginały zostają w plikach `.dialogue`, a wersje śląskie są w `dialogue/gwara_slaska.json` (92 kwestie).
   - Przełącznik jest w opcjach: „Silesian dialect (miners)”.
   - Test pilnuje, żeby każda linia górnika miała wersję śląską.

## Zagadka ściany
Kaplica, [Poziomy](../03_poziomy.md#kaplica-wschód-w-dół). Plik: `dialogue/sciana.dialogue`.
1. Ściana ma trzy wiersze napisu w sanctinie, w każdym brakuje jednego słowa. Pod napisem są trzy kamienne kręgi z sześcioma znakami: gwiazda, oko, płomień, kamień, zamknięte oko (sen), dłoń.
2. **Bez słowniczka Dobrawy** wiersze brzmią jak pseudołacina: „Esar dunem ex ___…”, „Priori, qui non audire…”. **Ze słowniczkiem** gracz widzi tłumaczenie:
   - „Zeszliśmy z ___ i daliśmy wam oczy.” → **gwiazda**
   - „Tych, którzy nie słuchali, oddaliśmy ___.” → **kamień**
   - „Kto zejdzie do nich, niech nie przerywa ich ___.” → **sen**
3. **Podpowiedzi w świecie:**
   - modlitewnik na ołtarzu (postacie z gwiazdami zamiast oczu),
   - Bolko („Pierwsi siedzą w skale”),
   - słowniczek („kamień: także więzienie”),
   - wydrapane obok „NIE BUDZIĆ”,
   - wiadomość dziadka („kawałek Ich snu”),
   - słowo „priori” (tak LoreDoc nazywa Pierwszych).
4. **Błędna próba** kosztuje 1 h, a amulet parzy. Po 2. i 3. próbie bohater przypomina sobie kolejne wskazówki. Można próbować, dopóki starcza godzin.
5. **Po rozwiązaniu**, kiedy gracz zamknie rozmowę:
   - kręgi obracają się na odpowiedzi, a znaki gasną,
   - płyta zjeżdża w posadzkę,
   - w niszy leżą list dziadka i kryształ.

## Dane i strojenie
| Parametr | Wartość | Uwagi |
|---|---|---|
| Koszt rozmowy | 1 h | zob. [Czas](czas.md#dane-i-strojenie) |
| Tempo tekstu | tempo Dialogue Manager, pomijalne kliknięciem lub [Spacja] | |
| Pliki dialogów | `dialogue/*.dialogue`: miroslaw, bolko, racibor, tekla, dobrawa, wszebor, nasir, hagiwara, sobek, anzelm, sabina, ottokar, hieronim, welf, drudzy (spotkanie z Exitium), sciana, system (wstęp, sny, poranki, zakończenia) | edycja w zakładce Dialogue edytora |

## Zależności
[NPC](npc.md) (reputacja, poczytalność, miejsce), [Czas](czas.md), [Questy](questy.md), [Ekwipunek](ekwipunek.md), stan gry (flagi).

## Przypadki brzegowe
- Brak dostępnych opcji → zawsze istnieje opcja wyjścia.
- Dialog prosi o akcję świata (sen, wybuch) → wykonuje się dopiero po zamknięciu rozmowy.
- Zmiana godziny w trakcie rozmowy → postacie przechodzą na nowe miejsca dopiero po jej zamknięciu.

## Implementacja
✅
- wtyczka **Dialogue Manager 4.1** (pliki `.dialogue`, `using GameState`),
- własny ekran `scene/vn/vn_balloon.tscn` (portret 3D w osobnym świecie i statyczne portrety),
- autoload `VN` (`start()`, `play()`, sygnały `started` i `finished`),
- gwara jako tłumaczenie Dialogue Managera (`Settings`).

Stary prototyp `visual_interaction.tscn` nie jest używany.

## Otwarte pytania
- ✅ Wtyczka czy własny system? Wtyczka Dialogue Manager.
- ✅ Portrety: rendery postaci 3D (bez ilustracji 2D).
- ✅ ~~Czy są wybory z ograniczonym czasem na odpowiedź?~~ Zespół (2026-09-26): nie.
