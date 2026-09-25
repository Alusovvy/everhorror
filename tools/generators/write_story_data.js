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
  start: "Racibor chce wiedzieć, gdzie jest błękit. Mam znaczyć żyły w nowych chodnikach i zdać mu raport. Za dwie żyły obiecał odpis z archiwum Kniazia.",
  rzapie: "Zaznaczyłem żyłę w rząpiu pod starym szybem.",
  upadowa: "Zaznaczyłem żyłę na dnie upadowej. Gruba jak ramię.",
  kaplica: "Zaznaczyłem żyłę w kaplicy. Cała ściana jest tam z błękitu.",
  zdane: "Zdałem raport. Racibor dał mi odpis raportu sprzed czterdziestu lat.",
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
console.log("data written");
