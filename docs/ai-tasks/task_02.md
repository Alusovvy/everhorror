Requierements:
1. Przygotuj szkic dla takiego taska i wstaw do tego folderu jako task_template.md
2. Napisz mi tutaj w tym tasku w osobnej sekcji jak moge przygotować taka integracje ze ja wydaje nowy built, w sensie wysyłam np commita czy cos i jest nowy build gry robiony i potem np. bot wrzuca na discorda link zeby ludzie mogli pobrac i zainstalowac. Taki build + readme co sie zmienilo.
3. Dodaj logo z assets folderu do menu gry i pauzy

---

## 1. Szablon zadania

Dodałem [task_template.md](task_template.md). Zawiera:
- **Requirements**: jedyna obowiązkowa sekcja, którą wypełniasz ty,
- opcjonalnie: kontekst, kryteria akceptacji („po czym poznam, że jest dobrze”), „poza zakresem”, priorytet,
- pod kreską: sekcje, które wypełniam ja (co zrobione, decyzje, czego potrzebuję, link do testu, podsumowanie).

Użycie: skopiuj szablon jako `task_03.md` i wypełnij Requirements. Resztę możesz usunąć.

## 2. Automatyczny build i ogłoszenie na Discordzie

### Jak to działa

```
ty: git tag v0.2.0 && git push origin v0.2.0
        │
        ▼
GitHub Actions (darmowy serwer w chmurze)
  1. pobiera Godot 4.7.2 + export templates
  2. eksportuje grę na Windows (Everold.exe)
  3. pakuje ZIP: gra + ZMIANY.md (lista zmian z commitów) + README.txt (jak uruchomić)
  4. tworzy GitHub Release z plikiem ZIP i listą zmian
  5. wysyła na kanał Discorda wiadomość: wersja, lista zmian, link „Pobierz”
```

**Wyzwalacz to tag wersji, a nie każdy commit.** To ty decydujesz, kiedy powstaje wersja dla ludzi, a zwykłe commity nie zaśmiecają kanału. Jeśli jednak chcesz build z każdego pusha na `main`, wystarczy zmienić jedną linię w `on:` (opisuję niżej).

**Lista zmian („readme co się zmieniło”)** tworzy się sama z wiadomości commitów od poprzedniego tagu. Pisz więc commity zrozumiale dla graczy, np. `Dodano logo w menu i pauzie`, a nie `fix`. Jeśli wolisz pisać listę ręcznie, prowadź `CHANGELOG.md` i ten plik trafi do ZIP-a.

### Co musisz przygotować (jednorazowo)

| # | Krok | Kto |
|---|---|---|
| 1 | **Repozytorium na GitHubie**: `gh auth login`, potem `gh repo create everold --private --source . --push` | ty (logowanie), ja mogę resztę |
| 2 | **Naprawa ścieżek w zestawie Mine & Caves.** 167 plików odwołuje się do `res://Assets/...` z wielkiej litery. Serwer buildowy działa na Linuksie, gdzie wielkość liter ma znaczenie, więc build wyszedłby **bez tekstur kopalni**. To zamiana tekstu w plikach zestawu. | ja, jedno polecenie |
| 3 | **Preset eksportu**: w edytorze Project → Export → Add… → Windows Desktop. Export Path: `build/windows/Everold.exe`, zaznacz *Embed PCK*. Zapisze się plik `export_presets.cfg`, który trzeba scommitować. | ty w edytorze albo ja w pliku |
| 4 | **Webhook Discorda**: Ustawienia kanału → Integracje → Webhooki → Nowy webhook → Kopiuj URL. Na GitHubie: repo → Settings → Secrets and variables → Actions → *New repository secret*, nazwa `DISCORD_WEBHOOK_URL`, wartość: skopiowany URL. | ty (URL jest tajny) |
| 5 | **Plik workflow** `.github/workflows/release.yml` (treść niżej) | ja |

**Git LFS nie jest potrzebny.** Projekt ma 56 MB, a największy plik 7 MB (limit GitHuba to 100 MB na plik). LFS wręcz by szkodził: darmowy limit transferu LFS to 1 GB miesięcznie, a każdy build pobierałby wszystkie assety.

### Workflow: `.github/workflows/release.yml`

