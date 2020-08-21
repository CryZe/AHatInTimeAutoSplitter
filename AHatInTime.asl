state("HatinTimeGame", "DLC 2.1") {
    int chapter : 0x011E1570, 0x68, 0x108;
}

state("HatinTimeGame", "110% Patch") {
    int chapter : 0x0121F280, 0x68, 0x108;
}

state("HatinTimeGame", "DLC 1.5") {
	int chapter: 0x011E7550, 0x68, 0x108;
}

state("HatinTimeGame", "Modding") {
	int chapter : 0x011475A8, 0x64, 0xF8;
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

    settings.Add("settings", true, "Settings");
    settings.CurrentDefaultParent = "settings";
    settings.Add("IL_mode", false, "IL Mode - Follow the act timer instead of the game timer");
    settings.SetToolTip("IL_mode", "This will also start the timer when the act timer is at 0, and reset when using \"restartil\" or exiting a level.");
    settings.Add("settings_new_file_start", true, "Only start the timer when opening an empty file");
    settings.Add("game_time_message", true, "Ask if Game Time should be used when the game opens");

    vars.lastChapter = 0; // used by seal the deal split
}

init {

    if (timer.CurrentTimingMethod == TimingMethod.RealTime && settings["game_time_message"]){
		var message = MessageBox.Show(
			"Would you like to change the current timing method to\nGame Time instead of Real Time?", 
			"LiveSplit | A Hat in Time Auto Splitter", MessageBoxButtons.YesNo, MessageBoxIcon.Question);
			
	    if (message == DialogResult.Yes)
			timer.CurrentTimingMethod = TimingMethod.GameTime;
	}

	switch (modules.First().ModuleMemorySize) {
        case 0x13AF000: version = "DLC 2.1"; break;
        case 0x13F0000: version = "110% Patch"; break;
		case 0x13B3000: version = "DLC 1.5"; break;
		case 0x1260000: version = "Modding"; break;
        default: version = "Undetected"; break;
    }

    var ptr = IntPtr.Zero;

    foreach (var page in game.MemoryPages(true)) {
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
}

update {
    vars.watchers.UpdateAll(game);
    if (version != "Undetected" && current.chapter != old.chapter){
        vars.lastChapter = old.chapter;
    }
}

start {
    return (settings["settings_new_file_start"] && vars.timerState.Current == 1 && vars.timerState.Old == 0 && vars.timePieceCount.Current == 0)
        || (!settings["settings_new_file_start"] && vars.timerState.Current == 1 && vars.timerState.Old == 0)
        || (settings["IL_mode"] && vars.actTimerIsVisible.Current == 1 && vars.realActTime.Current == 0);
}

split {
    if (vars.timePieceCount.Current == vars.timePieceCount.Old + 1 && settings["splits_tp_new"] ||
        vars.justGotTimePiece.Current == 1 && vars.justGotTimePiece.Old == 0 && settings["splits_tp_any"] ||
        version != "Undetected" && vars.justGotTimePiece.Current == 1 && vars.justGotTimePiece.Old == 0 && current.chapter == 3 && vars.lastChapter == 5 && settings["splits_tp_std"] ||
        current.chapter == 97 && old.chapter != 97 && settings["splits_dwbth"]){
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