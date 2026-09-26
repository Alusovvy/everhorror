# Decyzje do task 09: Hrapek, zegar w notesie, wyszarzone opcje

> Zadanie: [task_09](../../ai-tasks/done/task_09.md) · Przygotowano: 2026-09-26 · Źródło: specyfikacja `54898e8` → `bccb0d9`
> **Status: rozstrzygnięte 2026-09-26.** Wszystkie 7 decyzji zgodnie z rekomendacją. Odpowiedzi na pytania do zespołu są w tekście. Wpisane do [task_09](../../ai-tasks/done/task_09.md).

## Decyzje

| # | Pytanie | Opcje | Rekomendacja | Twój wybór |
|---|---|---|---|---|
| 1 | **Jak wygląda spotkanie z Hrapkiem przy powrocie?** | **A.** Wybierasz na mapie [M] „Obóz”. Zanim ekran się ściemni, słychać szuranie i otwiera się rozmowa VN z żywym portretem Hrapka. Po niej powrót idzie dalej. **B.** Hrapek fizycznie stoi przy drogowskazie w miejscu, w którym jesteś, i zagadujesz go [E]. Wymaga ustawienia go w ok. 13 miejscach i pilnowania, żeby gracz go zauważył | **A**: pewne (gracz go nie przegapi), tanie i zgodne z kartą („przy powrocie”) |A |
| 2 | **Terminy spotkań** (karta: dzień 3 zawsze, potem 25%, min. 2 do dnia 7, ale ginie w dniu 6) | **a)** Pierwsze spotkanie przy pierwszym powrocie od dnia 3, jeśli zawał jest już wysadzony (jeśli nie, to przy pierwszym powrocie po wybuchu). Potem 25% przy każdym powrocie, najwyżej raz dziennie. Jeśli rano w dniu 5 bohater spotkał go mniej niż 2 razy, pierwszy powrót w dniu 5 daje spotkanie na pewno. Od dnia 6 Hrapek nie żyje. **b)** To samo, ale bez gwarancji w dniu 5 (może wyjść jedno spotkanie) | **a)**: spełnia „minimum 2 razy” mimo śmierci w dniu 6 |Dobra, to minimum 2 do dnia 5 |
| 3 | **Śmierć i ciało** | **a)** Hrapek umiera w nocy z dnia 5 na 6. Przy pierwszym powrocie w dniu 6 lub później scena VN: ciało w chodniku, opcje „Zabierz pierścień” / „Zostaw go”. Tylko jeśli spotkałeś go choć raz. **b)** Ciało leży fizycznie w chodniku przy wejściu do obozu, od dnia 6, do obejrzenia [E]. Zależy od nowego układu obozu z task_08 | **a)**: ta sama mechanika co spotkania. Przyczyna śmierci zostaje niedopowiedziana („jakby coś go dopadło”), kanon należy do Ren i Rolanda | Kanon należy do Ren, bo to ona, ale tak, bierzemy A |
| 4 | **Pierścień niewidzialności: czy coś robi?** | **a)** Tylko fabularnie: opis w plecaku i linijka w podsumowaniu tygodnia. **b)** Mechanicznie, np. z pierścieniem Drudzy nie spotykają cię w tunelach albo ON cię nie widzi (sny) | **a)** w demie. Działanie mechaniczne to decyzja projektowa na pełną grę | A |
| 5 | **Łowienie ryby (4 h ze Wszeborem albo Mirosławem)** | **a)** Opcja w rozmowie z nimi („Chodź ze mną na ryby”), kiedy masz zadanie. Mija 4 h, krótka narracja i dostajesz rybę. Staw leży w **Zalanym chodniku**: dopiszę go do opisu miejsca. **b)** To samo, ale staw w **Grzybowej grocie** (tam, gdzie grzyby Hrapka). **c)** Nowe miejsce „Staw” na mapie i prawdziwa wyprawa | **a)**: zgodne z NPC-11 (pomoc NPC to czas, a nie chodzenie za graczem), bez nowego miejsca | A |
| 6 | **Gdzie jeszcze widać godzinę, skoro znika z rogu ekranu?** | **a)** Tylko w notesie [J] (zakładka „Czas”) i w oknie rozmowy VN (DIA-1), bo tam gracz płaci czasem. **b)** Tylko w notesie. Z okna VN też znika. **c)** Notes, VN i stół z mapą (planowanie wyprawy) | **a)**: w rogu ekranu czysto, a przy decyzjach, które kosztują czas, godzina dalej jest widoczna | A|
| 7 | **Wyszarzone opcje: kto je widzi?** | **a)** Przełącznik w OPTIONS („Show locked choices”), domyślnie włączony na demo i testy. **b)** Zawsze włączone, bez przełącznika. **c)** Tylko w buildzie deweloperskim | **a)**: spełnia „do fazy testów i demo”, a później wystarczy przestawić domyślną wartość |A |

