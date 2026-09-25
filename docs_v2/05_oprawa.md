# 05 Oprawa wizualna i dźwiękowa

> Status: 🟡 szkic · Właściciel: — · Aktualizacja: 2026-09-25

## Kierunek wizualny
Z opisu prologu w GDD:
- **Paleta:** zmierzch i czerwieniejące niebo na zewnątrz, ciemność i ciepłe punkty światła w środku. Pulsujące, **pomarańczowo-czerwone** światło w tunelach. ❓ Jak ma wyglądać błękitne żelazo? [propozycja] Zimny, błękitny blask jako kontrast do ciepłych lamp.
- **Atmosfera:** mgła, jesień, pustka (porzucony wóz).
- [propozycja] **Styl:** realistyczne, ale nisko-detaliczne modele (obecne zestawy), mocna gra światła i cienia. Ciemność jako główny materiał.

## Kierunek dźwiękowy
- Prolog **bez muzyki**: świerszcze, wiatr **[GDD]**.
- Ambient „nie niepokojący, ale **zbyt spokojny**” **[GDD]**.
- [propozycja] W kopalni: dźwięki przestrzeni (kapanie, trzeszczenie podpór, daleki stukot), kroki na różnych podłożach. Muzyka tylko w kluczowych momentach VN.

## Rejestr zasobów (assetów)
Każdy zewnętrzny zasób musi mieć tu wpis ze źródłem i licencją **zanim** trafi do wydanej wersji gry.

| Zasób | Folder | Źródło | Licencja | Użyty? |
|---|---|---|---|---|
| Mine & Caves Set (Loafbrr) | `assets/LoafbrrAssets` | [loafbrr.itch.io](https://loafbrr.itch.io/) | **CC0** (plik README) | ✅ poziom testowy |
| Prop pack (glTF, tekstury trim) | `assets/prop_pack` | ❓ | ❓ **brak pliku licencji** | ✅ rekwizyty |
| Sewer | `assets/Sewer` | ❓ | ❓ **brak pliku licencji** | ⬜ |
| `cave_ambient.mp3` | `assets/sounds` | ❓ | ❓ | ✅ |
| `steps.mp3` | `assets/sounds` | ❓ | ❓ | ✅ |
| Wygenerowane SFX (kapanie, skrzypienie, dudnienie, trzask lampy, stukanie kilofa) | `assets/sounds/generated` | własne, generowane kodem (`tools/generators/synth_sfx.js`) | nasze | ✅ tymczasowe, do podmiany |
| `sample-pic.jpg` | `assets/pics` | ❓ | ❓ | 🟡 prototyp VN |

⚠️ **Ryzyko:** 5 z 6 zasobów nie ma udokumentowanej licencji. Trzeba uzupełnić źródła (link do strony) i licencje, a w razie wątpliwości zastąpić zasób.

## Zasady techniczne dla grafiki i dźwięku
- Modele: **glTF** (`.gltf`/`.glb`). Import plików Blendera jest wyłączony w projekcie.
- Nie edytujemy plików zestawów. Materiały nadpisujemy w instancjach albo tworzymy dziedziczące sceny.
- ⚠️ Zestaw Mine & Caves odwołuje się do `res://Assets/...` (wielka litera), a folder nazywa się `assets`. Na Windows to tylko ostrzeżenia, ale w eksporcie na Linux lub macOS tekstury się nie wczytają. Do poprawienia przed pierwszym eksportem.
- Pliki binarne (tekstury, audio, modele) to kandydaci do **Git LFS**.
