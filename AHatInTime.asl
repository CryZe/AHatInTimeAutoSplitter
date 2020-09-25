// TODO: wtmt entry, fix alpine multisplits (pos) add all rift splits
// done: custom tp, delayed tp, act entry (wxcept wtmt), cp, cp_pause, cp_pause_pos, decide what to do with pos splits (alpine and slap),
// bonus: initial load is much faster now

state("HatinTimeGame", "DLC 2.1") {
    float x : 0x011BC360, 0x6DC, 0x00, 0x68, 0x51C, 0x80;
    float y : 0x011BC360, 0x6DC, 0x00, 0x68, 0x51C, 0x84;
    float z : 0x011BC360, 0x6DC, 0x00, 0x68, 0x51C, 0x88;

    int chapter : 0x011E1570, 0x68, 0x108;
    int act : 0x011E1570, 0x68, 0x10C;
    int checkpoint : 0x011E1570, 0x68, 0x110;
}

state("HatinTimeGame", "110% Patch") {
    float x : 0x011F9FE0, 0x6DC, 0x00, 0x68, 0x51C, 0x80;
    float y : 0x011F9FE0, 0x6DC, 0x00, 0x68, 0x51C, 0x84;
    float z : 0x011F9FE0, 0x6DC, 0x00, 0x68, 0x51C, 0x88;

    int chapter : 0x0121F280, 0x68, 0x108;
    int act : 0x0121F280, 0x68, 0x10C;
    int checkpoint : 0x0121F280, 0x68, 0x110;
}

state("HatinTimeGame", "DLC 1.5") {
    float x : 0x011C27E0, 0x6DC, 0x00, 0x68, 0x2F4, 0x80;
    float y : 0x011C27E0, 0x6DC, 0x00, 0x68, 0x2F4, 0x84;
    float z : 0x011C27E0, 0x6DC, 0x00, 0x68, 0x2F4, 0x88;

    int chapter: 0x011E7550, 0x68, 0x108;
    int act : 0x011E7550, 0x68, 0x10C;
    int checkpoint : 0x011E7550, 0x68, 0x110;
}

state("HatinTimeGame", "Modding") {
    float x : 0x011229C0, 0x6DC, 0x00, 0x68, 0x508, 0x80;
    float y : 0x011229C0, 0x6DC, 0x00, 0x68, 0x508, 0x84;
    float z : 0x011229C0, 0x6DC, 0x00, 0x68, 0x508, 0x88;

    int chapter : 0x011475A8, 0x64, 0xF8;
    int act : 0x011475A8, 0x64, 0xFC;
    int checkpoint : 0x011475A8, 0x64, 0x100;
}

