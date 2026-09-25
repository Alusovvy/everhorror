# Eksploracja kopalni

> Status: 🟢 zaimplementowane (demo, 15 miejsc) · Właściciel: Roland · Aktualizacja: 2026-09-25 (task_05) · Filary: 1, 3 · Źródło: GDD §1, §4

## Cel
Dać graczowi poczucie schodzenia w nieznane: każde nowe miejsce to nowa wiedza, zasoby i ryzyko, a dojście tam kosztuje czas. Do tego zlecenie, które nie daje spać: dwanaście żył do wieczora siódmego dnia.

## Doświadczenie gracza
Rano przy stole z mapą planujesz trasę. W chodnikach mapa [M] pyta „Dokąd dalej?” i pokazuje godziny. Wieczorem wracasz z podsumowaniem wyprawy i patrzysz, czy norma rośnie szybciej niż dni ubywają.

## Zasady
1. **Struktura:** kopalnia → jaskinie → Świątynia Onych **[GDD]**. W demie graf 15 miejsc w czterech poziomach głębokości (zob. [Poziomy](../03_poziomy.md#miejsca-wypraw-demo)).
2. **Graf miejsc** ✅: miejsca łączą się krawędziami z czasem drogi (`LocationData.links`, generator `write_world_data.js`). Obóz to węzeł `oboz`.
3. **Stół z mapą w obozie** **[GDD]** ✅:
   - lista znanych miejsc, dla każdego droga, rozpoznanie, „nowe” albo „żyły 1/2”,
   - rysunek grafu i trasa czerwonym atramentem,
   - licznik żył wobec normy,
   - przycisk **WYRUSZ** („Onward”). Gracz idzie najkrótszą drogą przez miejsca, które są teraz otwarte. Bez liny do galerii prowadzi droga przez pompy, a nie przez Ślepy szyb. Po śmierci Mirosława do kuźni i szybu da się zejść tylko od dołu, przez galerię. Jeśli każda droga jest zamknięta, mapa podaje, co stoi po drodze.
4. **Mapa w terenie [M]** ✅ (także drogowskaz przy wejściu do każdego miejsca):
   - sąsiednie miejsca („IDŹ DALEJ”) i powrót do obozu najkrótszą otwartą drogą („WRACAJ DO OBOZU”),
   - „ZOSTAŃ TUTAJ” zamyka mapę,
   - w obozie [M] podpowiada, że wyprawy planuje się przy stole.
5. **Znane miejsca** ✅: widać te, które graniczą z obozem albo z odwiedzonym miejscem, i te, o których ktoś opowiedział (spełniony warunek `flag:`). Zablokowane mają powód („Bez liny nie zejdziesz”), a nieznane mogą mieć nazwę zastępczą („Znak zapytania”, „Przekreślona gwiazda”).
6. **Koszt drogi** ✅:
   - suma krawędzi,
   - +1 h rozpoznania przy pierwszej wizycie,
   - +1 h na odcinek, gdy bohater jest ranny,
   - powrót zawsze możliwy, także po 22:00.
7. **Podsumowanie wyprawy** ✅ po powrocie:
   - godziny wyjścia i powrotu, odwiedzone miejsca,
   - nowe żyły i stan normy,
   - przyniesione rzeczy, zdarzenia (np. spotkanie z Drugimi, uratowany Welf, skrytka Grabca),
   - stan bohatera i jedno zdanie komentarza.
8. **Warunki dostępu** ✅: flaga (zawał wysadzony, kaplica odkryta, pompy uruchomione), przedmiot (lina, olej), a po śmierci Mirosława zachodni chodnik zamyka się na zawsze (`noflag:mir_dead`).
9. **Zagadki:** proste, logiczne **[GDD]**. Szyfr dziadka, ściana w kaplicy ✅.
10. **Znaleziska** ✅: błękitne żelazo, notatki poprzedniej ekipy (zeszyt Grabca), przedmioty (zob. [Ekwipunek](ekwipunek.md)).
11. **Zagrożenia** ✅: para w szczelinie, upadek z półki w ślepym szybie (rany), lodowata woda w zalanym chodniku (gorączka w nocy), kostnica i grota (poczytalność). Zob. [Zdrowie i poczytalność](zdrowie_i_poczytalnosc.md).
12. **Spotkania** ✅: górnicy przy pracy i Drudzy z Exitium (zob. [NPC](npc.md#zasady), pkt 8).

## Złoża i norma
1. **25 żył** w 15 miejscach (1–3 na miejsce) ✅. Każda to świecąca skała z „[E] Zaznacz żyłę na mapie · 1 h”. Po zaznaczeniu pojawia się palik, a na rysunku mapy niebieska kreska.
2. **Żyły pod naciekiem** ✅: w rząpiu, upadowej i kaplicy druga żyła jest pod białym naciekiem. Odkucie i zaznaczenie wymaga kilofa i trwa 2 h.
3. **Norma Kniazia:** 12 żył do wieczora dnia 7 ✅. Licznik widać na mapie, w ekwipunku, w notesie przy zadaniu „Złoża dla Kniazia” i w podsumowaniu wyprawy. Po każdej żyle pojawia się komunikat.
4. **Upomnienia** ✅: rano w dniach 4–7, gdy żył jest za mało, Racibor upomina gracza przy śniadaniu, coraz ostrzej, i traci do niego trochę zaufania **[decyzja 2026-09-25, MECHANICS §13 pkt 2]**.
5. **Rozliczenie** ✅ rano w dniu 8:
   - norma zrobiona: Racibor liczy kreski i gracz zostaje,
   - normy nie ma: wyprawa wyjeżdża bez gracza, który zostaje sam w kopalni („Zostałeś sam”) **[decyzja 2026-09-25, MECHANICS §13 pkt 2]**.
6. **Na skróty** ✅: Ottokar zaznacza graczowi żyły za kryształ (2) albo za mapy dziadka (1). Hagiwara nie dopisze żył do księgi.

## Dane i strojenie
| Parametr | Wartość | Gdzie |
|---|---|---|
| Miejsca | 15 (5 z task_04 + 10 z task_05) | `data/locations/*.tres` |
| Żyły | 25, norma 12 | `LocationData.veins`, `GameState.QUOTA` |
| Drogi | obóz → sztolnia / zachodni / rząpie 2 h; dalej 1–1,5 h | `write_world_data.js` (`EDGES`) |
| Rozpoznanie | +1 h przy pierwszej wizycie | `Expeditions.SCOUTING_HOURS` |
| Znaczenie żyły | 1 h (pod naciekiem 2 h, kilof) | generatory lokacji |
| Grozy miejsc (pierwsza wizyta) | upadowa 3, szyb 3, grota 4, galeria 6, kostnica 8, szczelina 2 | `LocationData.dread` |

## Zależności
[Czas](czas.md), [NPC](npc.md) (pomoc, role, spotkania), [Ekwipunek](ekwipunek.md) (klucze), [Zdrowie i poczytalność](zdrowie_i_poczytalnosc.md), [Interakcje](interakcje.md), [Poziomy](../03_poziomy.md).

## Przypadki brzegowe
- Jedyna droga dalej wymaga NPC, który nie żyje → np. po śmierci Mirosława galeria jest dostępna już tylko przez pompy i zalany chodnik.
- Bohater jest w miejscu wyprawy po 22:00 → dalej iść nie może, powrót zawsze.
- Bohater się załamie w tunelach → ktoś go przynosi do obozu, dzień przepada, wyprawa się kończy.
- Wyprawa trwa, a gracz zapisze grę → wyprawa jest w zapisie (`GameState.expedition`).

## Implementacja
✅
- `LocationData` + `Expeditions` (graf, najkrótsza otwarta droga, znane i zablokowane miejsca, koszt),
- `MapScreen` (tryby TABLE i FIELD, akcja `field_map` = M),
- `map_drawing.gd` (rysunek grafu),
- `ExpeditionSummary`,
- `StoryDirector` (`_arrive`, `_return_to_camp`, spotkania),
- miejsca w `scene/levels/locations.tscn` (generator `gen_locations.gd`), Stara sztolnia w `mine_deep.tscn` (`gen_mine_deep.gd`), zachodni chodnik w `camp.tscn` (`gen_camp.gd`).

## Otwarte pytania
- ❓ Czy miejsca zmieniają się między wizytami (np. wstrząs w piątą noc mógłby zasypać drogę)?
- ❓ Wydobycie w pełnej grze: kto kopie odnalezione złoża i jak gracz to widzi?
- ❓ Czy norma ma rosnąć z tygodnia na tydzień?
