# Rejestr flag

> Plik generowany: nie edytować ręcznie. Źródło: `reports/flags.tsv` (zapisuje `tools/run_tests.sh lint`), generator: `node tools/generators/write_flags_doc.js`.

Flag z literalną nazwą w źródłach: 241, z rodzin składanych w czasie gry: 11. „Ładunek: tak” znaczy, że flaga trzyma wartość inną niż `true` (miejsce, dzień, listę; `mark_today` i `bump_flag` zawsze). Brak „Czytana w” to flaga tylko zapisywana (ostrzeżenie lintu) albo czytana wyłącznie z nazwy składanej w czasie gry.

## Flagi

| Flaga | Ustawiana w | Czytana w | Ładunek |
|---|---|---|---|
| `<name>` | — | `script/data/location_data.gd`, `script/expeditions.gd` | nie |
| `announcement_done` | `script/story_director.gd` | `dialogue/racibor.dialogue`, `script/story_director.gd` | nie |
| `anz_hello` | `dialogue/anzelm.dialogue` | `dialogue/anzelm.dialogue` | tak |
| `anz_on_sabina` | `dialogue/anzelm.dialogue` | `dialogue/anzelm.dialogue` | nie |
| `anz_order` | `dialogue/anzelm.dialogue` | `dialogue/anzelm.dialogue` | nie |
| `anzelm_bandage` | `dialogue/anzelm.dialogue` | `dialogue/anzelm.dialogue` | tak |
| `anzelm_brew_given` | `dialogue/anzelm.dialogue` | `dialogue/anzelm.dialogue` | nie |
| `anzelm_brewing_day` | `dialogue/anzelm.dialogue` | `dialogue/anzelm.dialogue` | tak |
| `anzelm_care` | `dialogue/anzelm.dialogue`, `script/game_state.gd` | `dialogue/anzelm.dialogue`, `script/game_state.gd` | tak |
| `anzelm_sabina_peace` | `dialogue/anzelm.dialogue` | `dialogue/anzelm.dialogue`, `dialogue/sabina.dialogue`, `script/camp_schedule.gd`, `script/run_report.gd`, `script/story_director.gd` | nie |
| `bet_day` | `dialogue/sobek.dialogue` | `dialogue/sobek.dialogue` | tak |
| `bet_target` | `dialogue/sobek.dialogue` | `dialogue/sobek.dialogue` | tak |
| `bolko_asked_blast` | `dialogue/bolko.dialogue` | `dialogue/bolko.dialogue` | nie |
| `bolko_asked_dobrawa` | `dialogue/bolko.dialogue` | `dialogue/bolko.dialogue` | nie |
| `bolko_asked_first` | `dialogue/bolko.dialogue` | `dialogue/bolko.dialogue` | nie |
| `bolko_asked_grandpa` | `dialogue/bolko.dialogue` | `dialogue/bolko.dialogue` | nie |
| `bolko_asked_tekla` | `dialogue/bolko.dialogue` | `dialogue/bolko.dialogue` | nie |
| `bolko_asked_why` | `dialogue/bolko.dialogue` | `dialogue/bolko.dialogue` | nie |
| `bolko_day2_secret` | `dialogue/bolko.dialogue` | — | nie |
| `bolko_greet` | `dialogue/bolko.dialogue` | `dialogue/bolko.dialogue` | tak |
| `bolko_guilt` | `dialogue/bolko.dialogue` | `dialogue/bolko.dialogue` | nie |
| `bolko_guilt_said` | `dialogue/bolko.dialogue` | `dialogue/bolko.dialogue` | nie |
| `bolko_hint` | `dialogue/bolko.dialogue` | `dialogue/bolko.dialogue` | nie |
| `bolko_knows_fate` | `dialogue/bolko.dialogue` | `dialogue/bolko.dialogue`, `dialogue/racibor.dialogue`, `script/story_director.gd` | nie |
| `bolko_lamp_said` | `dialogue/bolko.dialogue` | `dialogue/bolko.dialogue` | nie |
| `bolko_on_sabina` | `dialogue/bolko.dialogue` | `dialogue/bolko.dialogue` | nie |
| `bolko_on_wszebor` | `dialogue/bolko.dialogue` | `dialogue/bolko.dialogue` | nie |
| `bolko_relieved` | `dialogue/bolko.dialogue` | `dialogue/bolko.dialogue`, `dialogue/racibor.dialogue`, `script/story_director.gd` | nie |
| `bolko_relieved_day` | `dialogue/bolko.dialogue` | `dialogue/bolko.dialogue` | tak |
| `bolko_relieved_said` | `dialogue/bolko.dialogue` | `dialogue/bolko.dialogue` | nie |
| `bolko_told_chapel` | `dialogue/bolko.dialogue` | `dialogue/bolko.dialogue` | nie |
| `bolko_tremor` | `dialogue/bolko.dialogue` | `dialogue/bolko.dialogue` | nie |
| `campfire` | `dialogue/ognisko.dialogue` | `script/story_director.gd` | tak |
| `crystal_to_dobrawa` | `dialogue/dobrawa.dialogue` | `dialogue/racibor.dialogue`, `script/run_report.gd`, `script/story_director.gd` | nie |
| `crystal_to_ottokar` | `dialogue/ottokar.dialogue` | `dialogue/dobrawa.dialogue`, `dialogue/racibor.dialogue`, `script/run_report.gd`, `script/story_director.gd` | nie |
| `crystal_to_racibor` | `dialogue/racibor.dialogue` | `dialogue/dobrawa.dialogue`, `script/run_report.gd`, `script/story_director.gd` | nie |
| `deciphered` | `dialogue/bolko.dialogue`, `dialogue/system.dialogue`, `script/story_director.gd` | `dialogue/bolko.dialogue`, `dialogue/drudzy.dialogue`, `dialogue/system.dialogue`, `script/story_director.gd` | nie |
| `dob_asked_carts` | `dialogue/dobrawa.dialogue` | `dialogue/dobrawa.dialogue` | nie |
| `dob_asked_crystal` | `dialogue/dobrawa.dialogue` | `dialogue/dobrawa.dialogue` | nie |
| `dob_asked_pain` | `dialogue/dobrawa.dialogue` | `dialogue/dobrawa.dialogue` | nie |
| `dob_asked_sleep` | `dialogue/dobrawa.dialogue` | `dialogue/dobrawa.dialogue` | nie |
| `dob_asked_why` | `dialogue/dobrawa.dialogue` | `dialogue/dobrawa.dialogue` | nie |
| `dob_day3` | `dialogue/dobrawa.dialogue` | `dialogue/dobrawa.dialogue` | nie |
| `dob_greet` | `dialogue/dobrawa.dialogue` | `dialogue/dobrawa.dialogue` | tak |
| `dob_on_exitium` | `dialogue/dobrawa.dialogue` | `dialogue/dobrawa.dialogue` | nie |
| `dob_told_wall` | `dialogue/dobrawa.dialogue` | `dialogue/dobrawa.dialogue` | nie |
| `dobrawa_leaving` | `dialogue/dobrawa.dialogue`, `script/story_director.gd` | `script/story_director.gd` | nie |
| `dobrawa_left` | `script/story_director.gd` | `dialogue/racibor.dialogue`, `script/camp_schedule.gd`, `script/run_report.gd`, `script/story_director.gd` | nie |
| `dobrawa_went_down` | `script/story_director.gd` | `script/run_report.gd`, `script/story_director.gd` | nie |
| `dream_decipher_seen` | `dialogue/system.dialogue` | `dialogue/system.dialogue` | nie |
| `drudzy_met` | `script/story_director.gd` | `dialogue/dobrawa.dialogue`, `dialogue/hagiwara.dialogue`, `dialogue/miroslaw.dialogue`, `dialogue/racibor.dialogue`, `dialogue/sobek.dialogue`, `dialogue/system.dialogue`, `script/field_schedule.gd`, `script/notebook.gd`, `script/run_report.gd`, `script/story_director.gd` | nie |
| `drudzy_met_at` | `script/story_director.gd` | — | tak |
| `drudzy_seen` | `script/story_director.gd` | `script/story_director.gd` | tak |
| `dwie_drugie` | `dialogue/dobrawa.dialogue` | `dialogue/dobrawa.dialogue` | nie |
| `encounter_npcs` | `script/story_director.gd` | `script/field_schedule.gd`, `script/story_director.gd` | tak |
| `encounter_place` | `script/story_director.gd` | `script/field_schedule.gd`, `script/story_director.gd` | tak |
| `found_cipher` | `tools/generators/gen_mine_deep.gd` | — | nie |
| `found_key` | `tools/generators/gen_camp.gd` | — | nie |
| `fourteenth_gift` | `script/story_director.gd` | `dialogue/system.dialogue`, `script/run_report.gd`, `script/story_director.gd` | nie |
| `fuses_delivered` | `dialogue/miroslaw.dialogue` | `dialogue/miroslaw.dialogue` | nie |
| `got_rope` | `dialogue/racibor.dialogue`, `dialogue/tekla.dialogue` | — | nie |
| `hag_asked_home` | `dialogue/hagiwara.dialogue` | `dialogue/hagiwara.dialogue` | nie |
| `hag_asked_lie` | `dialogue/hagiwara.dialogue` | `dialogue/hagiwara.dialogue` | nie |
| `hag_drudzy` | `dialogue/hagiwara.dialogue` | `dialogue/hagiwara.dialogue` | nie |
| `hag_empire` | `dialogue/hagiwara.dialogue` | `dialogue/hagiwara.dialogue` | nie |
| `hag_exile` | `dialogue/hagiwara.dialogue` | `dialogue/hagiwara.dialogue` | nie |
| `hag_hello` | `dialogue/hagiwara.dialogue` | `dialogue/hagiwara.dialogue` | tak |
| `hier_count` | `dialogue/hieronim.dialogue` | `dialogue/hieronim.dialogue` | tak |
| `hrapek_dead` | `script/story_director.gd` | `script/run_report.gd`, `script/story_director.gd` | nie |
| `hrapek_found` | `dialogue/hrapek.dialogue` | `script/run_report.gd`, `script/story_director.gd` | nie |
| `hrapek_free` | `script/story_director.gd` | `script/story_director.gd` | nie |
| `hrapek_left` | `dialogue/hrapek.dialogue` | — | nie |
| `hrapek_meetings` | `script/story_director.gd` | `dialogue/hrapek.dialogue`, `script/story_director.gd` | tak |
| `hrapek_q` | `dialogue/hrapek.dialogue`, `script/game_state.gd`, `script/story_director.gd` | — | tak |
| `hrapek_ring` | `dialogue/hrapek.dialogue` | `script/run_report.gd`, `script/story_director.gd` | nie |
| `hrapek_seen` | `script/story_director.gd` | `script/story_director.gd` | tak |
| `hrapek_told_emperor` | `dialogue/hrapek.dialogue` | `dialogue/hrapek.dialogue` | nie |
| `hrapek_told_food` | `dialogue/hrapek.dialogue` | `dialogue/hrapek.dialogue` | nie |
| `hrapek_told_grandfather` | `dialogue/hrapek.dialogue` | `dialogue/hrapek.dialogue` | nie |
| `hrapek_told_palace` | `dialogue/hrapek.dialogue` | `dialogue/hrapek.dialogue` | nie |
| `hrapek_told_past` | `dialogue/hrapek.dialogue` | `dialogue/hrapek.dialogue` | nie |
| `hrapek_told_work` | `dialogue/hrapek.dialogue` | `dialogue/hrapek.dialogue` | nie |
| `intro_done` | `script/story_director.gd` | `script/story_director.gd` | nie |
| `kaplica_known` | `dialogue/bolko.dialogue`, `dialogue/dobrawa.dialogue`, `script/story_director.gd` | `tools/generators/write_world_data.js` | nie |
| `location` | `script/story_director.gd` | `script/game_state.gd` | tak |
| `met_anzelm` | `dialogue/anzelm.dialogue` | `dialogue/anzelm.dialogue` | nie |
| `met_bolko` | `dialogue/bolko.dialogue` | `dialogue/bolko.dialogue` | nie |
| `met_dobrawa` | `dialogue/dobrawa.dialogue` | `dialogue/dobrawa.dialogue` | nie |
| `met_hagiwara` | `dialogue/hagiwara.dialogue` | `dialogue/hagiwara.dialogue` | nie |
| `met_hrapek` | `script/story_director.gd` | `script/run_report.gd`, `script/story_director.gd` | nie |
| `met_miroslaw` | `dialogue/miroslaw.dialogue` | `dialogue/miroslaw.dialogue` | nie |
| `met_nasir` | `dialogue/nasir.dialogue` | `dialogue/nasir.dialogue` | nie |
| `met_ottokar_field` | `dialogue/ottokar.dialogue` | `dialogue/ottokar.dialogue` | nie |
| `met_racibor` | `dialogue/racibor.dialogue` | `dialogue/hagiwara.dialogue`, `dialogue/miroslaw.dialogue`, `dialogue/racibor.dialogue` | nie |
| `met_sabina_camp` | `dialogue/sabina.dialogue` | `dialogue/sabina.dialogue` | nie |
| `met_sobek` | `dialogue/sobek.dialogue` | `dialogue/sobek.dialogue` | nie |
| `met_tekla` | `dialogue/tekla.dialogue` | `dialogue/bolko.dialogue`, `dialogue/tekla.dialogue` | nie |
| `met_wszebor` | `dialogue/wszebor.dialogue` | `dialogue/bolko.dialogue`, `dialogue/wszebor.dialogue` | nie |
| `mir_asked_collapse` | `dialogue/miroslaw.dialogue` | `dialogue/bolko.dialogue`, `dialogue/miroslaw.dialogue` | nie |
| `mir_asked_drudzy` | `dialogue/miroslaw.dialogue` | `dialogue/miroslaw.dialogue` | nie |
| `mir_asked_past` | `dialogue/miroslaw.dialogue` | `dialogue/miroslaw.dialogue` | nie |
| `mir_asked_racibor` | `dialogue/miroslaw.dialogue` | `dialogue/miroslaw.dialogue` | nie |
| `mir_comforted` | `dialogue/miroslaw.dialogue` | `dialogue/miroslaw.dialogue`, `script/run_report.gd`, `script/story_director.gd` | nie |
| `mir_company` | `dialogue/miroslaw.dialogue`, `dialogue/ognisko.dialogue` | `dialogue/miroslaw.dialogue`, `script/story_director.gd` | tak |
| `mir_day2_comfort` | `dialogue/miroslaw.dialogue` | `dialogue/miroslaw.dialogue` | nie |
| `mir_dead` | `script/story_director.gd` | `script/run_report.gd`, `tools/generators/write_world_data.js` | nie |
| `mir_drink` | `dialogue/miroslaw.dialogue` | `dialogue/miroslaw.dialogue` | tak |
| `mir_greet` | `dialogue/miroslaw.dialogue` | `dialogue/miroslaw.dialogue` | tak |
| `mir_night_blast_done` | `script/story_director.gd` | `script/story_director.gd` | nie |
| `mir_saw_charge` | `dialogue/miroslaw.dialogue` | `dialogue/miroslaw.dialogue`, `dialogue/racibor.dialogue`, `script/story_director.gd` | nie |
| `mir_scolded` | `dialogue/miroslaw.dialogue` | `dialogue/miroslaw.dialogue`, `script/run_report.gd` | nie |
| `mir_support` | `dialogue/miroslaw.dialogue` | `dialogue/miroslaw.dialogue` | tak |
| `mir_support_answered` | `dialogue/miroslaw.dialogue` | `dialogue/miroslaw.dialogue` | nie |
| `mir_support_day` | `dialogue/miroslaw.dialogue` | `dialogue/miroslaw.dialogue` | tak |
| `nas_asked_story` | `dialogue/nasir.dialogue` | `dialogue/nasir.dialogue` | nie |
| `nas_djinn` | `dialogue/nasir.dialogue` | `dialogue/nasir.dialogue` | nie |
| `nas_hello` | `dialogue/nasir.dialogue` | `dialogue/nasir.dialogue` | tak |
| `nas_jewel` | `dialogue/nasir.dialogue` | `dialogue/nasir.dialogue` | nie |
| `nas_sick_seen` | `dialogue/nasir.dialogue` | `dialogue/nasir.dialogue` | nie |
| `nas_sultanate` | `dialogue/nasir.dialogue` | `dialogue/nasir.dialogue` | nie |
| `nas_thanked_health` | `dialogue/nasir.dialogue` | `dialogue/nasir.dialogue` | nie |
| `nasir_at_pumps` | `dialogue/nasir.dialogue` | `dialogue/nasir.dialogue`, `script/camp_schedule.gd` | tak |
| `nasir_carried_up` | `script/story_director.gd` | `script/run_report.gd`, `script/story_director.gd` | nie |
| `nasir_fever_started` | `script/story_director.gd` | `dialogue/nasir.dialogue`, `script/run_report.gd`, `script/story_director.gd` | nie |
| `opened_grabiec_cache` | `tools/generators/gen_locations.gd` | — | nie |
| `opening` | `script/save_manager.gd` | `script/game_state.gd` | nie |
| `opening_done` | `script/story_director.gd` | `script/story_director.gd` | nie |
| `opening_maps` | `dialogue/drudzy.dialogue` | `script/story_director.gd` | tak |
| `ott_deal_done` | `dialogue/ottokar.dialogue` | `dialogue/ottokar.dialogue` | nie |
| `ott_has_maps` | `dialogue/ottokar.dialogue` | — | nie |
| `ott_nakamura` | `dialogue/ottokar.dialogue` | `dialogue/ottokar.dialogue` | nie |
| `ott_peasants` | `dialogue/ottokar.dialogue` | `dialogue/ottokar.dialogue` | nie |
| `ott_what` | `dialogue/ottokar.dialogue` | `dialogue/ottokar.dialogue` | tak |
| `ottokar_knows_crystal` | `dialogue/drudzy.dialogue` | — | nie |
| `ottokar_offer_open` | `dialogue/drudzy.dialogue` | — | nie |
| `papers_with_bolko` | `dialogue/bolko.dialogue` | `script/story_director.gd` | nie |
| `plan_upadowa` | `dialogue/racibor.dialogue` | `dialogue/bolko.dialogue`, `dialogue/miroslaw.dialogue`, `dialogue/racibor.dialogue`, `dialogue/tekla.dialogue`, `script/run_report.gd`, `script/story_director.gd` | nie |
| `protested_upadowa` | `dialogue/racibor.dialogue` | `dialogue/racibor.dialogue` | nie |
| `pump_running` | `dialogue/nasir.dialogue` | `dialogue/miroslaw.dialogue`, `dialogue/nasir.dialogue`, `dialogue/wszebor.dialogue`, `tools/generators/gen_locations.gd`, `tools/generators/write_world_data.js` | nie |
| `quota_met_logged` | `script/game_state.gd` | `script/game_state.gd` | nie |
| `rac_asked_dobrawa` | `dialogue/racibor.dialogue` | `dialogue/racibor.dialogue` | nie |
| `rac_asked_exitium` | `dialogue/racibor.dialogue` | `dialogue/racibor.dialogue` | nie |
| `rac_asked_why` | `dialogue/racibor.dialogue` | `dialogue/racibor.dialogue` | nie |
| `rac_day2` | `dialogue/racibor.dialogue` | `dialogue/racibor.dialogue` | nie |
| `rac_day3` | `dialogue/racibor.dialogue` | `dialogue/racibor.dialogue` | nie |
| `rac_day7` | `dialogue/racibor.dialogue` | `dialogue/racibor.dialogue` | nie |
| `rac_first_report` | `dialogue/racibor.dialogue` | `dialogue/racibor.dialogue` | nie |
| `rac_on_sabina` | `dialogue/racibor.dialogue` | `dialogue/racibor.dialogue` | nie |
| `rac_progress` | `dialogue/racibor.dialogue` | `dialogue/racibor.dialogue` | tak |
| `rac_saw_crystal` | `dialogue/racibor.dialogue` | `dialogue/racibor.dialogue` | nie |
| `racibor_doubts` | `dialogue/racibor.dialogue` | `dialogue/racibor.dialogue`, `script/run_report.gd`, `script/story_director.gd` | nie |
| `racibor_wants_upadowa` | `dialogue/racibor.dialogue` | `dialogue/racibor.dialogue` | nie |
| `read_letter` | `tools/generators/gen_locations.gd` | — | nie |
| `reminder_day` | `script/story_director.gd` | — | tak |
| `ring1` | `dialogue/sciana.dialogue` | `dialogue/sciana.dialogue` | tak |
| `ring2` | `dialogue/sciana.dialogue` | `dialogue/sciana.dialogue` | tak |
| `ring3` | `dialogue/sciana.dialogue` | `dialogue/sciana.dialogue` | tak |
| `sab_child` | `dialogue/sabina.dialogue` | `dialogue/sabina.dialogue` | nie |
| `sab_heal_secret` | `dialogue/sabina.dialogue` | `dialogue/sabina.dialogue` | nie |
| `sab_hello` | `dialogue/sabina.dialogue` | `dialogue/sabina.dialogue` | tak |
| `sab_on_fever` | `dialogue/sabina.dialogue` | `dialogue/sabina.dialogue` | nie |
| `sab_promised` | `dialogue/sabina.dialogue` | `dialogue/anzelm.dialogue`, `dialogue/sabina.dialogue` | nie |
| `sab_why` | `dialogue/sabina.dialogue` | `dialogue/sabina.dialogue` | nie |
| `sabina_arrival_seen` | `script/story_director.gd` | `script/story_director.gd` | nie |
| `sabina_heal` | `dialogue/sabina.dialogue` | `dialogue/sabina.dialogue` | tak |
| `sabina_joined` | `script/story_director.gd` | `dialogue/anzelm.dialogue`, `dialogue/bolko.dialogue`, `dialogue/dobrawa.dialogue`, `dialogue/racibor.dialogue`, `dialogue/tekla.dialogue`, `script/camp_schedule.gd`, `script/run_report.gd`, `script/story_director.gd` | nie |
| `sabina_sense` | `dialogue/sabina.dialogue` | `dialogue/sabina.dialogue` | tak |
| `saw_bread` | `tools/generators/gen_locations.gd` | — | nie |
| `saw_charge` | `tools/generators/gen_locations.gd` | `dialogue/bolko.dialogue`, `dialogue/drudzy.dialogue`, `dialogue/miroslaw.dialogue`, `dialogue/system.dialogue`, `dialogue/tekla.dialogue`, `script/story_director.gd` | nie |
| `saw_cracked_pillar` | `tools/generators/gen_locations.gd` | — | nie |
| `saw_forge_mark` | `tools/generators/gen_locations.gd` | — | nie |
| `saw_fresh_crack` | `tools/generators/gen_locations.gd` | — | nie |
| `saw_fungi` | `tools/generators/gen_locations.gd` | — | nie |
| `saw_grandpa_mark` | `tools/generators/gen_locations.gd` | — | nie |
| `saw_lamp` | `tools/generators/gen_locations.gd` | — | nie |
| `saw_marks_pillar` | `tools/generators/gen_locations.gd` | — | nie |
| `saw_marks_rzapie` | `tools/generators/gen_locations.gd` | — | nie |
| `saw_medal` | `tools/generators/gen_locations.gd` | — | nie |
| `saw_niches` | `tools/generators/gen_locations.gd` | — | nie |
| `soaked` | `script/story_director.gd` | `script/story_director.gd` | tak |
| `sob_dice` | `dialogue/sobek.dialogue` | `dialogue/sobek.dialogue` | tak |
| `sob_exarch` | `dialogue/sobek.dialogue` | `dialogue/sobek.dialogue` | nie |
| `sob_exitium` | `dialogue/sobek.dialogue` | `dialogue/sobek.dialogue` | nie |
| `sob_hello` | `dialogue/sobek.dialogue` | `dialogue/sobek.dialogue` | tak |
| `sob_steppe` | `dialogue/sobek.dialogue` | `dialogue/sobek.dialogue` | nie |
| `sob_sword` | `dialogue/sobek.dialogue` | `dialogue/sobek.dialogue` | nie |
| `supper` | `dialogue/tekla.dialogue` | `dialogue/tekla.dialogue` | tak |
| `supper_blast` | `dialogue/tekla.dialogue` | `dialogue/tekla.dialogue` | nie |
| `supper_eaten` | `dialogue/tekla.dialogue` | `dialogue/tekla.dialogue`, `script/story_director.gd` | nie |
| `supper_raport` | `dialogue/tekla.dialogue` | `dialogue/tekla.dialogue` | nie |
| `supper_szyfr` | `dialogue/tekla.dialogue` | `dialogue/tekla.dialogue` | nie |
| `supper_upadowa` | `dialogue/tekla.dialogue` | `dialogue/tekla.dialogue` | nie |
| `tekla_asked_dobrawa` | `dialogue/tekla.dialogue` | `dialogue/tekla.dialogue` | nie |
| `tekla_asked_favor` | `dialogue/tekla.dialogue` | `dialogue/tekla.dialogue` | nie |
| `tekla_asked_food` | `dialogue/tekla.dialogue` | `dialogue/tekla.dialogue` | nie |
| `tekla_candle` | `dialogue/tekla.dialogue` | `dialogue/tekla.dialogue` | tak |
| `tekla_day3` | `dialogue/tekla.dialogue` | `dialogue/tekla.dialogue` | nie |
| `tekla_father` | `dialogue/tekla.dialogue` | `dialogue/miroslaw.dialogue`, `dialogue/tekla.dialogue` | nie |
| `tekla_gave_fish` | `dialogue/tekla.dialogue` | `dialogue/tekla.dialogue` | nie |
| `tekla_gave_medicine` | `dialogue/tekla.dialogue` | `dialogue/tekla.dialogue` | nie |
| `tekla_gave_oil` | `dialogue/tekla.dialogue` | `dialogue/tekla.dialogue` | nie |
| `tekla_greet` | `dialogue/tekla.dialogue` | `dialogue/tekla.dialogue` | tak |
| `tekla_on_sabina` | `dialogue/tekla.dialogue` | `dialogue/tekla.dialogue` | nie |
| `tekla_owes` | `dialogue/tekla.dialogue` | `dialogue/tekla.dialogue`, `script/run_report.gd` | nie |
| `tekla_reported` | `dialogue/racibor.dialogue` | `dialogue/racibor.dialogue`, `dialogue/tekla.dialogue`, `script/camp_schedule.gd`, `script/run_report.gd`, `script/story_director.gd` | nie |
| `took_bundle` | `tools/generators/gen_locations.gd` | `dialogue/racibor.dialogue`, `dialogue/tekla.dialogue` | nie |
| `took_crowbar` | `tools/generators/gen_locations.gd` | — | nie |
| `took_crystal` | `tools/generators/gen_locations.gd` | `dialogue/system.dialogue`, `script/run_report.gd` | nie |
| `took_fuses` | `tools/generators/gen_camp.gd` | — | nie |
| `took_mushroom_1` | `tools/generators/gen_locations.gd` | — | nie |
| `took_mushroom_2` | `tools/generators/gen_locations.gd` | — | nie |
| `took_obuch` | `tools/generators/gen_locations.gd` | — | nie |
| `took_ossuary_candles` | `tools/generators/gen_locations.gd` | — | nie |
| `took_pump_oil` | `tools/generators/gen_locations.gd` | — | nie |
| `took_shaft_candles` | `tools/generators/gen_locations.gd` | — | nie |
| `took_shard` | `tools/generators/gen_locations.gd` | — | nie |
| `took_smith_flask` | `tools/generators/gen_locations.gd` | — | nie |
| `tremor_seen` | `script/story_director.gd` | `dialogue/bolko.dialogue`, `dialogue/wszebor.dialogue`, `tools/generators/gen_locations.gd` | nie |
| `wall_fails` | `dialogue/sciana.dialogue` | `dialogue/sciana.dialogue` | tak |
| `wall_open` | `dialogue/sciana.dialogue` | `dialogue/dobrawa.dialogue`, `dialogue/racibor.dialogue`, `script/story_director.gd`, `tools/generators/gen_locations.gd` | nie |
| `wall_seen` | `dialogue/sciana.dialogue` | `dialogue/sciana.dialogue` | nie |
| `welf_helped` | `dialogue/welf.dialogue` | `dialogue/welf.dialogue`, `script/field_schedule.gd`, `script/run_report.gd`, `script/story_director.gd` | nie |
| `welf_lost` | `script/story_director.gd` | `dialogue/hieronim.dialogue`, `script/story_director.gd` | nie |
| `welf_thanked` | `dialogue/welf.dialogue` | `dialogue/welf.dialogue` | nie |
| `welf_wounded` | `script/story_director.gd` | `dialogue/welf.dialogue`, `script/field_schedule.gd`, `script/run_report.gd`, `script/story_director.gd` | nie |
| `welf_wounded_day` | `script/story_director.gd` | — | tak |
| `west_blasted` | `script/story_director.gd` | `dialogue/miroslaw.dialogue`, `dialogue/system.dialogue`, `dialogue/tekla.dialogue`, `script/story_director.gd`, `tools/generators/write_world_data.js` | nie |
| `wsz_asked_home` | `dialogue/wszebor.dialogue` | `dialogue/wszebor.dialogue` | nie |
| `wsz_asked_ring` | `dialogue/wszebor.dialogue` | `dialogue/wszebor.dialogue` | nie |
| `wsz_field` | `dialogue/wszebor.dialogue` | `dialogue/wszebor.dialogue` | tak |
| `wsz_fish_day` | `dialogue/wszebor.dialogue` | `dialogue/wszebor.dialogue` | tak |
| `wsz_fish_given` | `dialogue/wszebor.dialogue` | `dialogue/wszebor.dialogue` | nie |
| `wsz_fish_offer` | `dialogue/wszebor.dialogue` | `dialogue/wszebor.dialogue` | nie |
| `wsz_forging_day` | `dialogue/wszebor.dialogue` | `dialogue/wszebor.dialogue` | tak |
| `wsz_gave_flask` | `dialogue/wszebor.dialogue` | `dialogue/wszebor.dialogue` | nie |
| `wsz_hello` | `dialogue/wszebor.dialogue` | `dialogue/wszebor.dialogue` | tak |
| `wsz_long_night` | `dialogue/wszebor.dialogue` | `dialogue/wszebor.dialogue` | nie |
| `wsz_quota_cheer` | `dialogue/wszebor.dialogue` | `dialogue/wszebor.dialogue` | nie |
| `wsz_song` | `dialogue/wszebor.dialogue` | `dialogue/wszebor.dialogue` | tak |
| `wsz_told_brother` | `dialogue/wszebor.dialogue` | — | nie |
| `wsz_tremor` | `dialogue/wszebor.dialogue` | `dialogue/wszebor.dialogue` | nie |