startup {

    vars.scanTarget = new SigScanTarget(0,
        "54 49 4D 52", // TIMR
        "?? ?? ?? ??", // timerState
        "?? ?? ?? ?? ?? ?? ?? ??", // unpauseTime
        "?? ?? ?? ??", // gameTimerIsPaused
        "?? ?? ?? ??", // actTimerIsPaused
        "?? ?? ?? ??", // actTimerIsVisible
        "?? ?? ?? ??", // unpauseTimeIsDirty
        "?? ?? ?? ??", // justGotTimePiece
        "?? ?? ?? ?? ?? ?? ?? ??", // gameTime
        "?? ?? ?? ?? ?? ?? ?? ??", // actTime
        "?? ?? ?? ?? ?? ?? ?? ??", // realGameTime
        "?? ?? ?? ?? ?? ?? ?? ??", // realActTime
        "?? ?? ?? ??", // timePieceCount
        "45 4E 44 20" // END
    );

    settings.Add("settings", true, "Settings");
    settings.CurrentDefaultParent = "settings";
    settings.Add("IL_mode", false, "IL Mode - Follow the act timer instead of the game timer");
    settings.SetToolTip("IL_mode", "This will also start the timer when the act timer is at 0, and reset when using \"restartil\" or exiting a level.");
    settings.Add("settings_new_file_start", true, "Only start the timer when opening an empty file");
    settings.Add("game_time_message", true, "Ask if Game Time should be used when the game opens");

    settings.CurrentDefaultParent = null;
    settings.Add("splits", true, "Splits");
    settings.CurrentDefaultParent = "splits";
    settings.Add("splits_tp", true, "Time Pieces");
    settings.Add("splits_tp_new", true, "New Time Pieces", "splits_tp");
    settings.Add("splits_tp_any", true, "Any Time Piece", "splits_tp");
    settings.SetToolTip("splits_tp_any", "This adds repeated time pieces and death wish time pieces but may not trigger under certain conditions.\nRecommended to use with \"New Time Pieces\".");
    settings.Add("splits_tp_std", true, "Seal The Deal", "splits_tp");
    settings.SetToolTip("splits_tp_std", "End of Death Wish Any%.\nOnly works on detected patches.");
    settings.Add("splits_dwbth", false, "Death Wish Level Back to Hub");
    settings.SetToolTip("splits_dwbth", "Only works on detected patches.");
    settings.CurrentDefaultParent = null;

    settings.Add("manySplits", false, "Detailed Splits");
    settings.SetToolTip("manySplits", "If you want more customizable options, use these splits instead.\nThey only work on detected patches.");

    string[] chapterNames = new string[7] {"Mafia Town", "Battle of the Birds", "Subcon Forest", "Alpine Skyline", "Time's End - The Finale", "The Artic Cruise", "Nyakuza Metro"};

    for (int i = 1; i <= 7; i++){
        settings.Add("manySplits_" + i, true, chapterNames[i-1], "manySplits");
    }

    string[,] actNames = new string[4, 7]{
        {"Welcome to Mafia Town", "Barrel Battle", "She Came From Outer Space", "Down With The Mafia!", "Cheating The Race", "Heating Up Mafia Town", "The Golden Vault"},
        {"Dead Bird Studio", "Murder on the Owl Express", "Picture Perfect", "Train Rush", "The Big Parade", "Award Ceremony", ""},
        {"Contractual Obligations", "The Subcon Well", "Toilet of Doom", "Queen Vanessa's Manor", "Mail Delivery Service", "Your Contract Has Expired", ""},
        {"Bon Voyage!", "Ship Shape", "Rock The Boat", "", "", "", ""}};

    for (int j = 1; j <= 7; j++){
        for (int i = 1; i <= 7; i++){
            if ((j <= 4) && string.Compare(actNames[j-1, i-1], "") != 0){
                settings.Add("manySplits_" + (j == 4 ? 6 : j) + "_" + i, true, actNames[j-1, i-1], "manySplits_" + (j == 4 ? 6 : j));
                settings.Add("manySplits_" + (j == 4 ? 6 : j) + "_" + i + "_entry", false, "Entry", "manySplits_" + (j == 4 ? 6 : j) + "_" + i);
            }
            else {
                i = 8;
            }
        }
        if (j == 4 || j == 5 || j == 7){
            settings.Add("manySplits_" + j + "_entry", false, "Entry", "manySplits_" + j);
        }
    }

    settings.Add("manySplits_1_1_cp1", false, "Umbrella Fight", "manySplits_1_1");
    settings.Add("manySplits_1_2_cp1", false, "Battle Start", "manySplits_1_2");
    settings.Add("manySplits_1_3_cp1", false, "Scare", "manySplits_1_3");
    settings.Add("manySplits_1_4_cp0_pause_pos", false, "Enter HQ", "manySplits_1_4");
    settings.Add("manySplits_1_4_cp1", false, "Vent", "manySplits_1_4");
    settings.Add("manySplits_1_4_cp2", false, "Boss", "manySplits_1_4");
    settings.Add("manySplits_1_6_cp59_pause", false, "Death", "manySplits_1_6");
    settings.SetToolTip("manySplits_1_6_cp59_pause", "Make sure you are doing on of the ice hat routes for this to work.");

    settings.Add("manySplits_2_1_cp5", false, "Warp Exploit", "manySplits_2_1");
    settings.Add("manySplits_2_4_cp1", false, "Intro", "manySplits_2_4");
    settings.Add("manySplits_2_4_cp4", false, "Exit to Roof", "manySplits_2_4");
    settings.Add("manySplits_2_5_cp1", false, "Intro", "manySplits_2_5");
    settings.Add("manySplits_2_5_cp2", false, "Waiting Time #1", "manySplits_2_5");
    settings.Add("manySplits_2_5_cp3", false, "Waiting Time #2", "manySplits_2_5");
    settings.SetToolTip("manySplits_2_6", "This is for the fake and real finale time pieces / entries.");
    settings.Add("manySplits_2_6_cp0_pause_pos", false, "Elevator to Boss", "manySplits_2_6");

    settings.Add("manySplits_3_2_cp0_pause_pos", false, "Inside Well", "manySplits_3_2");
    settings.Add("manySplits_3_3_cp1", false, "Fight Start", "manySplits_3_3");
    settings.Add("manySplits_3_4_cp0_pause_pos", false, "Inside Manor", "manySplits_3_4");
    settings.Add("manySplits_3_6_cp1", false, "Fight Start", "manySplits_3_6");

    settings.CurrentDefaultParent = "manySplits_4";
    settings.Add("manySplits_4_99_cp0_pause_pos", false, "Intro End");
    settings.SetToolTip("manySplits_4_99_cp0_pause_pos", "Triggered when going back to hub right after the screen fades to white in the zipline.");
    settings.Add("4_birdhouse", false, "The Birdhouse Arrival");
    settings.SetToolTip("4_birdhouse", "Triggered close to the end of the zipline.");
    settings.Add("4_lava_cake", false, "The Lava Cake Arrival");
    settings.SetToolTip("4_lava_cake", "Triggered close to the end of the zipline.");
    settings.Add("4_windmill", false, "The Windmill Arrival");
    settings.SetToolTip("4_windmill", "Triggered close to the end of the zipline.");
    settings.Add("4_twilight", false, "The Twilight Bell Arrival");
    settings.SetToolTip("4_twilight", "Triggered close to the end of the zipline.");
    settings.Add("4_illness_bh", false, "The Illness Has Spread - Birdhouse Warp");
    settings.Add("4_illness_wind", false, "The Illness Has Spread - Windmill Warp");

    settings.CurrentDefaultParent = null;

    settings.Add("manySplits_5_slap", false, "Slap", "manySplits_5");
    settings.Add("manySplits_5_1_cp10", false, "Hyper Zone", "manySplits_5");

    settings.Add("manySplits_6_1_cp3", false, "Check-in", "manySplits_6_1");
    settings.Add("manySplits_6_2_cp1", false, "Job Start", "manySplits_6_2");
    settings.Add("manySplits_6_3_cp1", false, "Sink the Boat", "manySplits_6_3");
    settings.Add("manySplits_6_3_cp2", false, "First Group Saved", "manySplits_6_3");
    settings.Add("manySplits_6_3_cp3", false, "Second Group Saved", "manySplits_6_3");

    // insert rift splits here

    for (int j = 1; j <= 7; j++){
        for (int i = 1; i <= 7; i++){
            if ((j <= 4) && string.Compare(actNames[j-1, i-1], "") != 0){
                settings.Add("manySplits_" + (j == 4 ? 6 : j) + "_" + i + "_tp", true, "Time Piece", "manySplits_" + (j == 4 ? 6 : j) + "_" + i);
                settings.Add("manySplits_" + (j == 4 ? 6 : j) + "_" + i + "_tpDelayed", false, "Delayed Time Piece", "manySplits_" + (j == 4 ? 6 : j) + "_" + i);
                settings.SetToolTip("manySplits_" + (j == 4 ? 6 : j) + "_" + i + "_tpDelayed", "This triggers on the loading screen after getting the time piece.");
            }
            else {
                i = 8;
            }
        }
        if (j == 4 || j == 5 || j == 7){
            settings.Add("manySplits_" + j + "_tp", true, "Time Piece" + (j == 5 ? "" : "s"), "manySplits_" + j);
        }
    }

    vars.lastChapter = 0; // used by seal the deal split
    vars.splitInLoadScreen = false;
    vars.splitsLock = false; // locks splits, prevents multiple splits on loading screens
    }

