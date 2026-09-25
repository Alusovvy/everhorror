# 05 Oprawa wizualna i dźwiękowa

> Status: 🟡 szkic · Właściciel: — · Aktualizacja: 2026-09-25

## Kierunek wizualny
Z opisu prologu w GDD:
- **Paleta:** zmierzch i czerwieniejące niebo na zewnątrz, ciemność i ciepłe punkty światła w środku. Pulsujące, **pomarańczowo-czerwone** światło w tunelach. Błękitne żelazo w demie świeci zimnym, pulsującym błękitem jako kontrast do ciepłych lamp. ❓ Czy zostaje przy błękicie?
- **Atmosfera:** mgła, jesień, pustka (porzucony wóz).
- **Styl:** realistyczne, ale nisko-detaliczne modele (obecne zestawy), mocna gra światła i cienia. Ciemność jako główny materiał.
- **Obce budowle Onych** (ściana w kaplicy) są gładkie, srebrnoszare i nie mają śladów dłuta, a ich znaki świecą błękitem. To zgodne z opisem Srebrnej Świątyni w LoreDoc.

## Kierunek dźwiękowy
- Prolog **bez muzyki**: świerszcze, wiatr **[GDD]**.
- Ambient „nie niepokojący, ale **zbyt spokojny**” **[GDD]**.
- W kopalni: kapanie, trzeszczenie stempli, dalekie dudnienie, stukanie kilofa zza ściany. Muzyka tylko w kluczowych momentach VN.

## Rejestr zasobów (assetów)
Każdy zewnętrzny zasób musi mieć tu wpis ze źródłem i licencją **zanim** trafi do wydanej wersji gry.

| Zasób | Folder | Źródło | Licencja | Użyty? |
|---|---|---|---|---|
| Mine & Caves Set (Loafbrr) | `assets/LoafbrrAssets` | [loafbrr.itch.io](https://loafbrr.itch.io/) | **CC0** (plik README) | ✅ hala, tunele, skały, stemple |
| Fantasy Props MegaKit (Standard) | `assets/prop_pack` | [Quaternius](https://quaternius.com) | **CC0** (`LICENSE_FantasyPropsMegaKit.txt`) | ✅ rekwizyty obozu i lokacji |
| Survival Kit | `assets/props/kenney_survival` | [Kenney](https://kenney.nl) | **CC0** (`License.txt`) | ✅ posłania, ognisko, rożen, drogowskazy, skrzynki (z teksturami z Mine & Caves) |
| Universal Base Characters | `assets/characters/quaternius/base`, `hair` | [Quaternius](https://quaternius.com/packs/universalbasecharacters.html) | **CC0** (`LICENSE_UniversalBaseCharacters.txt`) | ✅ ciała męskie i kobiece, fryzury |
| Modular Character Outfits – Fantasy | `assets/characters/quaternius/outfits` | [Quaternius](https://quaternius.com/packs/modularcharacteroutfitsfantasy.html) | **CC0** (`LICENSE_ModularCharacterOutfitsFantasy.txt`) | ✅ stroje chłopskie i zwiadowcy |
| Universal Animation Library | `assets/characters/quaternius/animations` | [Quaternius](https://quaternius.com/packs/universalanimationlibrary.html) | **CC0** (`LICENSE_UniversalAnimationLibrary.txt`) | ✅ animacje postaci |
| Sewer | `assets/Sewer` | ❓ | ❓ **brak pliku licencji** | ⬜ nieużywany, wyłączony z eksportu |
| `cave_ambient.mp3` | `assets/sounds` | ❓ | ❓ | ✅ |
| `steps.mp3` | `assets/sounds` | ❓ | ❓ | ✅ |
| `sample-pic.jpg` | `assets/pics` | ❓ | ❓ | ⬜ stary prototyp VN |

**Zasoby własne (generowane kodem, nasze):**

| Zasób | Folder | Generator |
|---|---|---|
| SFX: kapanie, skrzypienie, dudnienie, trzask lampy, stukanie kilofa, huk wybuchu | `assets/sounds/generated` | `tools/generators/synth_sfx.js` (tymczasowe, do podmiany) |
| Głowy postaci (wycięte z ciał bazowych) | `assets/characters/quaternius/base/head_*.res` | `tools/generators/build_character_head.gd` |
| Żelazna maska Drugich | `assets/characters/iron_mask.res` | `tools/generators/build_iron_mask.gd` |
| Znaki sanctinu (ściana, portret), kreski w rząpiu | `assets/textures/*.png` | `tools/generators/gen_sanctin_textures.gd` |
| Shadery: żyły błękitu, woda, ściana Onych, podświetlenie, tło VN | `shader/` | ręcznie |
| Kostury magów (drewno + świecąca kula), maski srebrna, brązowa i ciemna (wariant żelaznej maski), miecz Sobka (z Fantasy Props) | `scene/characters/*.tscn` | ręcznie (task_05) |
| Rekwizyty proste z brył: koło pompy, rury, grzyby, kryształowe kolumny, czaszki, chleb, łom, naciek nad żyłą, para (cząsteczki) | w `scene/levels/locations.tscn` | `tools/generators/gen_locations.gd` (task_05) |

⚠️ **Ryzyko:** licencji wciąż brakuje dla dźwięków `cave_ambient.mp3` i `steps.mp3` (oba są w buildzie) oraz dla nieużywanych `Sewer` i `sample-pic.jpg`. Trzeba uzupełnić źródła albo zastąpić te pliki, na przykład nagraniami CC0 z Freesound (potrzebny klucz API).

## Zasady techniczne dla grafiki i dźwięku
- Modele: **glTF** (`.gltf`/`.glb`). Import plików Blendera jest wyłączony w projekcie. Tekstury postaci są zmniejszone do 1024 px.
- Nie edytujemy plików zestawów. Materiały nadpisujemy w instancjach albo tworzymy dziedziczące sceny. Wyjątek to kopia poziomu testowego `scene/levels/mine.tscn`, którą edytujemy (usunięty drewniany podest).
- ✅ Ścieżki `res://Assets/...` w zestawie Mine & Caves są poprawione na `res://assets/...` (task_03), więc eksport działa także na systemach rozróżniających wielkość liter.
- Pliki binarne (tekstury, audio, modele) to kandydaci do **Git LFS**.