## Rodziny składane w czasie gry (`vein_*`, `visited_*`, `first_room_*`, `fever_*`)

Poniżej tylko te, których nazwa występuje w źródłach literalnie.

| Flaga | Ustawiana w | Czytana w | Ładunek |
|---|---|---|---|
| `fever_nasir` | `script/story_director.gd` | — | nie |
| `vein_` | `tools/generators/gen_locations.gd`, `tools/generators/gen_mine_deep.gd` | `script/expeditions.gd`, `script/game_state.gd`, `tools/generators/gen_locations.gd`, `tools/generators/gen_mine_deep.gd` | nie |
| `vein_kaplica` | — | `dialogue/racibor.dialogue` | nie |
| `vein_kaplica_2` | — | `dialogue/hieronim.dialogue` | nie |
| `vein_rzapie` | — | `dialogue/racibor.dialogue` | nie |
| `vein_rzapie_2` | — | `dialogue/hieronim.dialogue` | nie |
| `vein_upadowa` | — | `dialogue/racibor.dialogue` | nie |
| `vein_west_1` | `tools/generators/gen_camp.gd` | `tools/generators/gen_camp.gd` | nie |
| `visited_east` | — | `dialogue/system.dialogue` | nie |
| `visited_kaplica` | — | `dialogue/hieronim.dialogue` | nie |
| `visited_rzapie` | — | `dialogue/hieronim.dialogue` | nie |
