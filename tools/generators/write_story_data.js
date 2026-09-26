// Usage (from project root): node tools/generators/write_story_data.js -> data/npc, data/notes, data/quests (.tres)
const fs = require("fs");
const esc = (s) => s.replace(/\\/g, "\\\\").replace(/"/g, '\\"').replace(/\n/g, "\\n");

// faction: 0 = Drudzy, 1 = Ekspedycja, 2 = Inna (script/data/npc_data.gd)
function npc(o) {
  fs.writeFileSync(`data/npc/${o.id}.tres`, `[gd_resource type="Resource" script_class="NpcData" format=3]

[ext_resource type="Script" path="res://script/data/npc_data.gd" id="1_script"]
[ext_resource type="PackedScene" path="res://scene/characters/${o.id}_model.tscn" id="2_model"]
[ext_resource type="Resource" path="res://dialogue/${o.id}.dialogue" id="3_dialogue"]

[resource]
script = ExtResource("1_script")
id = &"${o.id}"
display_name = "${esc(o.display_name)}"
dialogue_name = "${esc(o.dialogue_name)}"
display_name_instrumental = "${esc(o.instr)}"
faction = ${o.faction}
role = "${esc(o.role)}"
max_sanity = ${o.max_sanity}
start_sanity = ${o.start_sanity}
max_health = 100
start_reputation = 0
history = "${esc(o.history)}"
sanity_zero_effect = "${esc(o.zero)}"
model = ExtResource("2_model")
dialogue = ExtResource("3_dialogue")
portrait_eye_height = ${o.eye ?? 1.62}
female = ${o.eye === 1.57 ? "true" : "false"}
`);
}

function note(id, title, text) {
  fs.writeFileSync(`data/notes/${id}.tres`, `[gd_resource type="Resource" script_class="NoteData" format=3]

[ext_resource type="Script" path="res://script/data/note_data.gd" id="1_script"]

[resource]
script = ExtResource("1_script")
id = &"${id}"
title = "${esc(title)}"
text = "${esc(text)}"
`);
}

function quest(id, title, giver, entries) {
  const body = Object.entries(entries).map(([k, v]) => `"${k}": "${esc(v)}"`).join(",\n");
  fs.writeFileSync(`data/quests/${id}.tres`, `[gd_resource type="Resource" script_class="QuestData" format=3]

[ext_resource type="Script" path="res://script/data/quest_data.gd" id="1_script"]

[resource]
script = ExtResource("1_script")
id = &"${id}"
title = "${esc(title)}"
giver = "${esc(giver)}"
entries = {
${body}
}
`);
}

// --- NPC cards (GDD §5) ---
npc({
  id: "miroslaw", display_name: "Mirosław z Głuszy", dialogue_name: "Mirosław", instr: "Mirosławem", faction: 1,
  role: "Specjalista od materiałów wybuchowych", max_sanity: 50, start_sanity: 38,
  history: "Urodzony w 1490 roku. Jako dziesięciolatek jedyny przeżył rzeź, którą Pierwsi rozpętali w jego osadzie; dwa miesiące ukrywał się w piwnicy tawerny. Przygarnięty w Mirosil przez alchemika pracującego z prochem, stracił go w wybuchu zakładu. W wieku 16 lat trafił do kopalni i pracował z materiałami wybuchowymi.",
  zero: "W jednym z tuneli detonuje beczkę prochu razem ze sobą. Jego śmierć zamyka dostęp do 2–3 tuneli, które trzeba odblokować wybuchem.",
});
npc({
  id: "bolko", display_name: "Stary Bolko", dialogue_name: "Bolko", instr: "Bolkiem", faction: 1,
  role: "Górnik (najstarszy w ekspedycji)", max_sanity: 100, start_sanity: 80,
  history: "[ROBOCZE, do poprawki przez Rena] Najstarszy górnik w ekspedycji. Kopał w tej kopalni czterdzieści lat temu razem z dziadkiem bohatera i pamięta jego zwyczaje: szyfry, milczenie, samotne zejścia. Nieufny wobec nowych, ale lojalny wobec tych, którzy okażą szacunek.",
  zero: "[ROBOCZE] Przestaje odróżniać przeszłość od teraźniejszości: bierze bohatera za jego dziadka i prowadzi go w głąb.",
});
npc({
  id: "racibor", display_name: "Racibor, zarządca", dialogue_name: "Racibor", instr: "Raciborem", faction: 1,
  role: "Zarządca ekspedycji z nadania Kniazia", max_sanity: 100, start_sanity: 72,
  history: "[ROBOCZE] Były porucznik straży kniaziowskiej. Od dziesięciu lat pilnuje kopalń w Wąwozie w imieniu Kniazia. Dostał rozkaz: pierwsza dostawa błękitu za miesiąc. Nie wierzy w legendy. Wierzy w rozkazy, liczby i porządne stemple. Najbardziej boi się tego, co powie Kniaź, jeśli wróci z pustymi rękami.",
  zero: "[ROBOCZE] Zabiera raport i ucieka szybem na górę, zostawiając ekspedycję samą sobie. Bez niego nikt nie pilnuje zapasów ani nie śle wieści do Kniazia.",
});
npc({
  id: "tekla", display_name: "Tekla, kwatermistrzyni", dialogue_name: "Tekla", instr: "Teklą", faction: 2,
  role: "Kwatermistrzyni i kucharka z ramienia Konfraterni kupieckiej", max_sanity: 100, start_sanity: 85, eye: 1.57,
  history: "[ROBOCZE] Córka Hanusza, kupca z Mirosil. Konfraternia kupiecka zaopatruje ekspedycję w jedzenie, olej i liny, a Tekla pilnuje tego na miejscu i gotuje dla wszystkich. Po cichu ma też inne zadanie: kupić od górników trochę błękitu, zanim cały trafi do skarbca Kniazia. Jej ojciec robił to samo czterdzieści lat temu.",
  zero: "[ROBOCZE] Nocą zabiera zapasy i ucieka szybem. Obóz zostaje bez jedzenia i oleju do lamp.",
});
npc({
  id: "dobrawa", display_name: "Dobrawa z Initium", dialogue_name: "Dobrawa", instr: "Dobrawą", faction: 0,
  role: "Druga z Initium, badaczka energii", max_sanity: 60, start_sanity: 52, eye: 1.57,
  history: "[ROBOCZE] Urodziła się w Jaksarze, ale od dziecka należy do Initium. Przeszła przemianę w Maszynie, więc nosi żelazną maskę i rękawice: dotyk żywego człowieka jest dla niej niebezpieczny. Initium przysłało ją, kiedy doszły wieści o błękicie. Błękit nie powstaje sam, więc gdzieś pod kopalnią musi być artefakt. Dobrawa ma go znaleźć, zanim zrobi to ktoś inny.",
  zero: "[ROBOCZE] Schodzi sama w głąb, żeby dotknąć źródła energii. Nie wraca.",
});

// --- task_05: five people of the camp (LoreDoc, nobody important in the world) ---
npc({
  id: "wszebor", display_name: "Wszebor ze Śnieżnej Przystani", dialogue_name: "Wszebor", instr: "Wszeborem", faction: 1,
  role: "Rębacz, Hawiar z Czarnych Gór", max_sanity: 100, start_sanity: 76, eye: 1.78,
  history: "Hawiar ze Śnieżnej Przystani, rębacz i kowal. Wielki jak drzwi do stodoły, śmieje się tak, że sypie się strop. Od kiedy w kopalni pod Przystanią zasypało jego brata Bogdala, boi się ciasnych chodników, choć za nic się do tego nie przyzna. Zjechał tu, bo Kniaź płaci potrójnie, a wdowa po bracie ma czworo dzieci.",
  zero: "Ucieka z ciasnego chodnika i biegnie przed siebie w ciemność. Znajdują go po dwóch dniach w ślepym korytarzu. Siedzi w kącie i nuci kołysankę z Długiej Nocy.",
});
npc({
  id: "nasir", display_name: "Nasir z Bakaszu", dialogue_name: "Nasir", instr: "Nasirem", faction: 2,
  role: "Pompiarz i górnik z Sułtanatu Nerdii", max_sanity: 100, start_sanity: 72,
  history: "Nerdyjczyk z Bakaszu. Jako chłopak trafił do sułtańskich kamieniołomów za długi ojca. Wykupił się po dwunastu latach, podpatrując waldgrosseńskich inżynierów wodnych, aż umiał wypompować wodę z każdej dziury. Mówi, że gdzie woda, tam życie, a gdzie jej za dużo, tam śmierć. Na północy marznie od pierwszego dnia. Na szyi nosi szklany paciorek, który nazywa Dalekim Klejnotem.",
  zero: "Przestaje schodzić pod ziemię. Siada pod szybem, patrzy w kwadrat nieba i szepcze do Dżinów w swoim języku.",
});
npc({
  id: "hagiwara", display_name: "Kiyoshi Hagiwara", dialogue_name: "Hagiwara", instr: "Hagiwarą", faction: 2,
  role: "Pisarz ekspedycji, wygnaniec z Cesarstwa Czterech Wysp", max_sanity: 100, start_sanity: 80,
  history: "Urzędnik Ministerstwa Ziemi z gałęzi pomniejszego klanu na Shihon. Prowadził księgi kopalń na Nagate, gdzie pracują Szarzy. Kiedy wpisał do raportu prawdziwe liczby zamiast tych, których oczekiwał jego pan, stracił twarz, urząd i ojczyznę. Teraz prowadzi księgi Racibora. Liczby, powtarza, nie kłamią. Kłamią ludzie, którzy je zapisują.",
  zero: "Przestaje prowadzić księgi. Pisze za to wiersz, bez końca ten sam, na każdej kartce, jaką znajdzie.",
});
npc({
  id: "sobek", display_name: "Sobek z Wielkiego Stepu", dialogue_name: "Sobek", instr: "Sobkiem", faction: 1,
  role: "Egzarcha, najemnik, straż obozu", max_sanity: 100, start_sanity: 84,
  history: "Egzarcha ze stepu. Przez trzy zimy jeździł z bandą Gniewomira, aż znudziło mu się uciekać przed jaksarskimi patrolami. Teraz Racibor płaci mu za pilnowanie wyjścia i zapasów. Nosi zaklęty miecz, który tnie tylko wtedy, kiedy Sobek go karmi, i gra w kości z każdym, kto ma czym zapłacić. Drudzy nazywają go półmagiem. On ich nazywa gorzej.",
  zero: "Stwierdza, że nikt mu nie płaci za umieranie. Zabiera miecz, trochę zapasów i znika szybem na górę.",
});
npc({
  id: "anzelm", display_name: "Brat Anzelm", dialogue_name: "Anzelm", instr: "Anzelmem", faction: 2,
  role: "Felczer, były zakonnik Niebiańskiego Płomienia", max_sanity: 100, start_sanity: 64,
  history: "Pochodzi z Kinkengardu. Wstąpił do Zakonu Niebiańskiego Płomienia, żeby bronić ludzi przed magią, i przez dwa lata służył pod Wysokim Inkwizytorem Przemirem z Łask. Odszedł po egzekucji, o której nie chce mówić. Teraz leczy górników ziołami, wrzątkiem i modlitwą. Wszyscy wciąż mówią do niego „bracie”. Magii nie znosi, ludzi kocha, a siebie ledwo znosi.",
  zero: "Wraca do dawnej wiary w najgorszym wydaniu i próbuje wygnać z obozu wszystko, co ma w sobie magię. Zaczyna od Sabiny.",
});
// --- task_05: the Exitium expedition (Drudzy); Sabina stays in the camp from day 3 ---
npc({
  id: "sabina", display_name: "Sabina von Reuss", dialogue_name: "Sabina", instr: "Sabiną", faction: 0,
  role: "Druga z Exitium, laborantka i uzdrowicielka", max_sanity: 60, start_sanity: 48, eye: 1.57,
  history: "Najmłodsza w wyprawie Exitium, z waldgrosseńskiej rodziny, która oddała ją do Initium, kiedy miała sześć lat. Leczy zaklęciami drugiego kręgu i płaci za to bólem, jakby wkładała dłoń pod wrzątek. Dobra z natury i święcie przekonana, że bezmagicznym trzeba pomagać jak dzieciom. Von Brühl zostawił ją w obozie, żeby patrzyła Raciborowi na ręce.",
  zero: "Leczy tak długo, aż ból ją przerasta. Zamyka się w sobie i przestaje odpowiadać, zapatrzona w linie, które widzi tylko ona.",
});
npc({
  id: "ottokar", display_name: "Ottokar von Brühl", dialogue_name: "Ottokar", instr: "Ottokarem", faction: 0,
  role: "Przewodniczący rozwoju w Exitium, szef wyprawy Drugich", max_sanity: 60, start_sanity: 54,
  history: "Arystokrata z Waldgrossen, jeden z przewodniczących rozwoju w Exitium, od lat zajęty ruinami Onych. Chłodny, uprzejmy i pewny, że bezmagiczni to narzędzia, które czasem mówią. Szuka źródła błękitu, bo kto je znajdzie, zasiądzie w Wielkiej Radzie. Cofnie się tylko przed tym, co przyniosłoby mu wstyd w oczach innych magów.",
  zero: "Schodzi coraz niżej, sam, i przestaje wracać na noc.",
});
npc({
  id: "hieronim", display_name: "Hieronim z Grotthamu", dialogue_name: "Hieronim", instr: "Hieronimem", faction: 0,
  role: "Stary Drugi z Exitium, szaleniec wyprawy", max_sanity: 60, start_sanity: 10,
  history: "Najstarszy Drugi w Exitium. Przekroczył więcej progów bólu, niż ktokolwiek powinien, i coś w nim pękło. Nie nosi maski, bo i tak nikt go nie dotknie. Śmieje się, nuci, gada ze skałą. Najgorsze jest to, że skała czasem mu odpowiada. I często ma rację.",
  zero: "Odchodzi w głąb, nucąc. Jego śmiech słychać jeszcze przez trzy noce, coraz niżej.",
});
npc({
  id: "welf", display_name: "Welf von Hagen", dialogue_name: "Welf", instr: "Welfem", faction: 0,
  role: "Młody Drugi z Exitium", max_sanity: 60, start_sanity: 44,
  history: "Syn waldgrosseńskiego rodu, który ma więcej herbów niż pieniędzy. Dwa lata po Inicjacji i bardzo dumny z linii na przedramionach. Bezmagicznych uważa za gorszy gatunek ludzi, a siebie za kogoś, kogo w kopalni nic nie zaskoczy. Kopalnia ma na ten temat inne zdanie.",
  zero: "Wpada w panikę i ciska zaklęciami na oślep, aż ból zwala go z nóg.",
});

// --- Notes ---
note("notatka_dowodcy", "Notatka dowódcy poprzedniej ekipy",
  "Leżała na skrzyni w jaskini przy wejściu do obozu. Podpis rozmazany.\n\n„Dzień czternasty. Im niżej schodzimy, tym jaśniej świeci błękit w ścianach. Ludzie gadają przez sen, ale nie swoimi głosami. Jutro schodzimy niżej.”");
note("szyfr", "Kartka z szyfrem dziadka",
  "Leżała w jaskini za Starą sztolnią. Pismo dziadka, drobne i pochyłe.\n\nWŻSGC ŁKMŹA ĘTPRO\nBŃUFH ZYJŚD CEIOA\nŃRGŁT ĄPSWK MUŹYE\n\nNa dole jedno zdanie, którego nie zaszyfrował: „Nie idźcie za błękitem.”");
note("klucz", "Deska z wyrytymi znakami",
  "Deska przybita do stempla w zachodnim chodniku, zaraz za zawałem.\n\nKtoś wyrył na niej alfabet w dwóch rzędach, dolny przesunięty o siedem liter. W rogu znak dziadka: dwie skrzyżowane kreski i kropka.");
note("odszyfrowana", "Odszyfrowana wiadomość dziadka",
  "Przesunięcie o siedem liter. Dziadek nikomu nie ufał, ale szyfry miał proste.\n\n„Jeśli to czytasz, klucz przetrwał zawał. Błękit nie bierze się ze skały. On rośnie z Nich. Każda tona, którą wywozimy na górę, to kawałek Ich snu. Nie schodźcie niżej, niż musicie. Ja zejdę, bo ktoś musi Ich zobaczyć, zanim Oni zobaczą nas.”");
note("raport_archiwum", "Odpis z archiwum Kniazia",
  "Racibor dał mi go za raport o złożach. Stary papier, przepisany ręką kancelisty.\n\n„Raport sztygara Wita Grabca dla kancelarii Kniazia. Dostawy błękitu z dolnych chodników ustały. Czternastego dnia zeszliśmy sprawdzić, co się stało. Zejście do upadowej zasypane na kilka sążni. Strop nad zawałem cały, stemple całe. Kamienie okopcone jak od prochu. W składzie brakuje trzech beczek. Z ludzi brakuje tylko przewodnika. Górnicy mówią, że dzień wcześniej zszedł sam i już nie wrócił. Gadają o klątwie i nie chcą zjeżdżać. Wstrzymuję wydobycie do odwołania.”\n\nNa marginesie, ręką Racibora: „Klątwy nie wpisujemy do ksiąg.”");
note("list_konfraterni", "List z pieczęcią Konfraterni",
  "Był w tobołku Tekli, razem z ciężką sakiewką srebra.\n\n„Tekla, kupuj od górników błękit po dwa grosze za łut, nie drożej. Płać srebrem z sakiewki i nigdy przy zarządcy. Jeśli ktoś się dowie, nie znamy cię.”\n\nPod spodem pieczęć Konfraterni kupieckiej z Mirosil.");
note("slowniczek", "Słowniczek sanctinu",
  "Dobrawa przepisała mi kilka znaków sanctinu, języka, którym pisali Oni. Rysuje je rękawicą, bez jednego drżenia.\n\nGwiazda: niebo, to, co w górze. Oni przyszli z gwiazd.\nOko: widzieć, patrzeć.\nPłomień: ogień, gniew.\nKamień: skała, to, co w dole. Także: więzienie.\nSen, czyli znak zamkniętego oka: spoczynek, noc.\nDłoń: dotyk, dar.\n\n„Oni zawsze piszą od góry do dołu: skąd przyszli, co zrobili i czego zakazują.”");
note("list_dziadka", "Ostatni list dziadka",
  "Leżał w niszy za ścianą w kaplicy, owinięty w natłuszczone płótno. Pismo dziadka, tym razem bez szyfru.\n\n„Jeśli to czytasz, masz mój klucz i moją głowę do zagadek. Dobrze.\n\nWidziałem Ich. Leżą niżej, niż sięga najdłuższa lina, i śpią. Błękit to Ich oddech. Im bliżej, tym go więcej, a przy samym sercu ściany świecą jak w dzień.\n\nKniaź chce więcej. Więcej jest tylko tam, gdzie nie wolno kopać.\n\nKupiłem u Hanusza z Mirosil trzy beczki prochu. Jutro zejdę upadową i ją zasypię. Zostanę po tamtej stronie, żeby nikt nie poszedł moim śladem.\n\nKryształ zabierz stąd i nie oddawaj nikomu, kto nosi maskę albo koronę. Oni go szukają.\n\nTwój dziadek”");

note("zapiski_grabca", "Zeszyt sztygara Grabca",
  "Leżał w skrytce na końcu Przekopu Grabca, zawinięty w ceratę. Same liczby, pisane coraz krzywiej.\n\n„Dzień 9. Wozów 6.\nDzień 10. Wozów 5. Dwóch chorych.\nDzień 11. Wozów 4. Ludzie gadają przez sen. Nie swoimi głosami.\nDzień 12. Wozów 2. Przewodnik chodzi na dół sam. Mówi, że liczy. Pytam, co liczy. Nie odpowiada.\nDzień 13. Wozów 0. Przewodnik kupił proch. Nie wiem od kogo.\nDzień 14.”\n\nPo „Dniu 14” już nic. Ta sama liczba co kreski na skale w rząpiu.");
note("wiersz_hagiwary", "Wiersz Hagiwary",
  "Hagiwara napisał go pędzelkiem na skrawku papieru i dał mi w zamian za grzyb.\n\nPod górą, w czarnej\nziemi rośnie blade światło.\nNikt go nie sadził.\n\nMówi, że w Cesarstwie na koniec roku pali się takie kartki razem z życzeniami. Mam tego nie palić. „Tu nie ma końca roku. Tu jest tylko koniec tygodnia.”");

// --- Quests ---
quest("slady", "Ślady dziadka", "Moja sprawa", {
  start: "Dziadek przepadł w tej kopalni czterdzieści lat temu. Jego mapy znam na pamięć. Muszę się dowiedzieć, co się z nim stało.",
  szyfr: "W jaskini za Starą sztolnią znalazłem kartkę zapisaną jego szyfrem. Bez klucza nic z niej nie wyczytam.",
  wskazowka_bolka: "Bolko mówi, że dziadek zostawiał klucz „przy drodze”, a wiadomość „w głąb”. Skoro kartka była na wschodzie, klucz może być na zachodzie, za zawałem.",
  klucz: "Za zawałem znalazłem deskę z wyrytym alfabetem. To chyba klucz do szyfru.",
  odszyfrowane: "Odczytałem wiadomość dziadka. Pisze o Nich, o błękicie i o tym, że zszedł niżej.",
  archiwum: "Raport sprzed czterdziestu lat: zejście do upadowej zasypane, kamienie okopcone jak od prochu, a w składzie brakowało trzech beczek.",
  proch: "Tekla mówi, że jej ojciec sprzedał dziadkowi proch. Trzy beczki, tuż przed jego zniknięciem.",
  zawal: "Na dnie upadowej jest zawał. Kamienie okopcone, między nimi klepki z beczki. To nie wygląda na zwykłe tąpnięcie.",
  ladunek: "Mirosław mówi, że upadowej nie zawalił strop. Ktoś tam odpalił ładunek i znał się na rzeczy.",
  list: "W kaplicy dziadek zostawił mi list. Sam zasypał upadową i został po tamtej stronie.",
});
quest("lonty", "Lonty dla Mirosława", "Mirosław z Głuszy", {
  start: "Mirosław może wysadzić zawał na zachodzie, tylko że zamokły mu lonty. Stara ekipa miała skład w Starej sztolni.",
  znalezione: "W Starej sztolni znalazłem skrzynkę suchych lontów.",
  oddane: "Oddałem lonty Mirosławowi. Może wysadzić zawał, kiedy tylko zechcę, ale zejdzie mu na tym ze cztery godziny.",
  wysadzone: "Mirosław wysadził zawał. Zachodni chodnik jest otwarty.",
});
quest("zloza", "Złoża dla Kniazia", "Racibor, zarządca", {
  start: "Kniaź chce dwunastu żył błękitu na mapie do wieczora siódmego dnia. Mam je znaleźć i zaznaczyć. Za pierwsze dwie Racibor obiecał odpis z archiwum Kniazia.",
  rzapie: "Zaznaczyłem żyłę w rząpiu pod starym szybem.",
  upadowa: "Zaznaczyłem żyłę na dnie upadowej. Gruba jak ramię.",
  kaplica: "Zaznaczyłem żyłę w kaplicy. Cała ściana jest tam z błękitu.",
  zdane: "Zdałem pierwszy raport. Racibor dał mi odpis raportu sprzed czterdziestu lat. Do dwunastu jeszcze daleko.",
  norma: "Dwanaście żył. Norma Kniazia zrobiona.",
});
quest("towar", "Tobołek Tekli", "Tekla, kwatermistrzyni", {
  start: "Kiedy spuszczali zapasy starym szybem, Tekli urwał się tobołek i wpadł do rząpia. Mam go wyłowić i nikomu o tym nie mówić.",
  znaleziony: "Wyłowiłem tobołek. W środku sakiewka i list z pieczęcią Konfraterni kupieckiej. Tekla ma skupować błękit na lewo.",
  oddany: "Oddałem Tekli tobołek. Racibor o niczym nie wie.",
  wydany: "Oddałem tobołek Raciborowi. Tekla ma przez to kłopoty.",
});
quest("sciana", "Ściana w kaplicy", "Dobrawa z Initium", {
  start: "Dobrawa szuka kaplicy, o której pisze archiwum Initium. Na mapie dziadka pod jaskinią jest znak zapytania. To pewnie tam.",
  slownik: "Dobrawa przepisała mi kilka znaków sanctinu. Mówi, że Oni piszą od góry do dołu.",
  otwarta: "Rozwiązałem zagadkę ściany. W niszy leżał list dziadka i kryształ.",
  krysztal_dobrawa: "Oddałem kryształ Dobrawie.",
  krysztal_racibor: "Oddałem kryształ Raciborowi.",
  krysztal_moj: "Kryształ zostaje u mnie. Dziadek prosił, żeby nie oddawać go nikomu.",
});
// --- task_05 quests: items, people, the Drudzy ---
quest("kilof", "Kilof dla przewodnika", "Wszebor ze Śnieżnej Przystani", {
  start: "Wszebor mówi, że obozowe kilofy to miękkie jaksarskie żelazo. Stara ekipa miała hawiarskiego kowala, więc gdzieś w chodnikach mógł zostać porządny obuch. Wszebor osadzi go na nowym trzonku.",
  znaleziony: "W starym wyrobisku, pod wywróconym wózkiem, znalazłem obuch hawiarskiego kilofa.",
  oddany: "Oddałem obuch Wszeborowi. Do rana ma być gotowy.",
  gotowy: "Mam kilof. Wszebor twierdzi, że rozłupie nim nawet naciek, pod którym chowają się żyły.",
});
quest("pompy", "Pompy Nasira", "Nasir z Bakaszu", {
  start: "Nasir chce uruchomić stare pompy pod rząpiem. Za nimi jest zalany chodnik, a w zalanych chodnikach, mówi, zawsze coś się kryje. Potrzebuje oleju do tłoków.",
  olej: "Dałem Nasirowi olej. Od jutra w dzień będzie przy pompach. Mam do niego zajrzeć i pomóc przy korbie.",
  ruszyly: "Pompy ruszyły. Woda z zalanego chodnika powoli schodzi.",
});
quest("goraczka", "Gorączka Nasira", "Brat Anzelm", {
  start: "Nasir ma gorączkę. Anzelm mówi, że bez lekarstwa Nasir nie dociągnie do końca tygodnia, a lekarstwa w obozie prawie nie ma.",
  grzyb: "Anzelm uwarzy lekarstwo ze świecącego grzyba z groty, jeśli mu go przyniosę.",
  wyleczony: "Nasir wyzdrowiał. Przeżył północ i gorączkę, a to już dwa cuda.",
  wywieziony: "Nasira wywieźli na górę w gorączce. Nie zdążyłem.",
});
quest("wiersz", "Wiersz o świetle", "Kiyoshi Hagiwara", {
  start: "Hagiwara pisze wiersz o świetle, które rośnie w ciemności. Chciałby zobaczyć świecący grzyb z groty, o którym gadają górnicy.",
  oddany: "Dałem Hagiwarze świecący grzyb. Napisał wiersz i dał mi w zamian lekarstwo z Czterech Wysp.",
});
quest("zaklad", "Zakład z Sobkiem", "Sobek z Wielkiego Stepu", {
  start: "Sobek założył się ze mną, że do jutra wieczora nie zaznaczę trzech nowych żył. Stawką jest jego nalewka.",
  wygrany: "Wygrałem zakład. Sobek oddał nalewkę i przez pół dnia nie mógł przestać się śmiać.",
  przegrany: "Przegrałem zakład z Sobkiem. Na szczęście stawiał tylko on.",
});
quest("pokoj", "Brat i czarownica", "Anzelm i Sabina", {
  start: "Anzelm nie znosi Sabiny, a Sabina nie rozumie, czemu on nie chce jej pomocy przy chorych. Obozowi przydałby się spokój.",
  sabina: "Sabina obiecała, że nie będzie leczyć nikogo za plecami Anzelma.",
  zgoda: "Anzelm i Sabina pracują razem przy chorych. Nikt nie wierzył, że to możliwe.",
});
quest("oferta", "Oferta z Exitium", "Ottokar von Brühl", {
  start: "Ottokar von Brühl chce map dziadka. Albo kryształu. Za cenę, o jakiej mi się nie śniło.",
  krysztal: "Oddałem Ottokarowi kryształ. W zamian zaznaczył mi na mapie dwie żyły, do których sam bym nie trafił.",
  mapy: "Pokazałem Ottokarowi mapy dziadka. Przerysował je co do kreski, a w zamian zaznaczył mi jedną żyłę.",
  odmowa: "Odmówiłem Ottokarowi. Nie wyglądał na zaskoczonego. Wyglądał na kogoś, kto ma czas.",
});
quest("czternasty", "Czternaście kresek", "Moja sprawa", {
  start: "Czternaście kresek, wydrapanych w skale. Stara ekipa liczyła coś do czternastu i przestała. Chcę wiedzieć dlaczego.",
  kreski_rzapie: "Kreski w rząpiu: czternaście, grupami po pięć. Pod nimi zaczęte imię, urwane po trzech literach.",
  kreski_filar: "Na filarze w starym wyrobisku ten sam rachunek. Czternaście. Tyle dni kopali. Albo tylu ich było.",
  zeszyt: "Zeszyt sztygara Grabca kończy się na Dniu 14. Dalej są puste kartki. Papieru mu nie zabrakło.",
  chleb: "Ktoś zostawia zmarłym w kostnicy świeży chleb. Zmarli nie jedzą. Więc kto tu je?",
  lampka: "Lampka w kaplicy pali się, choć nikt z nas jej nie zapalał. Knot przycięty, olej świeży.",
  nisza: "W kostnicy jest czternaście nisz. Ostatnia jest pusta i podpisana imieniem, którego nie umiem przeczytać.",
  medalik: "Wstrząs otworzył szczelinę w Przekopie. W środku medalik starej ekipy, wypolerowany od dotyku. Ktoś go nosił długo po tym, jak przestali liczyć dni.",
  podarunek: "W nocy ktoś zostawił przy moim posłaniu starą górniczą lampę ze znakiem dziadka. Na szkle czternaście kresek. Nie przyszła tu z góry.",
});
quest("odlamek", "Odłamek dla Sabiny", "Sabina von Reuss", {
  start: "Sabina chce zbadać czysty błękit. Najczystszy ma być w Kryształowej galerii, najniżej na mapie.",
  oddany: "Dałem Sabinie odłamek z galerii. Pierwszy raz widziałem, jak Druga się cieszy. Tak mi się przynajmniej wydaje, pod maską.",
});
// --- task_09: Hrapek (card 02_postacie/hrapek.md by Roland; lines [ROBOCZE]) ---
npc({
  id: "hrapek", display_name: "Hrapek", dialogue_name: "Hrapek", instr: "Hrapkiem", faction: 2,
  role: "Rybak, potem górnik. Mieszka poziom niżej, w swoim pałacu", max_sanity: 100, start_sanity: 20, eye: 1.43,
  history: "Kiedyś łowił ryby, potem zjechał do kopalni i został na dole, kiedy zasypało chodnik. Przeżył na grzybach, które świecą i zmieniają tego, kto je je. Mówi wierszem, śmieje się, sprząta „cesarskie piwnice” i bohatera nazywa Cesarzem. Zadaj mu trzy pytania z rzędu, a ucieka.",
  zero: "Nie spada. Hrapek jest zawsze taki sam.",
});
quest("ryba", "Ryba dla Hrapka", "Hrapek", {
  start: "Hrapek, ten blady człowiek z chodników, jest głodny. Chce ryby. „Rybkę dla Hrapka, Cesarzu, rybkę!” Tekla może coś mieć. A Wszebor i Mirosław mówili o stawie w zalanym chodniku.",
  od_tekli: "Tekla dała mi suszoną rybę, po cichu. Za tobołek.",
  zlowiona: "Złowiliśmy rybę w stawie w zalanym chodniku. Ślepa i blada, ale ryba.",
  oddana: "Hrapek zjadł rybę razem z ośćmi. Mówił o NIM: ON czeka na dole, ON już raz mnie dopadł. Twierdzi, że mnie zna, tylko byłem starszy. Chyba pomylił mnie z dziadkiem.",
  za_pozno: "Nie zdążyłem z rybą. Hrapek nie żyje.",
});

console.log("data written");