```yaml
name: Release build

on:
  push:
    tags: ["v*"]            # git tag v0.2.0 && git push origin v0.2.0
    # branches: [main]      # ← odkomentuj, jeśli build ma powstawać z każdego pusha na main

permissions:
  contents: write           # potrzebne do utworzenia Release

env:
  GODOT_VERSION: 4.7.2
  GAME_NAME: Everold

jobs:
  windows:
    runs-on: ubuntu-latest  # Linux eksportuje na Windows bez problemu i zużywa 2× mniej minut
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0    # pełna historia, potrzebna do listy zmian

      - name: Cache Godot
        id: cache-godot
        uses: actions/cache@v4
        with:
          path: |
            ~/godot
            ~/.local/share/godot/export_templates
          key: godot-${{ env.GODOT_VERSION }}

      - name: Install Godot + export templates
        if: steps.cache-godot.outputs.cache-hit != 'true'
        run: |
          base=https://github.com/godotengine/godot-builds/releases/download/${GODOT_VERSION}-stable
          mkdir -p ~/godot ~/.local/share/godot/export_templates/${GODOT_VERSION}.stable
          curl -sSL -o godot.zip "$base/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip"
          unzip -q godot.zip -d ~/godot
          curl -sSL -o templates.tpz "$base/Godot_v${GODOT_VERSION}-stable_export_templates.tpz"
          unzip -q templates.tpz -d /tmp/tpl
          mv /tmp/tpl/templates/* ~/.local/share/godot/export_templates/${GODOT_VERSION}.stable/

      - name: Export Windows build
        run: |
          GODOT=~/godot/Godot_v${GODOT_VERSION}-stable_linux.x86_64
          mkdir -p build/windows
          $GODOT --headless --path . --import
          $GODOT --headless --path . --export-release "Windows Desktop" build/windows/${GAME_NAME}.exe
          test -f build/windows/${GAME_NAME}.exe

      - name: Release notes (commits since previous tag)
        run: |
          PREV=$(git describe --tags --abbrev=0 "${GITHUB_REF_NAME}^" 2>/dev/null || true)
          { echo "## ${GAME_NAME} ${GITHUB_REF_NAME}"; echo
            git log --no-merges --pretty='- %s' ${PREV:+$PREV..}${GITHUB_REF_NAME}; } > notes.md
          cat notes.md

      - name: Package ZIP
        run: |
          cp notes.md build/windows/ZMIANY.md
          printf '%s\r\n' "${GAME_NAME} ${GITHUB_REF_NAME}" "" \
            "1. Rozpakuj caly folder." "2. Uruchom ${GAME_NAME}.exe." \
            "3. Jesli Windows pokaze 'System Windows chronil ten komputer': Wiecej informacji -> Uruchom mimo to" \
            "   (gra nie jest podpisana certyfikatem)." > build/windows/README.txt
          (cd build/windows && zip -qr "../../${GAME_NAME}-${GITHUB_REF_NAME}-windows.zip" .)

      - name: GitHub Release
        id: release
        uses: softprops/action-gh-release@v2
        with:
          body_path: notes.md
          files: ${{ env.GAME_NAME }}-${{ github.ref_name }}-windows.zip

      - name: Post to Discord
        env:
          WEBHOOK: ${{ secrets.DISCORD_WEBHOOK_URL }}
          PAGE_URL: ${{ steps.release.outputs.url }}
          ZIP_URL: ${{ fromJSON(steps.release.outputs.assets)[0].browser_download_url }}
        run: |
          jq -n --arg title "${GAME_NAME} ${GITHUB_REF_NAME}" --arg url "$PAGE_URL" \
                --arg notes "$(head -c 3500 notes.md)" --arg zip "$ZIP_URL" \
            '{content: "🕯️ Nowy build gry!",
              embeds: [{title: $title, url: $url, color: 11141120,
                        description: ($notes + "\n\n**[⬇ Pobierz (Windows, .zip)](" + $zip + ")**")}]}' \
          | curl -sSf -H "Content-Type: application/json" -d @- "$WEBHOOK"
```

### Wydanie nowej wersji (na co dzień)

```bash
git commit -am "Dodano logo w menu i pauzie"
git tag v0.2.0
git push origin main v0.2.0
```

Po około 5–8 minutach na Discordzie pojawia się wiadomość z listą zmian i linkiem. Postęp widać na GitHubie w zakładce **Actions**.

### Ważne: repozytorium prywatne czy publiczne?

| | Repo **publiczne** | Repo **prywatne** |
|---|---|---|
| Minuty GitHub Actions | bez limitu | 2000 min/mies. za darmo (≈ 250+ buildów) |
| Link z Discorda | działa dla każdego | **wymaga dostępu do repo**, więc obcy nie pobiorą |
| Kod gry | widoczny dla wszystkich | ukryty |

