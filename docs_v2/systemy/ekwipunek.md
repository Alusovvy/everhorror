# Ekwipunek

> Status: 🟢 zaimplementowane (demo) · Właściciel: Roland · Aktualizacja: 2026-09-25 (task_05) · Filary: 1

## Cel
Przedmioty jako decyzje. Lekarstwo dla chorego towarzysza czy dla siebie? Olej do pompy czy do lampy na najgłębszą wyprawę? Kryształ dla Drugiej, dla zarządcy czy za dwie żyły od Ottokara?

## Doświadczenie gracza
Plecak otwierany pod [I]:
- lista rzeczy i ich opisy,
- „UŻYJ” przy lekach i świecach,
- na górze słowny stan bohatera („Poobijany… Niespokojny…”) i postęp normy.

Przedmioty rzadko są „do wszystkiego”. Każdy ma zwykle jednego, dwóch chętnych.

## Zasady
1. **Przedmioty to dane** ✅: `ItemData` (`data/items/*.tres`, generator `tools/generators/write_world_data.js`) z nazwą, opisem, kategorią (narzędzie, lek, zapasy, sprawa, cenne) i działaniem (`heal`, `sanity`, `cures_fever`, `consumable`, `use_hours`, `use_text`).
2. **Ekran [I]** ✅: modalny jak notes. Pokazuje stan bohatera słowami, bez liczb, oraz postęp normy **[decyzja 2026-09-25, MECHANICS §13 pkt 4]**. „UŻYJ” jest tylko przy rzeczach, które działają na bohatera. Kiedy użycie nic nie da („Teraz ci to niepotrzebne”), przycisk jest wyłączony.
3. **Bez limitu miejsc** w demie [decyzja agenta, task_05, pytanie MECHANICS §13 pkt 7 nadal otwarte].
4. **Przedmioty dla NPC** ✅: daje się je w dialogu („Mam dla ciebie lekarstwo”, „Napij się. To na nerwy”). Leki działają na NPC tak samo jak na bohatera (`GameState.give_to_npc`). Ten sam przedmiot może pomóc tobie albo komuś (lekarstwo: Nasir albo twoja gorączka; nalewka: Mirosław albo twoja głowa; bandaże: Welf albo twoje rany).
5. **Przedmioty są kluczami** ✅:
   - do miejsc na mapie (`item:` w wymaganiach: lina do upadowej i ślepego szybu, olej do Kryształowej galerii),
   - do obiektów (`Interactable.required_item`, np. łom do skrzyni i skrytki, kilof do żył pod naciekiem),
   - do rozmów (warunek `has_item` w opcjach).
6. **Zużycie** ✅: leki, świece i nalewka znikają po użyciu, narzędzia (lina, łom, kilof) nie. Olej oddany Nasirowi przepada.
7. **Amulet dziadka** jest zawsze przy bohaterze **[GDD]** ✅. Na liście jako „cenne”, bez działania mechanicznego. Grzeje się, parzy i stygnie w tekstach.

## Przedmioty w demie
| Przedmiot | Skąd | Do czego |
|---|---|---|
| Amulet dziadka | od początku | fabularnie |
| Suche lonty | skrzynka w Starej sztolni | Mirosław wysadzi zawał |
| Kwit od Racibora | zadanie „Złoża dla Kniazia” | Tekla wyda za niego linę |
| Lina | Tekla (za kwit albo tobołek), Racibor (po donosie) | upadowa, ślepy szyb |
| Tobołek Tekli | rząpie | Tekli albo Raciborowi |
| Kryształ z kaplicy | nisza za ścianą | Dobrawie, Raciborowi, Ottokarowi (za 2 żyły) albo zatrzymać |
| Bandaże | Anzelm (1 dziennie), skrzynia w jaskini (łom), Hieronim | +30 zdrowia (0,5 h); ranny Welf |
| Lekarstwo | Tekla (raz: za dług albo wymianę), Hagiwara (za grzyb), Anzelm (warzy z grzyba do rana), Sabina (za odłamek), Welf (dług) | zbija gorączkę, +15 zdrowia; Nasir |
| Nalewka | Wszebor, kuźnia, skrzynia w jaskini, zakład z Sobkiem | +15 poczytalności; Mirosław |
| Świeca | Tekla (1 dziennie), kostnica, ślepy szyb (upadek z półki), Hieronim, skrzynia | +6 poczytalności (0,5 h) |
| Olej do lampy | komora pomp, skrytka Grabca (łom), Tekla (raz, za dług albo zaufanie) | Kryształowa galeria; pompy Nasira |
| Łom | kuźnia starej ekipy | skrzynia z zapasami w jaskini, skrytka w Przekopie Grabca |
| Obuch kilofa | stare wyrobisko | Wszebor zrobi z niego kilof (do rana) |
| Kilof | Wszebor | żyły pod naciekiem (rząpie, upadowa, kaplica) |
| Świecący grzyb | grota (2 sztuki) | Hagiwara (wiersz i lekarstwo) albo Anzelm (lekarstwo) |
| Odłamek błękitu | Kryształowa galeria | Sabina (lekarstwo, jej zaufanie) |
| Daleki Klejnot | Nasir po wyleczeniu | wymiana u Tekli na lekarstwo |

## Dane i strojenie
| Parametr | Wartość | Gdzie |
|---|---|---|
| Bandaże / lekarstwo / nalewka / świeca | +30 zdrowia / +15 zdrowia i koniec gorączki / +15 poczytalności / +6 poczytalności | `data/items/*.tres` |
| Czas użycia | bandaże i świeca 0,5 h, reszta 0 | `use_hours` |
| Limit ekwipunku | brak | — |

## Zależności
[Zdrowie i poczytalność](zdrowie_i_poczytalnosc.md), [Eksploracja](eksploracja_kopalni.md) (klucze do miejsc), [NPC](npc.md), [Questy](questy.md), [Dialogi](dialogi_vn.md) (warunek: posiadany przedmiot), [Zapis](zapis_i_opcje.md).

## Implementacja
✅
- `ItemData`, `GameState` (`ITEMS`, `give_item`, `take_item`, `use_item`, `item_use_blocker`, `give_to_npc`),
- `InventoryScreen` (`scene/ui/inventory.tscn`, akcja `inventory` = I),
- `Interactable.required_item` / `consume_item` / `missing_text` i wiele przedmiotów z jednego znaleziska (`on_use_item = "bandaze:2,swieca"`),
- znalezione przedmioty trafiają do podsumowania wyprawy.

## Otwarte pytania
- ❓ Limit ekwipunku i wybór rzeczy przed wyprawą **[GDD]** (paliwo do lampy jako zasób wyprawy). W demie olej jest tylko kluczem.
- ❓ Czy amulet ma działanie mechaniczne (sny, wizje, podpowiedzi przy zagadkach)?