init {

    if (timer.CurrentTimingMethod == TimingMethod.RealTime && settings["game_time_message"]){
        var message = MessageBox.Show(
            "Would you like to change the current timing method to\nGame Time instead of Real Time?", 
            "LiveSplit | A Hat in Time Auto Splitter", MessageBoxButtons.YesNo, MessageBoxIcon.Question);

        if (message == DialogResult.Yes){
            timer.CurrentTimingMethod = TimingMethod.GameTime;
        }
    }

    switch (modules.First().ModuleMemorySize) {
        case 0x13AF000: version = "DLC 2.1"; break;
        case 0x13F0000: version = "110% Patch"; break;
        case 0x13B3000: version = "DLC 1.5"; break;
        case 0x1260000: version = "Modding"; break;
        default: version = "Undetected"; break;
    }

    var ptr = IntPtr.Zero;

    foreach (var page in game.MemoryPages(true).Reverse()) {
        // if (page.State == MemPageState.MEM_COMMIT &&
        //     page.Type == MemPageType.MEM_IMAGE &&
        //     page.Protect == MemPageProtect.PAGE_READWRITE
        // ) {
            var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);

            if (ptr == IntPtr.Zero) {
                ptr = scanner.Scan(vars.scanTarget);
            } else {
                break;
            }
        // }
    }

    if (ptr == IntPtr.Zero) {
        // Waiting for the game to have booted up. This is a pretty ugly work
        // around, but we don't really know when the game is booted or where the
        // struct will be, so to reduce the amount of searching we are doing, we
        // sleep a bit between every attempt.
        Thread.Sleep(1000);
        throw new Exception();
    }

    vars.timerState = new MemoryWatcher<int>(ptr + 0x04);
    vars.unpauseTime = new MemoryWatcher<double>(ptr + 0x08);
    vars.gameTimerIsPaused = new MemoryWatcher<int>(ptr + 0x10);
    vars.actTimerIsPaused = new MemoryWatcher<int>(ptr + 0x14);
    vars.actTimerIsVisible = new MemoryWatcher<int>(ptr + 0x18);
    vars.unpauseTimeIsDirty = new MemoryWatcher<int>(ptr + 0x1C);
    vars.justGotTimePiece = new MemoryWatcher<int>(ptr + 0x20);
    vars.gameTime = new MemoryWatcher<double>(ptr + 0x24);
    vars.actTime = new MemoryWatcher<double>(ptr + 0x2C);
    vars.realGameTime = new MemoryWatcher<double>(ptr + 0x34);
    vars.realActTime = new MemoryWatcher<double>(ptr + 0x3C);
    vars.timePieceCount = new MemoryWatcher<int>(ptr + 0x44);

    vars.watchers = new MemoryWatcherList() {
        vars.timerState,
        vars.unpauseTime,
        vars.gameTimerIsPaused,
        vars.actTimerIsPaused,
        vars.actTimerIsVisible,
        vars.unpauseTimeIsDirty,
        vars.justGotTimePiece,
        vars.gameTime,
        vars.actTime,
        vars.realGameTime,
        vars.realActTime,
        vars.timePieceCount
    };

    // for certain conditions that need hat kid's position to work
	Func <int, int, bool, float, float, float, bool> ShouldSplitAtThisPos = (int chapter, int act, bool timerChangedState, float x, float y, float z) => {
	return (chapter == 4 && (act != 4  && settings["4_birdhouse"] && x > -24000f&& x < -23000f&& y > 29000f  && y < 30500f && z > 4000f  && z < 6000f  ||   // birdhouse arrival
			                 act != 3  && settings["4_lava_cake"] && x > 3000f  && x < 30400f && y > -28500f && y < -27353f&& z > 3200f  && z < 4000f  ||   // lava cake arrival
			                 act != 13 && settings["4_windmill"] && x > 71600f && x < 72300f && y > 21500f  && y < 22700f && z > 1500f  && z < 2100f   ||   // windmill arrival
			                 act != 15 && settings["4_twilight"] && x > 4600f  && x < 8700f  && y > 69000f  && y < 70000f && z > 4000f  && z < 5400f   ||   // twilight bell arrival
			                 settings["4_illness_bh"]   && x > -20000f&& x < -10000f&& y > 45000f  && y < 52500f && z < -9680f                         ||   // illness birdhouse warp
			                 settings["4_illness_wind"] && x > 38000f && x < 47000f && y > 28000f  && y < 34000f && z < -9680f)                        ||   // illness windmill warp
            chapter == 5 && settings["manySplits_5_slap"] && x > -38300f && x <-38190f && y > -85000f && y <-84000f && z >-59900f && z <-59000f        ||   // slap (5-1)
			
			timerChangedState  &&  (chapter == 1 && settings["manySplits_1_4_cp0_pause_pos"] && x > 3500f  && x < 4500f  && y > -3500f  && y < -3000f && z > 8000f  && z < 9000f    ||   // mafia boss enter HQ (1-4)
                                    chapter == 2 && settings["manySplits_2_6_cp0_pause_pos"] && x > 5500f  && x < 9500f  && y > 8200f   && y < 12000f && z < 5000f                  ||   // basement boss entry (2-6)
			                        chapter == 3 && settings["manySplits_3_2_cp0_pause_pos"] && x > 15800f && x < 17000f && y > 10900f  && y < 11900f && z < 2000f                  ||   // inside well (3-2)
			                        chapter == 3 && settings["manySplits_3_4_cp0_pause_pos"] && x > -28000f&& x < -26000f&& y > 2000f   && y < 3400f  && z > 200f   && z < 1200f    ||   // qvm inside manor (3-4)
			                        chapter == 4 && settings["manySplits_4_99_cp0_pause_pos"]&& x > 37000f && x < 41000f && y > 47000f  && y < 51000f && z > -14000f&& z < -5000f ));    // alpine intro(4-99)
	};
	vars.ShouldSplitAtThisPos = ShouldSplitAtThisPos;
}