**Jeśli repo ma być prywatne, a pobierać mają testerzy spoza zespołu**, lepszy jest **itch.io**:
- W workflow dochodzi krok `butler push build/windows <user>/<gra>:windows`. Potrzebny jest sekret `BUTLER_API_KEY`, czyli klucz z itch.io.
- Stronę gry ustawiasz jako *Restricted*: dostęp mają tylko osoby z linkiem albo kluczem.
- Testerzy instalują grę **aplikacją itch**, która sama pobiera aktualizacje przy każdym nowym buildzie. To najbliższe „instalowaniu”, o które pytasz.
- Na Discorda wysyłamy wtedy link do strony itch.io zamiast do GitHuba.

Inne opcje, gdyby były potrzebne później:
- **Instalator .exe** (Inno Setup): zamiast ZIP-a klasyczny instalator ze skrótem na pulpicie. Wymaga runnera Windows, który zużywa 2× więcej minut.
- **Buildy testowe z każdego pusha** jako tzw. artifacts: widoczne tylko dla zespołu na GitHubie.
- **Linux i macOS**: kolejne presety eksportu i kolejne pliki ZIP w tym samym workflow.

Źródła: [Action Setup Godot](https://github.com/marketplace/actions/action-setup-godot), [godot-export](https://github.com/firebelley/godot-export), [github-releases-to-discord](https://github.com/SethCohen/github-releases-to-discord), [Godot → itch.io przez GitHub Actions](https://www.vojtechstruhar.com/blog/022-godot-itch-github-action/), [CD pipeline Godot + itch.io](https://saltares.com/continuous-delivery-pipeline-for-godot-and-itchio/).

## 3. Logo w menu i pauzie

- **Menu główne:** logo zastąpiło tekstowy tytuł „EVERHORROR”. Przy starcie płynnie się pojawia (1,5 s).
- **Pauza:** mniejsze logo nad napisem „PAUSED”. Zmniejszyłem też odstępy, żeby przy 720p przycisk EXIT nie dotykał krawędzi ekranu.
- Logo zostaje widoczne także na ekranach OPTIONS i LOAD/SAVE GAME.
- Sprawdzone na renderach 1280×720 (menu, opcje, pauza na tle gry). Gra uruchamia się bez błędów.

Pliki: `scene/main_menu.tscn`, `scene/pause_menu.tscn`, `script/main_menu.gd`.

## Czego potrzebuję od Ciebie

1. **Nazwa gry.** Logo mówi **EVEROLD**, a projekt i dokumenty mówią „everhorror” (GDD: „XYZ”). Czy mam zmienić nazwę projektu (tytuł okna), dokumentację i nazwę pliku `.exe` na **Everold**? W workflow już przyjąłem `Everold`.
2. **Build:** czy repo będzie publiczne czy prywatne, i GitHub czy itch.io? Od tego zależy ostatni krok workflow.
3. Jeśli chcesz, żebym zrobił kroki 2, 3 i 5 (naprawa ścieżek, preset eksportu, plik workflow), daj znać albo dodaj to jako `task_03`. Webhook i logowanie do GitHuba musisz zrobić sam.

## Test

Lista do sprawdzenia: [docs/human-tasks/factcheck-test-02.md](../human-tasks/factcheck-test-02.md). Przygotowałem też [factcheck-test-01.md](../human-tasks/factcheck-test-01.md) dla zadania 1, bo było w nim dużo implementacji, a nowa zasada z INFO.md jeszcze wtedy nie obowiązywała.

## Podsumowanie

- **Szablon zadania** jest gotowy w `task_template.md`.
- **Pipeline buildów** jest opisany krok po kroku, z gotowym plikiem workflow. Wystarczy tag `vX.Y.Z`, a GitHub Actions eksportuje grę na Windows, pakuje ZIP z listą zmian i instrukcją, tworzy Release i ogłasza go na Discordzie z linkiem do pobrania. Przed pierwszym buildem trzeba naprawić ścieżki `Assets/` w zestawie kopalni (inaczej build nie będzie miał tekstur), utworzyć preset eksportu i dodać webhook. Przy prywatnym repo lepszą dystrybucją dla testerów jest itch.io z automatycznymi aktualizacjami.
- **Logo EVEROLD** jest w menu głównym (z płynnym pojawieniem się) i w menu pauzy. Zweryfikowane na renderach.
- Do decyzji: **nazwa gry (Everold?)** i **sposób dystrybucji**.