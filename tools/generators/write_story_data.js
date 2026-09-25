// Usage (from project root): node tools/generators/write_story_data.js -> data/npc, data/notes, data/quests (.tres)
const fs = require("fs");
const esc = (s) => s.replace(/\\/g, "\\\\").replace(/"/g, '\\"').replace(/\n/g, "\\n");

function npc(file, o) {
  fs.writeFileSync(file, `[gd_resource type="Resource" script_class="NpcData" format=3]

[ext_resource type="Script" path="res://script/data/npc_data.gd" id="1_script"]
[ext_resource type="PackedScene" path="${o.model}" id="2_model"]
[ext_resource type="Resource" path="${o.dialogue}" id="3_dialogue"]

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
portrait_eye_height = 1.62
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

npc("data/npc/miroslaw.tres", {
  id: "miroslaw", display_name: "Mirosław z Głuszy", dialogue_name: "Mirosław", instr: "Mirosławem", faction: 1,
  role: "Specjalista od materiałów wybuchowych", max_sanity: 50, start_sanity: 38,
  model: "res://scene/characters/miroslaw_model.tscn", dialogue: "res://dialogue/miroslaw.dialogue",
  history: "Urodzony w 1490 roku. Jako dziesięciolatek jedyny przeżył rzeź, którą Pierwsi rozpętali w jego osadzie; dwa miesiące ukrywał się w piwnicy tawerny. Przygarnięty w Mirosil przez alchemika pracującego z prochem, stracił go w wybuchu zakładu. W wieku 16 lat trafił do kopalni i pracował z materiałami wybuchowymi.",
  zero: "W jednym z tuneli detonuje beczkę prochu razem ze sobą. Jego śmierć zamyka dostęp do 2–3 tuneli, które trzeba odblokować wybuchem.",
});
npc("data/npc/bolko.tres", {
  id: "bolko", display_name: "Stary Bolko", dialogue_name: "Bolko", instr: "Bolkiem", faction: 1,
  role: "Górnik (najstarszy w ekspedycji)", max_sanity: 100, start_sanity: 80,
  model: "res://scene/characters/bolko_model.tscn", dialogue: "res://dialogue/bolko.dialogue",
  history: "[ROBOCZE, do poprawki przez Rena] Najstarszy górnik w ekspedycji. Kopał w tej kopalni czterdzieści lat temu razem z dziadkiem bohatera i pamięta jego zwyczaje: szyfry, milczenie, samotne zejścia. Nieufny wobec nowych, ale lojalny wobec tych, którzy okażą szacunek.",
  zero: "[ROBOCZE] Przestaje odróżniać przeszłość od teraźniejszości: bierze bohatera za jego dziadka i prowadzi go w głąb.",
});

note("notatka_dowodcy", "Notatka dowódcy poprzedniej ekipy",
  "Leżała na skrzyni w jaskini przy wejściu do obozu. Podpis rozmazany.\n\n„Dzień czternasty. Im niżej schodzimy, tym jaśniej świeci błękit w ścianach. Ludzie gadają przez sen, ale nie swoimi głosami. Jutro schodzimy niżej.”");
note("szyfr", "Kartka z szyfrem dziadka",
  "Leżała w jaskini za Starą sztolnią. Pismo dziadka, drobne i pochyłe.\n\nWŻSGC ŁKMŹA ĘTPRO\nBŃUFH ZYJŚD CEIOA\nŃRGŁT ĄPSWK MUŹYE\n\nNa dole jedno zdanie, którego nie zaszyfrował: „Nie idźcie za błękitem.”");
note("klucz", "Deska z wyrytymi znakami",
  "Deska przybita do stempla w zachodnim chodniku, zaraz za zawałem.\n\nKtoś wyrył na niej alfabet w dwóch rzędach, dolny przesunięty o siedem liter. W rogu znak dziadka: dwie skrzyżowane kreski i kropka.");
note("odszyfrowana", "Odszyfrowana wiadomość dziadka",
  "Przesunięcie o siedem liter. Dziadek nikomu nie ufał, ale szyfry miał proste.\n\n„Jeśli to czytasz, klucz przetrwał zawał. Błękit nie bierze się ze skały. On rośnie z Nich. Każda tona, którą wywozimy na górę, to kawałek Ich snu. Nie schodźcie niżej, niż musicie. Ja zejdę, bo ktoś musi Ich zobaczyć, zanim Oni zobaczą nas.”");

quest("slady", "Ślady dziadka", "Moja sprawa", {
  start: "Dziadek przepadł w tej kopalni czterdzieści lat temu. Jego mapy znam na pamięć. Muszę się dowiedzieć, co się z nim stało.",
  szyfr: "W jaskini za Starą sztolnią znalazłem kartkę zapisaną jego szyfrem. Bez klucza nic z niej nie wyczytam.",
  wskazowka_bolka: "Bolko mówi, że dziadek zostawiał klucz „przy drodze”, a wiadomość „w głąb”. Skoro kartka była na wschodzie, klucz może być na zachodzie, za zawałem.",
  klucz: "Za zawałem znalazłem deskę z wyrytym alfabetem. To chyba klucz do szyfru.",
  odszyfrowane: "Odczytałem wiadomość dziadka. Pisze o Nich, o błękicie i o tym, że zszedł niżej.",
});
quest("lonty", "Lonty dla Mirosława", "Mirosław z Głuszy", {
  start: "Mirosław może wysadzić zawał na zachodzie, tylko że zamokły mu lonty. Stara ekipa miała skład w Starej sztolni.",
  znalezione: "W Starej sztolni znalazłem skrzynkę suchych lontów.",
  oddane: "Oddałem lonty Mirosławowi. Może wysadzić zawał, kiedy tylko zechcę, ale zejdzie mu na tym ze cztery godziny.",
  wysadzone: "Mirosław wysadził zawał. Zachodni chodnik jest otwarty.",
});
console.log("data written");
