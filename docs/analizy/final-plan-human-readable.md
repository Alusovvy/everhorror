# Everhorror — plan końcowy

> 2026-10-26, zaktualizowany 2026-10-27 · Przygotował: agent (Claude) · Dla: Rolanda
>
> To jedyny plan projektu: **co robimy, w jakiej kolejności i kto co robi**. Zastępuje wcześniejsze analizy i plany. Ich decyzje, zgody i najważniejsze ustalenia przeniesiono tutaj ([§9](#9-decyzje-i-stałe-zgody)), a same pliki usunięto.
>
> **Status treści:**
> - **Decyzje** z [§9](#9-decyzje-i-stałe-zgody) obowiązują. D-01…D-15 i D1–D10 pochodzą z 2026-10-26, a D-16…D-26 z 2026-10-26/27; każda ma w tabeli podane źródło, także gdy jest to tylko rekomendacja agenta bez weta.
> - **Uproszczenia** z [§8.3](#83-co-upraszczam) to rekomendacja. Obowiązują od zapisu, dopóki Roland ich nie zawetuje.
> - **Liczby w etapach 5–7** to wartości startowe, które sprawdzi pomiar. Nie są to ostateczne decyzje.
>
> **Od czego zacząć:** [Gdzie jesteśmy](#gdzie-jesteśmy-2026-10-27). Skróty (PT, CP, K, ⬜, `[ROBOCZE]`) objaśnia [słowniczek](#10-słowniczek).

## Gdzie jesteśmy (2026-10-27)

- **Etapy 0–2 są zrobione.** Praca jest zapisana i wypchnięta w obu repozytoriach. Build **0.5.3** jest scalony do `master` gry, a tag `v0.5.3` stoi na `e1ba7ca`.
- **Zakres 0.5.3 się zmienił.** Raport przebiegu i bot balansu, planowane na 0.5.4 (etap 4), weszły do 0.5.3 w task_14. PT0 odbywa się więc na buildzie, który już zapisuje raport przebiegu (zob. [etap 4](#etap-4--pomiar-raport-i-bot-weszły-do-053)).
- **task_14 jest sfinalizowane.** Zadanie leży w `docs/ai-tasks/done/`, a wiersz w `WDROZENIA.md` ma wpis `27e91e7`. Lista „Na gałęziach” jest pusta. Zdalna gałąź `spec/2026-10-26-task14` zostaje do decyzji Rolanda. Czasowa kopia robocza specyfikacji `specification-praca` już nie istnieje.
- **Orkiestracja z dashboardu działa.** Zadania, arkusze, karty decyzji i przebiegi agenta obsługuje widok „Praca” (task_15, kod w `master` specyfikacji, ostatni commit dashboardu `88edde0`). Decyzje: [D-16…D-21](#decyzje-z-task_15-d-16d-21). Instrukcja obsługi: `specification/dashboard/INSTRUKCJA.md`.
- **Następny krok: etap 3, sesja PT0.** Jest jeden połączony arkusz, `docs/human-tasks/factcheck-test-14.md`. Część A dotyczy gry 0.5.3: wiersze 1–15, ankieta i raport przebiegu. Część B to odbiór dashboardu: wiersze 16–29, a wiersz 29 odsyła do instrukcji. Sesja zajmuje 1–3 godziny ([D-25](#decyzje-z-porządkowania-dokumentacji-d-22d-26)). Wcześniejsze arkusze `factcheck-test-15` i `factcheck-foundation-2026-10-26` są zastąpione i leżą w `done/` jako historia.
- **Punkt odniesienia K1 z bota** (task_14, nie od gracza): norma 12 żył pada między dniem 4, 13:00 (styl „żyły”) a dniem 5, 15:30 (styl „rozmowy”, wariant opóźniony). Cel [K1](#4-cele-mierzalne) to „nie wcześniej niż wieczorem dnia 6”.
- **Czeka na wyraźne „tak” Rolanda:** hasło administratora dashboardu, pierwsze płatne kliknięcie przebiegu oraz źródło i licencja `assets/logo.png` przed demem publicznym ([D-21](#decyzje-z-task_15-d-16d-21)).

---

## W skrócie

1. **Gra ma mocną pętlę, ale jej trzy obietnice słabną w połowie tygodnia.** Dotyczy to demo 0.5.2 i trzech obietnic: presji czasu, kruszących się ludzi i horroru w głąb. Ponowne sprawdzenie kodu potwierdziło diagnozę. Przy ludziach wyszło nawet gorzej: przez poczytalność łamie się praktycznie tylko Mirosław.
2. **Poprzednia praca nad narzędziami jest dobra, ale wąska.** Wykonał ją inny model AI. Dashboard specyfikacji dostał wyszukiwarkę i bezpieczny zapis, powstała jedna instrukcja pracy (`WORKFLOW.md`), a poller tylko powiadamia. Testy dashboardu przechodzą; agent uruchomił je ponownie.
3. **Najtańsze i najcenniejsze kroki są zrobione.** Korekta fałszywych wpisów testów, decyzje w specyfikacji, trzy drobne błędy gry i numer wersji weszły w etapach 1–2 (build 0.5.3).
4. **Od miesiąca nikt nie grał w grę.** Następnym prawdziwym krokiem jest sesja gry (PT0), a nie kolejne narzędzia.
5. **Kolejność etapów:**

   | Etap | Co |
   |---|---|
   | 0 | Zabezpieczyć pracę |
   | 1 | Posprzątać zapisy |
   | 2 | Poprawić drobne błędy |
   | 3 | **Zagrać (PT0) — bramka** |
   | 4 | Zmierzyć |
   | 5 | Poprawić odczucie |
   | 6 | Presja |
   | 7 | Ludzie |
   | 8 | Fabuła — **równolegle, tylko w specyfikacji** |
   | 9 | Pierwsza godzina i demo |

6. **Upraszczam wcześniejszy plan.** Odkładam nowy dziennik prac i rozbudowane CLI. CI i osobna tożsamość agenta stają się opcjonalne. Wstrzymanie dashboardu zostało zastąpione prośbą Rolanda z 2026-10-26, zob. [D-16](#decyzje-z-task_15-d-16d-21). Specyfikację nadal edytujemy bez osobnej kopii roboczej; kopia `specification-praca` była tylko czasowym wyjątkiem na task_15 i jest już usunięta.

**Gdzie czytać dalej:** etapy są w [§1](#1-plan-działań), obowiązki Rolanda w [§2](#2-co-robi-roland). [§7](#7-ocena-poprzedniej-pracy-nad-narzędziami) i [§8](#8-weryfikacja-wcześniejszego-planu) to dowody i historia. Wyjątek: [§8.3](#83-co-upraszczam) opisuje zmiany planu, które Roland może zawetować.

---

## 1. Plan działań

```text
Etap 0  Zabezpieczyć pracę              ~1 h        zrobione
Etap 1  Uczciwe zapisy i decyzje        ~3 h        zrobione (tylko dokumenty)
Etap 2  Drobne poprawki gry + wersja    ~3 h        zrobione → build 0.5.3, tag v0.5.3
Etap 3  Sesja gry PT0                   1–3 h Rolanda   ← teraz, bramka
Etap 4  Pomiar                          raport i bot już w 0.5.3; reszta → build 0.5.4
Etap 5  Odczucie (horror w świecie)     → PT1
Etap 6  Presja tygodnia                 → PT2
Etap 7  Ludzie się kruszą               → PT3
Etap 8  Kręgosłup fabuły                równolegle od etapu 5, tylko w specyfikacji
Etap 9  Pierwsza godzina i demo         → PT4 z nowymi graczami
```

- **Czasy to szacunki, nie terminy.** Przy dotychczasowym tempie wychodzi mniej więcej jeden etap gry tygodniowo.
- **Zasada startu:** etapy 4–9 zaczynają się dopiero na hasło Rolanda „start etapu N”. Etapy 0–2 to porządki i ruszają od razu po zatwierdzeniu.
- **Jeśli sesja gry wypadnie źle,** najpierw poprawiamy znalezione problemy, a dopiero potem idziemy dalej.

### Etap 0 — Zabezpieczyć pracę

**Stan: zrobione.**

**Cel:** awaria dysku nie zabiera miesiąca pracy.

1. **Specyfikacja:** dwa commity procesowe `[agent] proces: …`, osobno dla dashboardu i osobno dla dokumentów. W opisie commita zaznaczamy, że 3 pozorne „zmiany do wdrożenia” to tylko zmiana opiekuna z Rena na Rolanda. Nie robimy z nich zadań i **nie przesuwamy baseline**.
2. **Gra:** commit obejmujący ten plan, instrukcje, skille, narzędzia i arkusz odbioru.
3. **Push** obu repozytoriów, w tym 4 zaległych commitów gry.
4. **Tag** `v0.5.2` na `e4c5edc`. Starsze buildy tagujemy dopiero po sprawdzeniu, który commit był którym demem.

- **Kto:** agent robi commity. Pierwszy push i tag `v0.5.2` idą po wyraźnej zgodzie Rolanda; późniejsze tagi i push `master` po scaleniu mieszczą się w stałych zgodach z [§9](#9-decyzje-i-stałe-zgody).
- **Gotowe, gdy:**
  - `git status` jest czysty w obu repozytoriach;
  - stan lokalny zgadza się ze zdalnym;
  - `git tag` pokazuje `v0.5.2`.

### Etap 1 — Uczciwe zapisy i decyzje

**Stan: zrobione.** Banery z ostatniego punktu zastąpiła archiwizacja z [D-02](#decyzje-o-projekcie-i-procesie-d-01d-15).

**Cel:** zapisy mówią prawdę, a decyzje da się znaleźć w specyfikacji. Etap dotyczy dokumentów i jednej drobnej poprawki testu pollera.

- **Korekta fałszywych potwierdzeń:**
  - dopisać do 123 wierszy, które agent oznaczył jako „sprawdzone przez użytkownika”, adnotację „(wpis agenta, nie testera — 2026-09-26)”;
  - w nagłówkach tych arkuszy wpisać „niesprawdzone przez człowieka”;
  - dodać erratę w `decision-analiza-rozgrywki.md`.
- **Zapis decyzji:**
  1. Wpisać w `docs/human-tasks/decision-analiza-rozgrywki.md` odpowiedzi D1–D10 (dziś 0 z 10) z dopiskiem „Roland, czat 2026-10-26”.
  2. Przenieść ten plik do `done/`.
  3. Przepisać decyzje z [§9](#9-decyzje-i-stałe-zgody) do dziennika decyzji w `specification/09_produkcja.md`, a karty umieścić w `zgloszenia/`.
  4. Usunąć z `09_produkcja.md` pytania, na które już odpowiedziano.
- **Drobne poprawki specyfikacji:**
  - poprawić liczniki: 20 przedmiotów, 15 zadań, 15 kart postaci;
  - usunąć nieistniejącą akcję `jump`;
  - poprawić ścieżkę na `scene/ui/screen_fade.tscn`;
  - zamienić „task_11” na „task_09” w `WDROZENIA.md`;
  - usunąć nieistniejący filar „kopalnia patrzy”;
  - poprawić podsumowanie task_13;
  - dopisać test `first_meet` do mapy testów;
  - dopisać Hrapka do tabeli zakończeń;
  - zaktualizować kamienie milowe i hash `master`.
- **Jedna zasada dla zmian spoza specyfikacji.** Dziś `ARCHITEKTURA.md` i README dashboardu mówią co innego niż skille. Ustalamy, że każda zmiana najpierw trafia do specyfikacji jako ⬜, więc tabela „Zmiany agenta poza specyfikacją” przestaje rosnąć ([D-23](#decyzje-z-porządkowania-dokumentacji-d-22d-26)).
- **Banery** „materiał referencyjny — nie aktualizować” w `docs/MECHANICS.md` i w plikach `docs_v2/`.
- **Test pollera:** wymusić kodowanie UTF-8, bo dziś pada w domyślnej konsoli Windows.

- **Kto:** agent robi poprawki, Roland przegląda zmiany.
- **Gotowe, gdy:**
  - żaden tekst agenta nie stoi w kolumnie człowieka;
  - wyszukiwarka dashboardu znajduje każdą decyzję;
  - lint daje 0 błędów.

### Etap 2 — Drobne poprawki gry i numer wersji → 0.5.3

**Stan: zrobione.** Build jest scalony do `master` gry (`5c08c5d`), tag `v0.5.3` stoi na `e1ba7ca`.

**Cel:** czysty build do pierwszej sesji gry.

- **Trzy błędy:**
  - postacie, które jeszcze nie przybyły do obozu (Sabina, Drudzy), nie tracą poczytalności w nocy;
  - martwy warunek `hieronim_gone` usunąć albo zacząć tę flagę ustawiać;
  - poprawić linię intro: stół z mapą stoi w zagrodzie bez dachu, a nie „za drewnianą ścianką”.
- **Wersja:**
  - `config/version` w ustawieniach projektu;
  - w menu głównym napis `0.5.3 · spec <skrót commita>`;
  - `CHANGELOG.md` dołączony do zipa.
- **Testy:** warstwy `unit`, `lint`, `dialogue` i jeden krótki scenariusz.

- **Kto:** agent pracuje na gałęzi `spec/*`, Roland scala. Po scaleniu przez Rolanda agent taguje `v0.5.3` i wysyła zmiany (push), zgodnie z [regułą tagów i pushy](#reguła-tagów-i-pushy).
- **Gotowe, gdy:** menu pokazuje wersję, a zip 0.5.3 leży w `build/`.

### Etap 3 — Sesja gry PT0 (bramka)

**Cel:** pierwsza prawdziwa informacja od człowieka od miesiąca.

- Roland gra w 0.5.3 przez 1–3 godziny; najlepiej, żeby w tym czasie przejść cały tydzień w grze (dni 1–7).
- **Jeden arkusz**, `docs/human-tasks/factcheck-test-14.md`, zastępuje sześć dawnych arkuszy (factchecki 08–13, 76 wierszy) i odbiór dashboardu z task_15. Część A (gra 0.5.3) zawiera:
  - **15 wierszy** wyłącznie z rzeczami, które ocenia człowiek: odczucie, czytelność, ton, obraz;
  - **5 pytań w skali 1–7:**
    - napięcie w tunelach;
    - rozumiem, co kosztuje czas;
    - „dziś zabrakło mi czasu” — **tę jedną liczbę zapisujemy po każdym dniu gry**;
    - przywiązanie do ludzi;
    - ciekawość „co niżej”;
  - **1 pytanie otwarte:** „gdzie było nudno albo trudno się połapać?”;
  - **raport przebiegu:** do arkusza dołączamy pliki `.md` i `.json` z gry.
- **Część B** (wiersze 16–29) to odbiór dashboardu z task_15. Wiersz 29 odsyła do `specification/dashboard/INSTRUKCJA.md`.
- **Bramka:** dopóki PT0 nie jest wypełniony albo świadomie pominięty przez Rolanda, agent nie zaczyna nowych funkcji gry. Narzędzia pomiaru z etapu 4 już są (raport i bot w 0.5.3), a dalsze można budować, bo nie zmieniają rozgrywki.

- **Kto:** agent przygotowuje arkusz, Roland gra i go wypełnia.
- **Gotowe, gdy:** arkusz jest wypełniony albo jawnie pominięty, a każdy znaleziony problem ma decyzję (poprawić teraz albo odłożyć).

### Etap 4 — Pomiar (raport i bot weszły do 0.5.3)

**Cel:** liczby zamiast zgadywania przed zmianą balansu.

- **Zmiana zakresu (2026-10-27).** Raport przebiegu i bot balansu zrobił task_14 już w 0.5.3, a nie w 0.5.4. Dzięki temu PT0 daje pierwszy raport z gry.
- **Raport przebiegu.** Gra zapisuje go na koniec tygodnia i z menu pauzy, jako lokalny plik `.md` i `.json`. Zawiera:
  - czas w podziale na kategorie, dla każdego dnia;
  - liczbę żył;
  - stan bohatera i ludzi o świcie;
  - kluczowe wybory i zakończenie.

  Nic nie jest wysyłane przez sieć.
- **Bot balansu.** To skrypt, który sam „gra” tydzień bez uruchamiania świata gry. Ma dwa style gry: „żyły” (zachłanny) i „rozmowy”. Wypisuje, kiedy osiągnięto normę, oraz stan na koniec tygodnia.
- **Stan wyjściowy K1 z bota.** Norma 12 żył pada od dnia 4, 13:00 (styl „żyły”, wariant optymistyczny) do dnia 5, 15:30 (styl „rozmowy”, wariant opóźniony). Cel z [§4](#4-cele-mierzalne) to wieczór dnia 6. Bot nie zastępuje gracza, więc liczby potwierdzi dopiero raport z PT0.
- **Zostaje do zrobienia** (proces, nie warunek ukończenia etapu):
  - zawęzić uprawnienia agenta w `.claude/settings.json`: zamiast ogólnych `git:*` i `node:*` lista konkretnych komend, a w zakazach `+master`, `rebase`, `restore` i `checkout --`;
  - podział `CLAUDE.md` na rdzeń do 10 KB i pliki tematyczne wykonuje przebieg dokumentacji z 2026-10-27, nie etap 4.

- **Kto:** agent pracuje na gałęzi `spec/*`, Roland scala.
- **Gotowe, gdy:** bot podaje dzień osiągnięcia normy i gra zapisuje raport przebiegu (oba są w 0.5.3), a uprawnienia są zawężone. Pierwszy punkt odniesienia dla celów [K1–K5](#4-cele-mierzalne) daje PT0, bo arkusz prosi o dołączenie plików raportu. PT1 służy do porównania.

### Etap 5 — Odczucie: horror w świecie, nie w tekście

**Cel:** strach w tym, co słychać i widać, a nie w napisach.

- **Ruch:**
  - chód około **3,2 m/s** z krótkim rozpędem i hamowaniem; dziś jest 5 m/s, czyli tempo biegu;
  - opcjonalne kołysanie głowy;
  - kroki zależne od podłoża: drewno, skała, woda;
  - wolniejszy chód, gdy bohater jest ranny.
- **Światło według głębokości.** Obóz zostaje ciepły, tunele są coraz zimniejsze i ciemniejsze. Na głębokości 3–4 świecą tylko lampa i żyły.
- **Dźwięk zamiast tekstu:**
  - szepty jako dźwięk 3D za plecami, z tekstem tylko jako napisem;
  - pukanie, które z dnia na dzień jest bliżej;
  - lampa przygasa, gdy bohater jest na krawędzi.
- **Łagodniejsze podświetlenie.** Postacie tracą podświetlenie, a przedmioty dostają cienki kontur.
- **Mikro-horror** wieczorami i nocami w dniach 1–2. Próba w Kostnicy (4b) nie weszła do decyzji: wybrano 4a (Roland, czat 2026-10-26). Wraca tylko na osobne polecenie.
- **Licencje.** `cave_ambient.mp3` i `steps.mp3` wymienić na dźwięki CC0. Freesound wchodzi w grę, jeśli Roland poda klucz.
- **Sesja gry PT1.** Porównuje K1–K5 z raportem z PT0 oraz napięcie (K3) z ankietą PT0. Warto dać build też znajomemu.

- **Kto:** agent pracuje na gałęzi `spec/*`, Roland scala i gra.
- **Gotowe, gdy:** build ma nowy ruch, światło i dźwięk, a arkusz PT1 jest wypełniony.

### Etap 6 — Presja tygodnia

**Cel:** gracz co dzień czuje „nie zdążę”, a nie tylko w dniu 7.

- **Norma etapami.** Racibor sprawdza ją rano w dniach 4, 6 i 8, bo co dwa dni przyjeżdża wózek z góry. Startujemy od 4/8/14 żył, a ostateczne liczby ustawia bot. **Niezaliczony etap kosztuje zaufanie i scenę, ale nie kończy gry.**
- **Noc ma cenę:**
  - −3 poczytalności za każdą rozpoczętą godzinę po 22:00;
  - po powrocie po północy pobudka jest o 7:00.
- **Żyły ponad normę jako pokusa** (dokładny próg bot ustawi razem z normą). Amulet się grzeje, sny są silniejsze, a każda taka żyła kosztuje −1 poczytalności.
- **Rozmowy oddają czas.** Każda dłuższa płatna rozmowa daje wskazówkę o drodze lub o żyle, ostrzeżenie albo zniżkę.
- **Zmęczenie** zostaje tylko jako modyfikator czasu marszu, bez nowych efektów.
- **Strojenie stanu „na krawędzi”** według pierwszego zmierzonego tygodnia, bez nowych liczników.
- **Sesja gry PT2.** Sprawdzamy cele K1 i K4.

- **Kto:** agent pracuje na gałęzi `spec/*`, Roland scala i gra.
- **Gotowe, gdy:** K1 i K4 są spełnione albo Roland wybiera, co poprawić przed etapem 7.

### Etap 7 — Ludzie się kruszą

**Cel:** więcej niż jedna osoba w obozie łamie się na oczach gracza, a koniec tygodnia pokazuje, kogo zabrakło w obozie.

- **Wymaga:**
  - rejestru kanonu z etapu 8 (krok 1), który przeszedł okno weta;
  - okna weta Rolanda na teksty załamań.
- **Najpierw przygotowanie (część 1 „wydarzeń jako danych”):**
  1. Test „złoty tydzień” zapisuje wyniki wszystkich 7 nocy.
  2. Nocne zmiany poczytalności i poranne zdania przechodzą z kodu do tabel w specyfikacji, a z nich przez generator do danych gry.
  3. Test potwierdza, że wyniki są identyczne. Zachowanie gry się nie zmienia.
- **Wspólne wstrząsy:**
  - drżenie ziemi kosztuje −8 zamiast −2;
  - śmierć lub odejście kogoś to −5 dla pozostałych;
  - praca w głębi to −1 co noc.
- **Punkty załamania dla Tekli, Racibora i Anzelma.** Każde z nich łamie się po swojemu, na oczach gracza, w osobnej scenie. Teksty pisze agent jako `[ROBOCZE]`, a Roland może je zawetować. Trzeba też naprawić Dobrawę, która dziś nie dochodzi do progu załamania.
- **Zapowiedź dzień wcześniej,** np. „Nasir wygląda coraz gorzej”.
- **Jedna szansa na uspokojenie** każdej postaci. To scena, a nie nowy licznik.
- **Zakończenie zależne od losów ludzi.** Dwa ekrany zakończenia zostają jak dziś, ale zmienia się ich tytuł i pierwszy akapit, np. „Nie wszyscy wyjadą.”
- **Sesja gry PT3.** Sprawdzamy cele K2 i K5.

- **Kto:** agent pracuje na gałęzi `spec/*`, Roland przegląda teksty, scala i gra.
- **Gotowe, gdy:** „złoty tydzień” przechodzi, a K2 i K5 są spełnione albo Roland wybiera, co poprawić.

### Etap 8 — Kręgosłup fabuły (równolegle, tylko w specyfikacji)

**Cel:** wypełnić puste miejsca w GDD, czyli dokumencie projektowym gry: główną fabułę i zakończenia pełnej gry.

1. **Rejestr kanonu** w nowym pliku `specification/01_swiat/biblia_tajemnic.md`: co jest prawdą, co gra pokazuje i czego nigdy nie mówi. Zaczynamy w etapie 5.
2. **Karty kanonu:**
   - rok 1518;
   - 40 lat przerwy;
   - wątek Skarbnika;
   - Czternasty zostaje w grze nienazwany;
   - po 2–3 warianty dla pytań „czyje myśli są w snach” i „czym jest kryształ”.
3. **2–3 jednostronicowe osie fabuły.** Agent rekomenduje jedną.
4. **Tabele zakończeń pełnej gry.**

Wszystko oznaczamy `[ROBOCZE]` i obowiązuje dopiero po oknie weta. Agent pisze najwyżej około 20 nowych faktów kanonu między przeglądami.

- **Kto:** agent pisze, Roland może zawetować.
- **Gotowe, gdy:** punkty 1–4 są zapisane, a wybrana oś fabuły przeszła okno weta.

### Etap 9 — Pierwsza godzina i demo publiczne

**Cel:** pierwsza godzina, która przekona nowego gracza.

- **Wymaga:**
  - etapu 5;
  - kroków 1–3 etapu 8 (rejestr, karty kanonu, oś fabuły).

  Lepiej zacząć go po etapach 6 i 7.
- **Prolog na powierzchni**, który jest też samouczkiem.
- **Demo publiczne:** dni 1–3, zakończone na spotkaniu z Exitium. Pełna gra nadal trwa cały tydzień.
- **Wersja angielska**, przez ten sam mechanizm tłumaczeń co gwara. Gwara zostaje tylko po polsku.
- **Ostateczna nazwa przed stroną w sklepie.** Do tego czasu zostaje „Everhorror” (kandydaci w [§9](#9-decyzje-i-stałe-zgody)).
- **Wskazówki z researchu** (źródła blogowe, niska pewność):
  - strona sklepu i grafika okładki ważą tyle samo co demo;
  - demo warto wypuścić kilka tygodni przed festiwalem, np. Steam Next Fest;
  - demo powinno trwać 15–60 minut i kończyć się w punkcie kulminacyjnym.
- **Sesja gry PT4** z nowymi graczami. Sprawdzamy K3 i pierwszą godzinę.

- **Kto:** agent przygotowuje, Roland decyduje. Publikacja i wydatki tylko po wyraźnym „tak”.
- **Gotowe, gdy:** PT4 jest wypełniony przez graczy spoza projektu, a decyzja o publikacji dema jest podjęta.

---

## 2. Co robi Roland

- **Teraz:** sesja PT0 w arkuszu `docs/human-tasks/factcheck-test-14.md` (część A: gra 0.5.3, część B: odbiór dashboardu), 1–3 godziny. Do tego czasu czekają jeszcze trzy sprawy z końca bloku [Gdzie jesteśmy](#gdzie-jesteśmy-2026-10-27).
- **Po każdym etapie gry (zwykle raz w tygodniu):**
  - około 30 minut na karty decyzji czekające na weto, wyniki gry i wybór następnego etapu;
  - około godziny na grę w najnowszy build i wypełnienie krótkiego arkusza; PT0 jest dłuższy, 1–3 godziny.
- **Scalanie:** gałąź agenta trafia do gry tylko po decyzji Rolanda.
- **Wyraźne „tak”** dla rzeczy publicznych, płatnych i związanych z bezpieczeństwem. Nic takiego nie dzieje się samo.
- **Opcjonalnie:**
  - klucz Freesound;
  - build dla znajomego, który odpowie na te same pytania.

---

## 3. Zasady, które obowiązują

1. **Trzy źródła prawdy:** specyfikacja mówi, co chcemy; kod mówi, co gra robi; arkusz człowieka mówi, co ktoś naprawdę sprawdził.
2. **Każda zmiana gry zaczyna się w specyfikacji.** Najpierw jest reguła ⬜, potem zadanie, gałąź i build. Prośba z czatu też najpierw trafia do specyfikacji.
3. **Decyzje: agent rekomenduje, Roland może zawetować.**
   - Rzeczy odwracalne (liczby, UX, proces) obowiązują od zapisu.
   - Kanon, nazwa i język obowiązują po najbliższym przeglądzie Rolanda (zwykle raz w tygodniu).
   - Pieniądze, bezpieczeństwo i wszystko publiczne wymagają **wyraźnego „tak”**.
   - Każda rekomendacja podaje filar gry, któremu służy, i wskazuje konflikt z wcześniejszą decyzją.
4. **Agent nigdy nie wpisuje wyników za człowieka.** Brak wpisu oznacza brak sprawdzenia. Decyzję z czatu agent zapisuje tylko z podpisem „Roland, czat <data>: …”.
5. **Limity pracy:**
   - najwyżej **1** otwarta gałąź z kodem;
   - najwyżej **2** buildy czekające na zagranie. Przy limicie agent proponuje sesję gry zamiast nowej funkcji; poprawki błędów są nadal dozwolone;
   - najwyżej **5** otwartych kart decyzji.
6. **Pełny zestaw testów uruchamiamy tylko za zgodą. Do `master` gry scala tylko Roland.**
7. **Każdy build dostaje numer wersji i tag.** Push następuje po każdym scaleniu, według jednej [reguły tagów i pushy](#reguła-tagów-i-pushy) z §9.
8. **Zasady projektowe dla każdej zmiany gry:**
   - bez walki;
   - bez nowych liczników;
   - bez zegara czasu rzeczywistego;
   - każdą nieodwracalną stratę zapowiadamy dzień wcześniej;
   - słowa zamiast liczb;
   - rzadkie, niepewne straszenie zamiast częstego;
   - każda dłuższa płatna rozmowa coś oddaje.

Codzienną drogę od pomysłu do sprawdzenia opisuje `specification/WORKFLOW.md`.

---

## 4. Cele mierzalne

Cele sprawdzamy botem, raportami przebiegu i pięcioma pytaniami z arkusza. Przy jednym testerze ankieta pokazuje tylko kierunek, a nie dowód.

| Cel | Filar | Kiedy uznajemy, że działa |
|---|---|---|
| **K1** Presja | Czas to waluta | Bot „żyły” osiąga normę **nie wcześniej niż wieczorem dnia 6**. Odpowiedź „dziś zabrakło mi czasu” dostaje ≥ 4/7 w co najmniej 3 dniach. |
| **K2** Ludzie | Ludzie się kruszą | Do nocy 6 co najmniej 6 z 11 osób w obozie choć raz traci spokój. Strata zdarza się w co najmniej połowie przebiegów, a co najmniej 80% strat jest zapowiedziane dzień wcześniej. Próg 80% służy pomiarowi; zasada z [§3](#3-zasady-które-obowiązują) dąży do zapowiadania wszystkich. |
| **K3** Głębia | Tajemnica w głąb | Bohater jest „na krawędzi” w co najmniej połowie przebiegów. Od dnia 2 co dzień zdarza się coś niepokojącego poza tekstem. Napięcie na głębokości 3–4 to ≥ 5/7, a w obozie ≤ 3/7. |
| **K4** Czytelność | — | „Rozumiem, co kosztuje czas” dostaje ≥ 6/7. Żadna nieodwracalna strata nie przychodzi bez ostrzeżenia. |
| **K5** Zakończenia | — | Są co najmniej 3 rozróżnialne warianty zakończenia zależne od losów ludzi. |

---

## 5. Czego nie robimy

- **Narzędzia:** bez bazy danych zamiast Markdown, przebudowy dashboardu, grafu relacji i orkiestratora wielu agentów (tę ostatnią decyzję podjęto już 2026-09-26). Nowe integracje MCP tylko przy konkretnej potrzebie.
- **Gra:** bez walki, nowych liczników zasobów, zegara czasu rzeczywistego, wyborów na czas w rozmowach i skoku.
- **Platformy:** Unity, WebGL i multiplayer są poza zakresem.
- **Publikacja:** bez publikacji, wydatków i strony w sklepie, dopóki Roland wyraźnie się nie zgodzi.

---

## 6. Ryzyka

| Ryzyko | Jak je ograniczamy |
|---|---|
| Utrata pracy, bo wszystko jest na jednym dysku | Etap 0 jako pierwszy, potem tag i push po każdym scaleniu. |
| Historię i kanon pisze agent | Jeden rejestr kanonu, weto Rolanda, oznaczenie `[ROBOCZE]` na wszystkim i limit tempa. Przyszły scenarzysta zobaczy, co napisał agent. |
| „Wszystko według rekomendacji” staje się przyklepywaniem | Każda rekomendacja wskazuje filar i konflikty. Decyzje odwracalne można cofnąć nową kartą. |
| Jeden tester | Bot i raporty przebiegu mierzą to, co da się zmierzyć. Przy PT1 i PT4 warto zaprosić znajomych. |
| Znowu więcej procesu niż gry | Odłożone narzędzia z [§8.3](#83-co-upraszczam), bramka PT0 i limit 2 buildów bez sesji gry. |
| Przepisanie wydarzeń zepsuje tydzień | Test „złoty tydzień” przed i po zmianie oraz tylko jedna część naraz. |
| Etapy normy będą frustrować | Niezaliczony etap to scena i utrata zaufania, nie koniec gry. Każdy etap jest zapowiedziany. |
| Ciemniej znaczy mniej czytelnie | Opcja jasności już jest. Światło nadal prowadzi ścieżki. Sprawdzamy zrzuty ekranu na każdej głębokości. |

---

## 7. Ocena poprzedniej pracy nad narzędziami

Przed tym planem inny model AI („drugi model”) uporządkował dokumentację, dashboard i sposób pracy. Jego plan, recenzja i notatka przekazania zostały usunięte; wnioski są poniżej.

- **Dostarczył:** wyszukiwanie w dashboardzie, bezpieczny zapis (partia plików sprawdzana przed zapisem), `specification/WORKFLOW.md` z regułą „nowsza przyjęta decyzja wygrywa”, tryb solo, poller tylko informujący, szablony i kontrolę linków.
- **Sprawdzone ponownie:** testy dashboardu 38/38, build, lint (0 błędów) i linki (357 celów, 0 brakujących) zgadzają się, a poprawki zapisu są zgodne z kodem. Wyjątek: test pollera przechodził **tylko w konsoli UTF-8** (poprawka w etapie 1).
- **Dobre strony:** wyniki automatu oddzielone od wyników człowieka, Markdown + Git zamiast bazy danych, jedna krótka instrukcja zamiast kilku sprzecznych.
- **Słabe strony:**
  - złe proporcje: kod dashboardu i około 50 KB planów powstały dla jednej osoby, a najcenniejsze kroki czekały;
  - żadna zmiana nie była w commicie, więc praca zależała od jednego dysku (naprawia etap 0), a decyzje nie trafiły do specyfikacji (etap 1);
  - dług w dashboardzie (skomplikowany stan zapisu w `store.tsx`, jedna karta edycyjna) poprawiamy dopiero wtedy, gdy zacznie przeszkadzać;
  - `CLAUDE.md` urósł do ponad 40 KB, choć miał się zmniejszyć. Przebieg dokumentacji z 2026-10-27 skrócił go do rdzenia 9 053 B; reszta jest w `docs/agent/README.md`, `tools/README.md` i specyfikacji.

---

## 8. Weryfikacja wcześniejszego planu

Tezy wcześniejszego planu agenta sprawdzono w kodzie, historii Git i źródłach (metoda na końcu dokumentu).

### 8.1 Co się potwierdziło

- **Proces:** 36 commitów z jednego konta, 0 tagów, 13 z 14 zmian poza oficjalną drogą przeglądu.
- **Fałszywe potwierdzenia testów:** 123 z 219 wierszy factchecków agent oznaczył jako „sprawdzone przez użytkownika” (`d39bbb9`). Korektę robił etap 1.
- **Gra:** bohater prawie nigdy nie jest „na krawędzi”; zakończenie zależy tylko od normy żył; horror jest w tekście (chód 5 m/s, jeden dźwięk kroków, szepty jako napisy, światło bez zmian z głębokością); `story_director.gd` ma około 107 warunków; tylko 3 ze 128 ID reguł są w kodzie lub testach. Trzy błędy z etapu 2 naprawiono w 0.5.3.

### 8.2 Co poprawiam

| Pisałem we wcześniejszym planie | Jest naprawdę |
|---|---|
| 5 commitów niewysłanych na serwer | **4** |
| Norma 12 żył „w południe dnia 4” | Szacunek ze starej tabeli. Nowy szacunek to dzień 3–5, a bot z 0.5.3 daje dzień 4, 13:00 – dzień 5, 15:30 (zob. [K1](#4-cele-mierzalne)). Żył jest 25, więc połowa mapy jest opcjonalna. |
| Tekla może spaść do 0 | Nie zejdzie niżej niż około 13. |
| Na oczach gracza łamią się 3 osoby | Przez poczytalność łamie się tylko **Mirosław**. Dobrawa kończy tydzień na około 20, więc jej załamanie to martwy kod; gorączka Nasira dotyczy zdrowia. |
| 49 sprzeczności; ~198 z 234 flag bez dokumentacji | Przykłady prawdziwe, liczb nie odtworzono; flag bez dokumentacji jest około 85%. |

### 8.3 Co upraszczam

Wcześniejszy plan (8 fal, 30 zadań) był zbyt ambitny dla jednej osoby z agentem. To rekomendacja, którą Roland może zawetować.

| Było w planie | Teraz |
|---|---|
| Osobna kopia robocza specyfikacji i gałęzie `agent/*` | Specyfikację edytujemy lokalnie według `WORKFLOW.md`, commit po lincie z 0 błędów. Czasowy wyjątek task_15 (kopia `specification-praca`, już usunięta) zastąpiła prośba Rolanda z 2026-10-26, zob. [D-16](#decyzje-z-task_15-d-16d-21). Kopia gry `everhorror-wdrozenie` zostaje. |
| Dziennik „Prace” i CLI `work/finalize/trace/review/report/doctor` | **Odkładamy.** Zostają tabele `WDROZENIA.md`. |
| Natychmiastowa archiwizacja `docs_v2/` i `MECHANICS.md` | Wykonana 2026-10-27 po przeniesieniu LoreDoc i rejestru zasobów do specyfikacji (specyfikacja `e8c899e`, obrazy `ca9832b`): `docs_v2/` usunięty (gra `bc68d01`; ostatnia treść: `10074fc`), `MECHANICS.md` w `docs/archiwum/` ([D-02](#decyzje-o-projekcie-i-procesie-d-01d-15)). |
| CI gry, osobna tożsamość agenta, hook przed pushem | **Opcjonalne.** Lint ręcznie. Tożsamość agenta w przebiegach z dashboardu: [D-19](#decyzje-z-task_15-d-16d-21). |
| Zawężenie uprawnień i podział `CLAUDE.md` w pierwszym tygodniu | Uprawnienia w etapie 4; podział `CLAUDE.md` zrobiono 2026-10-27. |
| „Wydarzenia jako dane” w 3 częściach | **Tylko część 1**, w etapie 7. |
| Pakiet „Ludzie”: Tekla, Racibor, Anzelm | Dochodzi naprawa Dobrawy. |
| Raport tygodniowy z CLI | Krótka notatka agenta przed przeglądem. |
| Dalszy rozwój dashboardu | Wstrzymany, tylko poprawki błędów. **Zastąpione** prośbą Rolanda z 2026-10-26 (orkiestracja zadań z dashboardu), zob. [D-16](#decyzje-z-task_15-d-16d-21). |

---

## 9. Decyzje i stałe zgody

Roland, czat 2026-10-26: „all decisions go as recommended”, czyli wszystkie decyzje zgodnie z rekomendacją. Poniżej ich treść, z uwzględnieniem uproszczeń z [§8.3](#83-co-upraszczam). Zapisano je w dzienniku decyzji w specyfikacji (karty D-03).

### Decyzje o projekcie i procesie (D-01…D-15)

| Karta | Decyzja | Etap |
|---|---|---|
| D-01 | Nowy sposób pracy: zasady z [§3](#3-zasady-które-obowiązują), krótki arkusz gry, zasada uczciwości wpisów. Zakres ograniczony przez [§8.3](#83-co-upraszczam). | 0–4 |
| D-02 | `docs/MECHANICS.md` i `docs_v2/` idą do archiwum; rejestr zasobów i tekst LoreDoc przechodzą do specyfikacji. Wykonane 2026-10-27: LoreDoc i rejestr w specyfikacji (specyfikacja `e8c899e`, obrazy `ca9832b`), `docs_v2/` usunięty z repozytorium (gra `bc68d01`; ostatnia treść w historii gita: `10074fc`), `MECHANICS.md` w `docs/archiwum/`. Taką formę archiwizacji zaproponował agent (rekomendacja, weto Rolanda). | 1, wykonane 2026-10-27 |
| D-03 | Karty decyzji trzymamy w `specification/zgloszenia/` jako „Rodzaj: decyzja”. | 1 |
| D-04 | Pakiet odczucia: ruch, światło według głębokości, szepty 3D, łagodniejsze podświetlenie, mikro-horror. Próba w Kostnicy odpada (wybór D4 = a, Roland, czat 2026-10-26). | 5 |
| D-05 | Presja: norma etapami, cena nocy, żyły ponad normę jako pokusa, rozmowy oddają czas. Liczby ustala bot. | 6 |
| D-06 | Ludzie: wspólne wstrząsy, załamania Tekli, Racibora i Anzelma, zapowiedzi, jedna szansa na odwrócenie. Teksty pisze agent, Roland może zawetować. | 7 |
| D-07 | Zakończenie zależy od losów ludzi: tytuł i pierwszy akapit. | 7 |
| D-08 | Nazwa: wybieramy przed stroną w sklepie. Do tego czasu „Everhorror”. Robocze kierunki: *Błękit, Bluevein, The Deep Vein, Sztolnia, Fourteen Marks, Czternasty* (motywy kopalni, głębi, szychty, Skarbnika i błękitu, działające po polsku i angielsku). | 9 |
| D-09 | Angielski: tak, tłumaczymy przy cięciu dema. Nowe teksty piszemy tak, żeby dało się je przetłumaczyć. | 9 |
| D-10 | `cave_ambient.mp3` i `steps.mp3` wymieniamy na CC0. | 5 |
| D-11 | Kanon: rok 1518, 40 lat przerwy, wątek Skarbnika, Czternasty nienazwany w grze. Dla „czyje myśli są w snach” i „czym jest kryształ” obowiązuje rekomendowany wariant po oknie weta. | 8 |
| D-12 | Główna oś fabuły: agent przygotowuje 2–3 i rekomenduje jedną, która obowiązuje po oknie weta. | 8 |
| D-13 | Demo publiczne obejmuje dni 1–3 i kończy się spotkaniem z Exitium (cliffhanger). | 9 |
| D-14 | „Wydarzenia jako dane”: tak, w częściach. Teraz tylko część 1. | 7 |
| D-15 | Automatyzacja: poller tylko powiadamia (zrobione), węższe uprawnienia, push po każdym scaleniu. CI gry jest opcjonalne. | 0, 4 |

### Decyzje o rozgrywce (D1–D10)

Roland, czat 2026-10-26: „1. a, 2. c, 3 a, 4 a, 5 a, 6 A”, „Reszta też jak rekomendowane”. Zapisane w `docs/human-tasks/done/decision-analiza-rozgrywki.md`.

| # | Pytanie | Decyzja | Etap |
|---|---|---|---|
| D1 | Presja w dniach 5–7 | Norma etapami: kontrole rano w dniach 4, 6 i 8, start 4/8/14, strojenie botem. | 6 |
| D2 | Więcej kruszących się ludzi | Wspólne wstrząsy i efekty zerowej poczytalności dla Tekli, Racibora i Anzelma. | 7 |
| D3 | Bohater częściej na krawędzi | Najpierw pomiar, strojenie po jednym zmierzonym tygodniu. | 4 → 6 |
| D4 | Horror w pierwszej osobie | **a)** Dźwięk zamiast tekstu. Bez próby w Kostnicy. | 5 |
| D5 | Ruch | 3,2 m/s, bezwładność, opcjonalne kołysanie głowy, kroki według podłoża, wolniej gdy ranny. | 5 |
| D6 | Światło według głębokości | Ciepły obóz, zimne tunele, na głębokości 3–4 tylko lampa i żyły. | 5 |
| D7 | Późny powrót | −3 poczytalności za rozpoczętą godzinę po 22:00; po północy pobudka o 7:00. | 6 |
| D8 | Podświetlenie | Łagodniejsze: przedmioty z cienkim konturem, postacie bez podświetlenia. | 5 |
| D9 | Zakończenia poza normą | Te same dwa ekrany, tytuł i pierwszy akapit zależne od losów. | 7 |
| D10 | Kolejność prac | Najpierw odczucie, potem balans na zmierzonych liczbach. | 5 → 6 |

Pytania zespołowe:
- etapy normy uzasadnia wózek z góry co dwa dni;
- teksty załamań pisze agent na podstawie propozycji z kart postaci;
- pytanie o Kostnicę odpada, bo próba 4b nie weszła do decyzji.

**Te decyzje nie obejmują:** wydatków (np. opłata Steam Direct, około 100 USD), publikacji (strona w sklepie, publiczne buildy, promocja) i zmian bezpieczeństwa poza D-15. Każda z tych rzeczy wymaga osobnego „tak”.

### Decyzje z task_15 (D-16…D-21)

Źródło: [`docs/ai-tasks/done/task_15.md`](../ai-tasks/done/task_15.md), sekcje „Decyzje i założenia” oraz „Czego potrzebuję od Ciebie”. Pozycje oznaczone „rekomendacja” agent przyjął w ramach polecenia „Reszta też jak rekomendowane” (Roland, czat 2026-10-26), więc Roland może je zawetować.

| Karta | Decyzja | Źródło |
|---|---|---|
| D-16 | Orkiestracja zadań i arkuszy z dashboardu (widok „Praca”). Zadania i arkusze zostają w `docs/`, stan liczy się z dokumentów i gita bez własnej bazy, pytania agenta to karty D-03, strefy człowieka mają jedną definicję składniową, a przebiegi agenta to lokalne `claude -p` na kliknięcie (jeden naraz, strażnik i audyt). Zastępuje w tym zakresie [§8.3](#83-co-upraszczam): „dalszy rozwój dashboardu wstrzymany”; „bez osobnej kopii roboczej” miało tylko czasowy wyjątek na task_15 (kopia `specification-praca`, już usunięta). Bez zmian: dziennik „Prace” odłożony, [§5](#5-czego-nie-robimy), jedna otwarta gałąź, scalanie tylko przez Rolanda, pełny zestaw testów za zgodą, agent nie wpisuje wyników człowieka. | prośba Rolanda, czat 2026-10-26 (`task_15.md`, D1–D14 projektu, w tym D13) |
| D-17 | Zmiany procesu: (a) arkusze człowieka żyją w `master` gry, nie na gałęziach `spec/*`, a zapis z dashboardu to commit jednego pliku podpisany wybraną osobą; (b) pytania z analizy zadań to karty decyzji D-03, nie `decision-task-NN.md`; (c) przebiegi z dashboardu nie commitują w grze, nie wypychają i nie tagują. | rekomendacja agenta (weto Rolanda), `task_15.md` pkt 1 |
| D-18 | Domyślne modele przebiegów: Opus z effort high dla planowania, analizy i przeglądu; Sonnet z effort high dla wdrożenia, poprawek i domknięcia; próba bez zmian (Sonnet low). Limity kosztu bez zmian. Zastępuje „Opus max i Sonnet max” z `task_15.md` pkt 3. Haiku jest dziś dostępny w oknie uruchomienia tylko jako „własny identyfikator”. Zmiana wartości w kodzie dashboardu (`RUN_KINDS`, `AGENT_LABELS`) idzie osobnym commitem w przebiegu dokumentacji. | Roland, czat 2026-10-27: „Używajmy w kolejnych zadaniach Opus 5.5 High, Haiku 5.5 Max albo Sonnet 5.5 High, żeby było szybciej” |
| D-19 | Tożsamość agenta w przebiegach z dashboardu to „Claude (agent)” z adresem `agent@everhorror.local`. Przebiegi działają na subskrypcji; płatne API tylko po `EVERHORROR_ALLOW_API_KEY=1`. | rekomendacja agenta (weto Rolanda), `task_15.md` pkt 4–5 |
| D-20 | Włączenie dashboardu do `master` specyfikacji i zapis dokumentów procesu w grze. Wykonane: dashboard w `88edde0`, dokumenty procesu w `2a155ce`. | rekomendacja agenta (weto Rolanda), `task_15.md` pkt 6–7 |
| D-21 | **Czeka na Rolanda.** Hasło administratora dashboardu (dziś puste), pierwsze płatne kliknięcie przebiegu („Sprawdź agenta”, grosze) oraz źródło i licencja `assets/logo.png` przed demem publicznym. Każda z tych rzeczy wymaga wyraźnego „tak”. | `task_15.md` pkt 8–9, D-10 |

### Decyzje z porządkowania dokumentacji (D-22…D-26)

Przebieg porządkowania dokumentacji z 2026-10-27 wykonał prośbę Rolanda o przegląd, aktualizację i redukcję rozproszonych dokumentów oraz o instrukcję obsługi dashboardu.

| Karta | Decyzja | Źródło |
|---|---|---|
| D-22 | Agent robi commity `[agent] proces: dokumentacja — …` w `master` gry i wypycha je po przeglądzie. To jednorazowy wyjątek od stałych zgód, tylko dla tego przebiegu. | Roland, czat 2026-10-26/27: prośba o wykonanie pracy łącznie z commitem i pushem |
| D-23 | Tabela „Zmiany agenta poza specyfikacją” nie dostaje nowych wierszy. Pilna poprawka błędu, który narusza istniejącą regułę, nie potrzebuje wiersza, bo przywraca zgodność. Każda inna zmiana najpierw trafia do specyfikacji jako ⬜. | rekomendacja agenta (weto Rolanda) |
| D-24 | Założenia agenta z task_05 w `09_produkcja.md` (np. „Norma to 12 z 25”) zostają do etapu 6 z dopiskiem „zweryfikuje D1/D-05”. | rekomendacja agenta (weto Rolanda) |
| D-25 | Czas sesji gry dla testera: do PT0 „1–3 godziny”. Jedną liczbę podamy po PT0. | rekomendacja agenta (weto Rolanda) |
| D-26 | LoreDoc (tekst Rena) jest przeniesiony do specyfikacji dosłownie. Pytanie, czy oryginał ma rozdział „Przystosowanie do Savage Worlds”, oraz poprawa usterek eksportu (H1 w L476, puste `###`) czekają na zgodę. | rekomendacja agenta (weto Rolanda) |

### Odłożone (bez decyzji)

- **Korekty specyfikacji do stanu gry.** Każda zmienia treść reguły i w dashboardzie wychodzi jako „do wdrożenia”, więc czeka na jedną zgodę i jeden commit `[agent]`: `welf.md:35` („rozmowa (1 h)”, w grze `[#free]`; brak +20 zaufania), `07_balans.md:82` (kąt +4) i `:134` (lista zaufania), ZAD-1 bez zakładki „Czas”, `00_gra.md` („Stan gry”, „dziesięć postaci”) oraz pochodzenie „Tekla [GDD]” i „Hanusz (LoreDoc)”.
- **Przyszłe zadanie narzędziowe dla dashboardu** (do otwarcia po PT0; do tego czasu redakcja plików reguł dająca fałszywe „do wdrożenia” czeka):
  - (a) zmiana samych linii meta („Stan na”) bez pozycji `tekst`;
  - (b) `01_swiat/LoreDoc.md` w `EDITORIAL_FILES`;
  - (c) reguły TECH-1…3 są dziś niewidoczne dla `/spec-tasks`, bo `08_technika.md` jest plikiem redakcyjnym;
  - (d) linie ❓ w listach numerowanych;
  - (e) wpis INSTRUKCJI w nawigacji aplikacji;
  - (f) etykieta „Szablon: zadanie”;
  - (g) rodzajowe stopki commitów (`Wpisał-`, `Scalił-`, `Zamknął-` …) i zdanie „Ten przebieg uruchomił …”;
  - (h) wtyczki użytkownika zsynchronizowane z kontem ładują się w przebiegach z dashboardu (ostrzeżenie przy starcie: „Wtyczki są załadowane: cc-plugin-…”);
  - (i) domknięcie zapisuje w `WDROZENIA.md` („Wpisy”) commit wdrożenia, więc własny commit domknięcia, który przestawia znaczniki, pokazuje się w dashboardzie jako fałszywe pozycje „do wdrożenia”.

### Stałe zgody dla agenta (Roland, 2026-10-26, D-01 i D-15)

**Wolno bez pytania:**
- commity na gałęziach `spec/*` w kopii roboczej `everhorror-wdrozenie`;
- commity `[agent]` w specyfikacji, po lincie z wynikiem 0 błędów;
- tag wersji i push `master` gry po scaleniu przez Rolanda, według [reguły tagów i pushy](#reguła-tagów-i-pushy);
- krótkie testy (`unit`, `lint`, `dialogue`, pojedynczy scenariusz).

Bieżące polecenie może ten zakres zawęzić.

**Trzeba zapytać Rolanda:**
- scalanie do `master` gry;
- force push i każde przepisywanie historii;
- pełny zestaw testów;
- wszystko publiczne, wydatki i ustawienia bezpieczeństwa (poza zawężeniem uprawnień z etapu 4).

**Zasady commitów:**
- prefiksy: `task_NN: …`, `fix: …`, `build: vX.Y.Z`, `[agent] …` (specyfikacja), `[agent] proces: …` (zmiany procesu, np. `[agent] proces: dokumentacja — …`, [D-22](#decyzje-z-porządkowania-dokumentacji-d-22d-26));
- zmiany procesu i praca nad grą nigdy w jednym commicie;
- żaden commit nie nazywa się po prostu „changes”.

### Reguła tagów i pushy

Jedna reguła dla wszystkich dokumentów i skilli:

- Agent stawia tag `vX.Y.Z` na commicie, z którego zbudowano zip, i wysyła go razem z `master` gry po scaleniu przez Rolanda.
- Przebiegi z dashboardu nie commitują w grze, nie wypychają i nie tagują.
- Opcja „tag i push” przy kliknięciu „Scal” robi to samo w imieniu Rolanda.

---

## 10. Słowniczek

| Pojęcie | Znaczenie |
|---|---|
| **Specyfikacja (spec)** | Repozytorium `specification/`: reguły gry z ID (np. `CZAS-3`) i znacznikami. Źródło prawdy o tym, co chcemy zbudować. |
| **Znaczniki w specyfikacji** | ✅ jest w grze · 🟡 częściowo · ⬜ ustalone, czeka na wdrożenie · 💡 propozycja · ❓ pytanie · ❌ do usunięcia |
| **`[ROBOCZE]`** | Treść napisana przez agenta, która czeka na przegląd człowieka. Obowiązuje dopiero po oknie weta. |
| **Okno weta** | Czas do najbliższego przeglądu Rolanda (zwykle raz w tygodniu), w którym Roland może odrzucić rekomendację. |
| **Factcheck / arkusz** | Plik w `docs/human-tasks/`, w którym człowiek zapisuje, co sprawdził w grze. Agent nie wpisuje tam wyników. |
| **PT0…PT4** | Kolejne sesje gry (playtesty). |
| **CP-0…CP-6** | Pakiety zmian gry z wcześniejszego planu: Pomiar, Odczucie, Wydarzenia jako dane, Presja, Ludzie, Fabuła, Pierwsza godzina. Tu odpowiadają im etapy 4–9. |
| **K1…K5** | Cele mierzalne z [§4](#4-cele-mierzalne). |
| **D-01…D-26, D1–D10** | Decyzje z [§9](#9-decyzje-i-stałe-zgody). D-16…D-21 pochodzą z task_15, D-22…D-26 z porządkowania dokumentacji. |
| **Baseline** | Commit specyfikacji, do którego gra jest w pełni wdrożona. Punkt odniesienia dla pytania, co się zmieniło od ostatniego wdrożenia. |
| **Bot balansu** | Skrypt, który sam „gra” tydzień bez świata gry i podaje, kiedy osiągnięto normę. |
| **Raport przebiegu** | Lokalny plik z czasem, żyłami i stanem ludzi z jednej rozgrywki. |
| **Dashboard / poller** | Dashboard to lokalna aplikacja do przeglądania i edycji specyfikacji. Poller to skrypt, który tylko raportuje stan, bez uruchamiania modelu. |
| **`everhorror` i `everhorror-wdrozenie`** | To samo repozytorium gry w dwóch folderach. Główna kopia jest na `master` i nigdy nie zmienia gałęzi. Druga kopia robocza (*git worktree*) służy agentowi do gałęzi `spec/*`. |
| **Gałąź `spec/*`** | Gałąź z kodem jednego zadania, w kopii `everhorror-wdrozenie`. |
| **Norma** | Dziś 12 żył błękitnego żelaza do końca dnia 7 (Racibor liczy rano w dniu 8). W etapie 6 zastąpi ją norma etapami (kontrole w dniach 4, 6 i 8). |
| **GDD** | Oryginalny dokument projektowy zespołu (`docs/GDD.md`). |

---

### Skąd te wnioski

- **Przeczytane dokumenty:** plan, recenzja i notatka przekazania drugiego modelu, `WORKFLOW.md` oraz wcześniejszy plan agenta.
- **Pomocnicy:**
  - jeden sprawdził deklaracje drugiego modelu i sam uruchomił testy, build, lint i kontrolę linków;
  - drugi zestawił oba plany;
  - trzeci przeprowadził research.
- **Weryfikacja wcześniejszego planu:** 20 agentów (10 weryfikatorów i 10 sceptyków) sprawdziło jego tezy w kodzie, historii Git i źródłach.
- **Przegląd tego dokumentu:** 12 agentów (2 świeżych czytelników, redaktor polszczyzny, krytyk struktury, sprawdzający fakty i krytyk spójności, każdy z własnym sceptykiem).
- **Pewność researchu:**
  - mocno potwierdzone: Markdown + Git, storylety, CI dla Godota;
  - ograniczona pewność: demo, ankiety i prędkość chodu w horrorach.