update {
    vars.watchers.UpdateAll(game);
    if (version != "Undetected" && current.chapter != old.chapter){
        vars.lastChapter = old.chapter;
    }
    if (version != "Undetected" && (vars.timePieceCount.Current == vars.timePieceCount.Old + 1 || vars.justGotTimePiece.Current == 1 && vars.justGotTimePiece.Old == 0) && settings["manySplits_" + current.chapter + "_" + current.act + "_tpDelayed"]){
        vars.splitInLoadScreen = true;
    }
    if (vars.gameTimerIsPaused.Current == 0 && vars.gameTimerIsPaused.Old == 1){
        vars.splitInLoadScreen = false;
        vars.splitsLock = false;
    }
}

start {
    return (settings["settings_new_file_start"] && vars.timerState.Current == 1 && vars.timerState.Old == 0 && vars.timePieceCount.Current == 0)
        || (!settings["settings_new_file_start"] && vars.timerState.Current == 1 && vars.timerState.Old == 0)
        || (settings["IL_mode"] && vars.actTimerIsVisible.Current == 1 && vars.realActTime.Current == 0);
}

split {
    if (vars.timerState.Current != 0 && !vars.splitsLock
        &&
        (
        settings["splits"] 
            &&
            (
            vars.timePieceCount.Current == vars.timePieceCount.Old + 1 && settings["splits_tp_new"]  // new time piece
            ||
            vars.justGotTimePiece.Current == 1 && vars.justGotTimePiece.Old == 0 && settings["splits_tp_any"]  // any time piece
            ||
            vars.justGotTimePiece.Current == 1 && vars.justGotTimePiece.Old == 0 && version != "Undetected" && current.chapter == 3 && vars.lastChapter == 5 && settings["splits_tp_std"]  // seal the deal
            ||
            version != "Undetected" && current.chapter == 97 && old.chapter != 97 && settings["splits_dwbth"]  // death wish back to hub
            )
        ||
        settings["manySplits"] && version != "Undetected" 
            &&
            (
            (vars.timePieceCount.Current == vars.timePieceCount.Old + 1 || vars.justGotTimePiece.Current == 1 && vars.justGotTimePiece.Old == 0) && (settings["manySplits_" + current.chapter + "_" + current.act + "_tp"] || settings["manySplits_" + current.chapter + "_"])  // custom time pieces
            ||
            current.checkpoint != old.checkpoint && settings["manySplits_" + current.chapter + "_" + current.act + "_cp" + current.checkpoint] // new checkpoint
            ||
            vars.ShouldSplitAtThisPos(current.chapter, current.act, vars.gameTimerIsPaused.Changed, current.x, current.y, current.z) // all position splits
            ||
            vars.splitInLoadScreen && vars.gameTimerIsPaused.Current == 1 && vars.gameTimerIsPaused.Old == 0  // delayed custom time pieces
            ||
            vars.realActTime.Current == 0f && vars.realActTime.Old != 0f && (settings["manySplits_" + current.chapter + "_" + current.act + "_entry"] || settings["manySplits_" + current.chapter + "_entry"]) // act entry
            ||
            vars.gameTimerIsPaused.Current == 1 && vars.gameTimerIsPaused.Old == 0 && settings["manySplits_" + current.chapter + "_" + current.act + "_cp" + current.checkpoint + "_pause"] // paused with certain checkpoint
            )
        )
        )
        {
            return true;
        }

    return false;
}

reset {
    return vars.timerState.Current == 0 && vars.timerState.Old == 1 || settings["IL_mode"] && (vars.actTimerIsVisible.Current == 0 && vars.actTimerIsVisible.Old == 1 || vars.realActTime.Current < vars.realActTime.Old);
}

isLoading {
    return true;
}

gameTime {
    return settings["IL_mode"] ? TimeSpan.FromSeconds(vars.realActTime.Current) : TimeSpan.FromSeconds(vars.realGameTime.Current);
}