## Pytania do zespołu (nie blokują startu)
- **Rybak czy górnik?** Karta: rola „Były rybak”, historia „Górnik, który był uwięziony poziom niżej”. Przyjmuję: rybak z pochodzenia, potem górnik, stąd głód ryby. (Roland) - Tak to był rybak, który potem został górnikiem. Można zrobić że na pytanie kim był odpowie "Górnikiem... a nie nie nie, rybakiem!" czy coś takiego. 
- **Czy Hrapek ma coś wspólnego z „Czternastoma kreskami”?** Chleb w kostnicy, lampa przy posłaniu i stukanie za zawałem pasują do kogoś, kto od lat żyje na dole i zna dziadka. Demo o tym nie mówi, dopóki Ren nie zdecyduje. Czy to celowy fałszywy trop, prawdziwy trop, czy nie ma związku? Narazie to zostawimy.
- **Amulet („już tak działa”).** Dziś amulet działa tylko w tekstach: grzeje się we śnie, przy ścianie i przy Ottokarze, parzy przy złej odpowiedzi na ścianie. Nie podpowiada żył ani rozwiązań. Jeśli to wystarczy, zapiszę w specyfikacji „działanie fabularne” i zamknę pytanie. Jeśli miał podpowiadać, to osobne zadanie.
 Może będzie podpowiadał, do ustalenia
## Czego nie trzeba decydować (zrobię tak)
- **Wiersz bez gwary.** Hrapek mówi własnym językiem (wierszem), bez śląskiej wersji. Test gwary obejmuje tylko Mirosława i Bolka. Kwestie piszę sam jako [ROBOCZE] do przejrzenia przez Rolanda i Ren, chyba że Roland chce je napisać.
- **Trzy pytania z rzędu:**
  - liczą się tylko pytania w jednej rozmowie,
  - na trzecie Hrapek nie odpowiada, tylko mówi swoją kwestię i ucieka,
  - oddanie ryby i pożegnanie nie liczą się jako pytania,
  - przy następnym spotkaniu licznik zaczyna od zera.
- **Wygląd** z części Quaternius: łysy, blady, bez koszuli, w podartych portkach, skulony, trochę mniejszy. Bez nowego modelu.
- **Warunek zawału:** osobna, trwała flaga `hrapek_free`, ustawiana przy wybuchu. Dzisiejsza `west_blasted` znika po śmierci Mirosława, a z nią zniknąłby Hrapek.
- **Ryba** zużywa się przy oddaniu (karta mówi „nie”, poprawię). Tekla daje ją raz.
- **Dziennik czasu** obejmuje cały tydzień, najnowszy dzień na górze, z sumą dnia. Jest w zapisie gry. Starsze zapisy wczytują się z pustym dziennikiem.
- **Opcje-spoilery:** opcjom, które wymagają samego przedmiotu, a pokazywałyby się za wcześnie (np. „Mam twój tobołek” od dnia 1), dopiszę warunek zadania.
