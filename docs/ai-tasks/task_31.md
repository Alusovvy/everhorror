<!--
Zadanie ze specyfikacji (spec-tasks, 2026-10-27). Wymagania to cytat zasad ze specyfikacji w commicie 67b762e; nie edytować.
-->

# task_31: Żyły jako bryły rudy i tyle świecących skał, ile żył

Wymagania:
1. ZYL-12 (03_mechaniki/zyly_i_norma.md) ⬜: „**[ROBOCZE]** Żyła wygląda jak ruda: okrągłe, wypukłe bryły błękitnego żelaza wrośnięte w ścianę (kilka brył różnej wielkości w jednym skupisku, część przysłonięta skałą), a nie cienkie świecące linie namalowane na skale (Roland, playtest 2026-10-27: „Żyła błękitnego żelaza to cienka tekstura, zróbmy to ładnie, okrągłe w kształcie rudy na ścianie, a nie takie cienkie teksturki, bo to brzydko z boku wygląda”). Bryły świecą i pulsują błękitem jak dziś (ZYL-2, [oprawa](../06_oprawa.md#kierunek-wizualny)) i dobrze wyglądają także z boku. Kształt brył rudy ma **tylko** żyła do zaznaczenia (albo żyła za naciekiem z ZYL-3, przebłyskująca spod nacieku): w każdym miejscu liczba skupisk brył = liczba żył z [miejsc](../04_tresc/miejsca.md) ([zgłoszenie o nadmiarze świecących skał](../zgloszenia/2026-10-27_zyly-za-duzo-swiecacych-skal.md)). Ozdobne światło błękitu, np. „ściany z błękitu” Kryształowej galerii, świeci równo i słabiej, bez brył, więc nie da się go wziąć za żyłę; urobek w wózkach w obozie może mieć bryły, bo leży w wózku, a nie na ścianie. Po zaznaczeniu bryły zostają, a palik stoi obok (ZYL-2). Dziś żyłę rysuje nakładka `shader/blue_iron_vein.gdshader` (pasy szerokości `vein_width = 0.13` w przestrzeni świata) na całych skałach z paczki (`script/overlay_applier.gd`). **Dla agenta:** bryły jako siatka z generatora (np. spłaszczone, nieregularne kule z `mesh()` / `glow_material()` w `tools/generators/gen_locations.gd`, które już robią kryształy w Galerii), wspólna funkcja dla `vein()`, `hidden_vein()` i skał w grupach `Vein` (`gen_locations.gd`), `BlueIronVeins` (`gen_mine_deep.gd`), `blue_ore()` (`gen_camp.gd`, żyła `west_1` i `CartOre`); podświetlenie [E] (`highlight_target`) na bryłach; sceny regenerować, nie edytować. Test strukturalny jak w task_16 (`tools/tests/test_expedition.gd`): liczba skupisk brył w miejscu = `LocationData.veins.size()`. Wygląd ocenia człowiek w arkuszu, także z boku.
  - Roland, czat 2026-10-27: „ściany z błękitu” w Kryształowej galerii zostają jako równa poświata bez brył — „Tak”.”
2. Oprawa, kierunek wizualny (06_oprawa.md) ⬜: „**[ROBOCZE]** **Żyły błękitu** to okrągłe, wypukłe bryły rudy wrośnięte w ścianę, które świecą i pulsują błękitem, a nie cienkie świecące linie na skale (Roland, playtest 2026-10-27; zasada: [ZYL-12](03_mechaniki/zyly_i_norma.md)). Kształt brył ma tylko żyła do zaznaczenia; ozdobny błękit (ściany Galerii) świeci równo, bez brył.”
3. Zgłoszenie zgloszenia/2026-10-27_zyly-za-duzo-swiecacych-skal.md (błąd), „Co”: „Roland, czat 2026-10-27: „W Upadowej są 4 żyły widoczne, ale tylko jedną można oznaczyć, a jest jeszcze jedna, co wymaga kilofa. No to powinny być 2, a nie 5 tekstur w sumie. Zweryfikuj, czy w innych pomieszczeniach nie ma tego problemu, i to jest do poprawy.”

To ten sam błąd, który task_16 naprawił w Starej sztolni: generator nakłada świecenie żyły na skały, przy których nie ma czego zaznaczyć.”

Źródło: specyfikacja `67b762e` · ID: ZYL-12 (oraz ZYL-1, ZYL-2, ZYL-3 ✅), oprawa (żyły błękitu), miejsca `upadowa`, `rzapie`, `kaplica`, `galeria` · Zgłoszenia: zgloszenia/2026-10-27_zyly-za-duzo-swiecacych-skal.md
Poziom: rozgrywka

Priorytet: do ustalenia (uwagi z playtestu 2026-10-27, poza kolejką „Czeka na wdrożenie”; zgłoszenie błędu, więc agent proponuje wysoki) · Kolejność: po task_25 (arkusz sprawdza żyły na ZIP-ie z poprawką eksportu); rozbłysk z task_26 (ZYL-9) powinien działać na nowych bryłach

---
<!-- ↓↓↓ Sekcje poniżej wypełnia agent ↓↓↓ -->

## Analiza wstępna
Zgłoszenie i ZYL-12 dotykają tych samych funkcji generatorów, więc jedno zadanie (rekomendacja w „Odpowiedzi agenta” zgłoszenia).

**Systemy i pliki:** `tools/generators/gen_locations.gd` (`vein_group()`, `vein()`, `hidden_vein()`, grupy `Vein` w Upadowej `:482–483`, Rząpiu `:400`, Kaplicy `:535`, `BlueWalls` w Galerii `:1065–1068`), `tools/generators/gen_mine_deep.gd` (`BlueIronVeins`, poprawione w task_16), `tools/generators/gen_camp.gd` (`blue_ore()`, `west_1` `:578–585`, `CartOre` `:434`), `shader/blue_iron_vein.gdshader`, `script/overlay_applier.gd`, `script/interactable.gd` (`highlight_target`). Sceny `locations`, `mine_deep`, `camp` są generowane: zmiana generatora i regeneracja, `--import` po zmianie.

**Kierunek:** jedna funkcja „skupisko brył rudy” (kilka spłaszczonych, nieregularnych kul z `glow_material()`, część wpuszczona w skałę) dla każdej żyły i żyły za naciekiem; skały bez żyły w Upadowej, Rząpiu i Kaplicy jako zwykły kamień; Galeria: równa, słabsza poświata bez brył; urobek w wózkach może zostać bryłami. Test w `tools/tests/test_expedition.gd`: w każdym miejscu liczba skupisk = `LocationData.veins.size()` i każde ma `VeinMark_*` (wzór task_16).

**Ryzyka:** wydajność (kilkadziesiąt dodatkowych siatek ze świeceniem; trzymać małą liczbę wierzchołków, bez dodatkowych świateł poza `blue_light` przy prawdziwych żyłach); regeneracja przesuwa losowe obroty palików; wygląd „z boku” ocenia tylko człowiek (arkusz, zrzuty ekranu z kilku kątów w raporcie). Test strukturalny liczy w edytorze; to, że listy żył przechodzą do eksportu, sprawdza test eksportu z task_25.

Pełna analiza niżej.

## Analiza

**Jak jest dziś (master `f45b9b0`).** Żyła to cała skała z paczki (`cave_wall_rocks_*`) w węźle z `script/overlay_applier.gd`, który na każdą siatkę pod sobą kładzie `material_overlay` = `shader/blue_iron_vein.gdshader` (unshaded, `blend_add`, pasy `sin()` w przestrzeni świata o szerokości `vein_width = 0.13`, puls `0.65 + 0.35·sin(TIME·0.7 + x·0.3)`). Z boku i z bliska to cienkie linie, które „przecinają” skałę bez względu na jej kształt; to opisuje Roland. Te same nakładki mają cztery generatory:

| Miejsce | Kod | Żyły w danych | Skały z nakładką | Uwagi |
|---|---|---|---|---|
| 9 miejsc z `vein()` (wyrobisko, pompy, grota, kostnica, kuźnia, przekop, zalany, szczelina, szyb) | `gen_locations.gd:729–735`, wywołania `:928–1236` | 13 | 13 | grupa `Vein_<id>`, `blue_light` przed skałą |
| Galeria | `vein()` `:1077–1079` + `BlueWalls` `:1065–1068` | 3 | 3 + 6 | ściany Galerii mają **tę samą** nakładkę co żyły |
| Rząpie | `:398–404` | 2 | 2 + 1 (`:400`, skała e) | grupa `Vein` (stara nazwa, `LEGACY_VEINS`), znacznik `VeinMark` |
| Upadowa | `:480–488` | 2 | 2 + 2 (`:482–483`, skały d, f) | jw.; drugie `blue_light` `:485` świeci przy zawale, nie przy żyle |
| Kaplica | `:533–540` | 2 | 2 + 1 (`:535`, skała e) | jw.; drugie `blue_light` `:537` stoi przy skale-atrapie |
| Stara sztolnia | `gen_mine_deep.gd:282–297` | 2 | 2 | poprawione w task_16; `VeinMark_*` są dziećmi `BlueIronVeins` |
| Zawalony chodnik (obóz) | `gen_camp.gd:578–588` | 1 | 1 | `blue_ore(west, "Vein")`, `VeinGlow` |
| Wózek w magazynie (obóz) | `gen_camp.gd:434–437` | — | 3 kamienie | `CartOre`, urobek, nie żyła |

Żyła za naciekiem (`hidden_vein()`, `:738–754`): skała z nakładką za czterema płytami `crust_mat`, słabe `FaintBlue_<id>`; znacznik jest dzieckiem `Crust_<id>` i ma go za `highlight_target`, więc po odkuciu skorupa znika (`interactable.gd:207–208`), a skała zostaje.

**Podświetlenie [E].** `interactable.gd:98–100` zbiera siatki z `highlight_target` przy `_ready()`, a `set_highlighted()` (`:165–178`) podmienia im `material_overlay` na `interact_highlight.gdshader` i potem przywraca poprzedni. Dziś `highlight_target` = skała z nakładką, więc obrys obejmuje całą skałę. Dla brył: `highlight_target` = węzeł skupiska (bryły), skała zostaje bez podświetlenia albo razem z nim (patrz Plan, krok 2). Bryły z `material_override` nie mają `material_overlay`, więc podmiana i przywracanie działają bez zmian w `interactable.gd`.

**Luki względem wymagań.**
1. ZYL-12 / oprawa: brak kształtu rudy; puls jest w nakładce shaderowej, a `glow_material()` (`gen_locations.gd:785`) daje stałą emisję bez pulsu. Bryły muszą pulsować „jak dziś”, więc potrzebny jest materiał z pulsem (shader) albo skrypt; najprościej nowy shader `spatial` (oświetlony, emisja z tym samym pulsem co dziś, faza z pozycji świata), przypisany jako `material_override` na bryłach.
2. Zgłoszenie: 4 skały-atrapy (Rząpie 1, Upadowa 2, Kaplica 1) i 6 skał `BlueWalls` świecą jak żyła. Atrapy mają zostać zwykłym kamieniem (przenieść poza grupę, jak `PlainRocks` w task_16), `blue_light` tylko przy prawdziwych żyłach. Galeria: „ściany z błękitu” zostają jako równa, słabsza poświata bez brył i bez pasów (Roland, czat 2026-10-27, cytat w wymaganiach).
3. Brak testu, który pilnuje równości „skupiska = żyły” we wszystkich miejscach (task_16 sprawdza tylko sztolnię, `test_expedition.gd:23–33`).

**Zgodność z treścią.** Kilka opisów żył mówi o żyle liniowej: `east_2` „jak nitka wszyta w skałę”, `rzapie` „wąska żyła biegnie ukosem”, `szczelina_1` „wąska żyła w pęknięciu”, `upadowa_2` „cieńsza, ale długa”, `east_1` „od spągu po strop”. Nie trzeba ich zmieniać (to opis żyły w skale, bryły są jej wychodnią), ale układ skupiska może je wspierać: **[ROBOCZE]** każda żyła dostaje rozmiar i rozkład brył (kilka małych brył w ukośnym rzędzie dla wąskiej żyły, kilka dużych w gromadzie dla „najgrubszej” w Upadowej i żył Galerii). Tekstów nie zmieniam, więc `lore-checker` niepotrzebny; arkusz pyta człowieka, czy wygląd zgadza się z opisem.

**Zależności i kolejność.**
- task_25 (eksport gubi listy): 📋 czeka, niewdrożone. Wymagania task_31 tego nie wymagają, ale arkusz sprawdza Upadową, do której po poprawce eksportu potrzebna jest lina; wdrożenie może iść równolegle (inne pliki), arkusz najlepiej grać na ZIP-ie, który ma już poprawkę task_25.
- task_26 (rozbłysk ZYL-9): 📋 czeka. Jego plan szuka siatek w węźle żyły (`Vein_<id>`, `Vein`, `BlueIronVeins`) w czasie gry, bez zależności od shadera. Skupiska brył zostają **wewnątrz** tych węzłów, więc rozbłysk zadziała na nich bez względu na kolejność wdrożeń. Pliki obu zadań się nie pokrywają (task_26 nie rusza generatorów).
- Ścieżki węzłów używane przez testy zostają: `Locations/Upadowa/VeinMark` (`test_day2.gd:40`), `Locations/Rzapie/VeinMark` (`test_rzapie.gd:24`), `MineDeep/BlueIronVeins/VeinMark_east_1` (`test_expedition.gd:37`, `tools/interact_test.gd:7`). Nie zmieniam nazw grup `Vein` (stare żyły) ani `BlueIronVeins`.

**Ryzyka.**
- Wydajność: 25 skupisk po 3–6 brył, `SphereMesh` z małą liczbą segmentów (np. 12×6), bez nowych świateł (zostają istniejące `blue_light`/`VeinLight`/`VeinGlow` przy prawdziwych żyłach, usunięte przy atrapach). Galeria i tak ma 3 światła `Glow`.
- Bryły muszą „wrastać” w ścianę: skały z paczki mają różne kształty, a `pos` w `vein()` to środek skały. Bryły przesunięte wzdłuż normalnej ściany (`Basis(UP, yaw) * BACK`, jak w `vein()` `:732`) o ułamek głębokości skały, część wpuszczona w skałę (środek kuli za powierzchnią). Pozycje trzeba obejrzeć na zrzutach (kilka kątów, także z boku); żadna liczba nie zastąpi oka.
- Regeneracja trzech scen przesuwa losowe obroty palików i kamieni (`randf()` po nowych wywołaniach). Żeby nie przesuwać reszty, bryły nie używają globalnego `randf()`: osobny `RandomNumberGenerator` z ziarnem z `hash(vein_id)`. Diff scen i tak będzie duży (nowe węzły), ale zmiany poza żyłami powinny być zerowe; sprawdzić `git diff --stat` i fragmenty scen.
- Nakładka `blue_iron_vein.gdshader` nie będzie już nigdzie potrzebna (żyły: bryły; Galeria: równa poświata; wózek: bryły). Usunąć plik i jego `.uid`, gdy `grep` nie znajdzie odwołań; `overlay_applier.gd` zostaje dla poświaty Galerii.
- Test strukturalny liczy węzły w edytorowej scenie świata; czy to samo trafia do eksportu, sprawdza test eksportu z task_25 (poza tym zadaniem).

## Plan

1. **Materiały i wspólna funkcja brył** (`tools/generators/`):
   - Nowy `shader/blue_iron_ore.gdshader`: `spatial`, oświetlony (szorstki metaliczny kamień, `ALBEDO` ciemny błękit), `EMISSION` = kolor żyły × `intensity` × puls z dzisiejszego wzoru (`pulse_speed = 0.7`, faza z pozycji świata), bez pasów. Intensywność i prędkość pulsu to oprawa, nie balans: zostają w shaderze jako `uniform` (nie w `07_balans.md`), opisane w „Dla agenta” oprawy.
   - Nowy `shader/blue_glow_wall.gdshader` (nakładka `blend_add`, unshaded): równa, słaba poświata błękitu, bez pasów i bez pulsu (**[ROBOCZE]** „równo” = stała jasność i jednolity kolor). Zastępuje `blue_iron_vein.gdshader` w `BlueWalls`.
   - Wspólny pomocnik `tools/generators/ore_cluster.gd` (statyczna funkcja, bez `class_name`, ładowany `preload` w trzech generatorach, bo `gen_*.gd` to osobne `SceneTree`-skrypty bez wspólnej bazy): `build(parent, node_name, center, yaw_deg, size, spread, seed_key) -> Node3D` tworzy `Node3D` „`Ore_<vein_id>`” w grupie `vein_ore` (`add_to_group(&"vein_ore", true)`, żeby grupa zapisała się w `.tscn`) i z metadaną `vein_id`, a w nim 3–6 `MeshInstance3D` (`SphereMesh`, `radial_segments` 12, `rings` 6, skala niejednorodna, np. (1, 0.75, 0.55) × losowy rozmiar, obrót losowy) z materiałem z pierwszego punktu jako `material_override`. Środki kul częściowo w skale (przesunięcie wzdłuż normalnej ujemne dla części brył), **[ROBOCZE]** rozmiar i rozrzut per żyła. Losowanie z `RandomNumberGenerator` z ziarnem `hash(seed_key)`.
2. **`gen_locations.gd`**:
   - `vein_group()` przestaje nakładać shader (zwykły `Node3D`; skała w środku to kamień). `vein()` i `hidden_vein()` dokładają `ore_cluster.build(...)` w swoim `Vein_<id>`, na powierzchni skały; `vein()` ustawia `highlight_target` znacznika na skupisko (bryły), nie na skałę. **[ROBOCZE]** podświetlenie obejmuje same bryły (to „żyła”), skała obok nie. Nowe opcjonalne argumenty `vein()`: `ore_size`, `ore_spread` (domyślne dla zwykłej żyły).
   - `hidden_vein()`: bryły pod skorupą, częściowo widoczne między płytami `Flowstone` („przebłyskująca spod nacieku”, ZYL-12); `FaintBlue_<id>` zostaje; po odkuciu bryły zostają (skorupa znika jak dziś).
   - Rząpie, Upadowa, Kaplica: skała żyły zostaje w `Vein`, dochodzi skupisko `Ore_rzapie` / `Ore_upadowa` / `Ore_kaplica`, `highlight_target` na skupisko; skały-atrapy (`:400`, `:482–483`, `:535`) przenieść do nowej grupy `PlainRocks` miejsca (te same pozycje, bez nakładki); usunąć `blue_light` bez żyły (`:485` przy zawale, `:537` przy atrapie w Kaplicy) albo przesunąć do prawdziwych żył (Upadowa: „świeci też przez szczeliny w zawale” jest w opisie żyły, więc **[ROBOCZE]** słabe światło przy zawale może zostać jako poświata zza zawału, bez brył; zdecyduję po zrzucie, zapiszę w raporcie).
   - Galeria: `BlueWalls` z nakładką `blue_glow_wall.gdshader` (słabsza, równa); żyły `galeria_1..3` z dużymi skupiskami.
   - LEGACY_VEINS i nazwy znaczników bez zmian.
3. **`gen_mine_deep.gd`**: `BlueIronVeins` bez `overlay_applier`; skały e i f zostają jako kamień, przy każdej `Ore_east_1` / `Ore_east_2` (rozkład: `east_1` długi pionowy rząd „od spągu po strop”, `east_2` mały cienki rząd). `vein_mark()` dostaje `highlight_target` = skupisko. `VeinMark_*` dalej dziećmi `BlueIronVeins` (ścieżki testów).
4. **`gen_camp.gd`**: `blue_ore()` → skała `west_1` bez nakładki + `Ore_west_1`, `highlight_target` na skupisko. `CartOre`: **[ROBOCZE]** kamienie w wózku zamiast pasów dostają kilka małych brył (ten sam materiał, bez grupy `vein_ore`, bo to nie żyła); `Look` z opisem wózka zostaje na pierwszym kamieniu.
5. **Regeneracja i import**: uruchomić trzy generatory (`tools/generators/README` / `tools/README.md#generatory`), potem `--headless --path <kopia gałęzi> --import`. Usunąć `shader/blue_iron_vein.gdshader` (+ `.uid`), jeśli nic go nie używa. Sprawdzić, że diff scen poza żyłami jest pusty (palik i kamienie bez przesunięć).
6. **Test strukturalny** w `tools/tests/test_expedition.gd` (krok obok task_16; scena świata ma wszystkie miejsca): dla każdego `LocationData` z `GameState.LOCATIONS` znaleźć węzeł miejsca (`Locations/<Nazwa>`, `MineDeep` dla `east`, `Camp`/zachód dla `west`; mapa id → ścieżka w teście) i sprawdzić: liczba węzłów z grupy `vein_ore` pod nim = `veins.size()`; zbiór ich `vein_id` = `veins`; dla każdej żyły istnieje znacznik (`VeinMark_<id>` albo `VeinMark` dla `LEGACY_VEINS`) z `highlight_target` = jej skupisko (przy żyle za naciekiem: skorupa, a skupisko leży w `Vein_<id>`); żaden węzeł z `blue_iron_vein`/pasów nie istnieje. Krok task_16 (`:24–29`) przepisać z „skał z nakładką” na „skupiska brył” (dziś liczy dzieci `BlueIronVeins`, po zmianie byłyby tam skały, bryły i znaczniki).
7. **Testy:** serwer po wdrożeniu uruchamia `unit lint dialogue` + `expedition` (nowy test, sztolnia, wyrobisko), `rzapie` i `day2` (znaczniki `Locations/Rzapie/VeinMark`, `Locations/Upadowa/VeinMark`), `kaplica`, `camp_walk` (obóz po regeneracji); agent najpierw robi `--import` w kopii gałęzi (nowe `.gdshader`, brak nowych `class_name` i `.dialogue`). `tools/interact_test.gd` (spoza `run_tests.sh`) uruchomić osobno, jeśli da się krótko. Zrzuty ekranu (`tools/README.md#zrzuty`) Upadowej, Galerii, sztolni i żyły w obozie z przodu i z boku do raportu.
8. **Spec i dokumenty**: w `03_mechaniki/zyly_i_norma.md` (ZYL-12) i `06_oprawa.md` dopisać pod „Dla agenta” nowe wskaźniki (`ore_cluster.gd`, `blue_iron_ore.gdshader`, `blue_glow_wall.gdshader`, grupa `vein_ore`, test) i szczegóły **[ROBOCZE]** (układ brył per żyła, podświetlenie samych brył, CartOre z bryłami, równa poświata Galerii); ⬜ zostaje (finalize). Zgłoszenie: dopisać pod „Odpowiedź agenta” gałąź i commit. `docs/agent/README.md` (system żył i oświetlenia: nakładka → bryły), `tools/README.md` (nowy krok testu, jeśli opisuje scenariusz `expedition`). Arkusz (poziom `rozgrywka`): jedna część `## Część: task_31` arkusza builda (D-27): Upadowa 2 skupiska, Rząpie 2, Kaplica 2, Galeria 3 + równe ściany bez brył, sztolnia 2, zachód 1; wygląd z przodu i z boku; puls; podświetlenie [E] na bryłach; palik obok po zaznaczeniu; żyła za naciekiem przebłyskuje; wózek w obozie.

**Pytania do Rolanda:** brak. Galeria rozstrzygnięta (Roland, czat 2026-10-27, w wymaganiach); pozostałe szczegóły to **[ROBOCZE]** do weta w arkuszu. Karty decyzji nie ma.

Pliki: tools/generators/ore_cluster.gd, tools/generators/gen_locations.gd, tools/generators/gen_mine_deep.gd, tools/generators/gen_camp.gd, shader/blue_iron_ore.gdshader, shader/blue_glow_wall.gdshader, shader/blue_iron_vein.gdshader, shader/blue_iron_vein.gdshader.uid, scene/levels/locations.tscn, scene/levels/mine_deep.tscn, scene/levels/camp.tscn, tools/tests/test_expedition.gd, tools/interact_test.gd, docs/agent/README.md, tools/README.md
Ryzyko: wysokie

## Przepływ (D-36)
Poziom `rozgrywka`: nowy wygląd żył w świecie gry (bryły rudy, materiały, przegenerowane sceny). Arkusz tylko jako jedna część `## Część: task_31` arkusza builda (D-27, D-36 pkt 4); testy `unit lint dialogue` i scenariusze z kroku „Testy” uruchamia serwer po wdrożeniu, przegląd robi osobny przebieg łańcucha.
Ryzyko `wysokie`: przegenerowanie scen `camp`, `locations` i `mine_deep` w trzech generatorach.

## Podsumowanie
Dziś żyłę rysują cienkie pasy shadera nałożone na całe skały, a w Upadowej, Rząpiu, Kaplicy i Galerii świeci 10 skał, przy których nie ma czego zaznaczyć. Plan: wspólna funkcja generatorów robi skupisko pulsujących brył rudy przy każdej z 25 żył (także za naciekiem i w obozie), atrapy stają się zwykłym kamieniem, ściany Galerii dostają równą, słabą poświatę bez brył, a nowy test sprawdza w każdym miejscu, że skupisk jest tyle, ile żył w danych. Zadanie nie potrzebuje decyzji; plików nie dzieli z task_25 ani task_26, a rozbłysk z task_26 zadziała na bryłach, bo zostają w węzłach żył. Wygląd z boku oceni człowiek w arkuszu.
