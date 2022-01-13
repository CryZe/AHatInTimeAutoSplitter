state("HatinTimeGame") {
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

    // works on vanessa's curse patches from 2022/01/12+
    vars.saveDataScanTargetVacu = new SigScanTarget(3,
        "48 8B 1D ?? ?? ?? ?? 48 85 DB 74 ?? 48 8B 5B ?? 48 85 DB 74 ??"
    );

    // works on DLC patches
    vars.saveDataScanTargetDLC = new SigScanTarget(3,
        "48 8B 05 ?? ?? ?? ?? 48 8B 74 24 ?? 48 83 C4 50"
    );

    // works on modding patch or similar
    vars.saveDataScanTargetModding = new SigScanTarget(3,
        "48 8B 05 ?? ?? ?? ?? 48 8B D9 48 85 C0 75 ?? 48 89 7C 24 ??"
    );

    // works in 1.0 or similar
    vars.saveDataScanTargetoRelease = new SigScanTarget(3,
        "48 8B 05 ?? ?? ?? ?? 48 8B 7C 24 ?? 48 83 C4 40"
    );

    // actors, for all patches
    vars.actorsScanTarget = new SigScanTarget(3,
        "48 8B 05 ?? ?? ?? ?? 81 88 ?? ?? ?? ?? 00 00 80 00"
    );

    // this finds the second to last offset for the coordinates of hat kid
    vars.hatKidScanTarget = new SigScanTarget(3,
        "48 8B 81 ?? ?? ?? ?? 4C 8D 80 ?? ?? ?? ??"
    );

    #region settings
    settings.Add("settings", true, "Settings");
    settings.CurrentDefaultParent = "settings";
    settings.Add("settings_ILMode", false, "IL Mode - Follow the act timer instead of the game timer");
    settings.SetToolTip("settings_ILMode", "This will also start the timer when the act timer is at 0, and reset when using \"restartil\" or exiting a level.");
    settings.Add("settings_newFileStart", true, "Only start the timer when opening an empty file");
    settings.Add("settings_gameTimeMsg", true, "Ask if Game Time should be used when the game opens");

    settings.CurrentDefaultParent = null;
    settings.Add("splits", true, "Simple Splits");
    settings.CurrentDefaultParent = "splits";
    settings.Add("splits_tp", true, "Time Pieces");
    settings.Add("splits_tp_new", true, "New Time Pieces", "splits_tp");
    settings.Add("splits_tp_any", true, "Any Time Piece", "splits_tp");
    settings.SetToolTip("splits_tp_any", "This adds repeated time pieces and death wish time pieces but may not trigger under certain conditions.\nRecommended to use with \"New Time Pieces\".");
    settings.Add("splits_tp_std", true, "Seal The Deal", "splits_tp");
    settings.SetToolTip("splits_tp_std", "End of Death Wish Any%.");
    settings.Add("splits_actEntry", false, "Act Entries");
    settings.SetToolTip("splits_actEntry", "Also for time rifts in the spaceship.");
    settings.Add("splits_checkpoint", false, "Checkpoint");
    settings.Add("splits_yarn", false, "Yarn");
    settings.Add("splits_dwbth", false, "Death Wish Level Back to Hub");
    settings.Add("splits_dwbth_doubleSplitNo", true, "Avoid Double Splits", "splits_dwbth");
    settings.SetToolTip("splits_dwbth_doubleSplitNo", "Useful for 110%,\nIf another split triggered recently, the Death Wish Back to Hub split won't trigger.");
    settings.CurrentDefaultParent = null;

    settings.Add("manySplits", false, "Detailed Splits");
    settings.SetToolTip("manySplits", "Here you can find a lot of customizable options.");

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
            if (j <= 4 && actNames[j-1, i-1] != ""){
                settings.Add("manySplits_" + (j == 4 ? 6 : j) + "_" + i, true, actNames[j-1, i-1], "manySplits_" + (j == 4 ? 6 : j));
                settings.Add("manySplits_" + (j == 4 ? 6 : j) + "_" + i + "_entry", false, "Entry", "manySplits_" + (j == 4 ? 6 : j) + "_" + i);
                if (i == 1){
                    settings.SetToolTip("manySplits_" + (j == 4 ? 6 : j) + "_1_entry", "Note that this also triggers when entering a time rift from this chapter using the telescope.");
                }
            }
            else {
                i = 8;
            }
        }
        if (j == 5 || j == 7){
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
    settings.SetToolTip("manySplits_1_6_cp59_pause", "Only for routes that do the beach faucet after the death as the last one.");

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
    settings.Add("manySplits_4_99_entry", false, "Intro Entry");
    settings.Add("manySplits_4_99_cp0_pause_pos", false, "Intro End");
    settings.SetToolTip("manySplits_4_99_cp0_pause_pos", "Triggered when going back to hub right after the screen fades to white in the zipline.");
    settings.Add("manySplits_pos_40", false, "The Birdhouse Arrival");
    settings.SetToolTip("manySplits_pos_40", "Triggered close to the end of the zipline.");
    settings.Add("manySplits_pos_41", false, "The Lava Cake Arrival");
    settings.SetToolTip("manySplits_pos_41", "Triggered close to the end of the zipline.");
    settings.Add("manySplits_pos_42", false, "The Windmill Arrival");
    settings.SetToolTip("manySplits_pos_42", "Triggered close to the end of the zipline.");
    settings.Add("manySplits_pos_43", false, "The Twilight Bell Arrival");
    settings.SetToolTip("manySplits_pos_43", "Triggered close to the end of the zipline.");
    settings.Add("manySplits_pos_44", false, "The Illness Has Spread - Birdhouse Warp");
    settings.Add("manySplits_pos_45", false, "The Illness Has Spread - Windmill Warp");

    settings.CurrentDefaultParent = null;

    settings.Add("manySplits_5_1_cp1", false, "Enter Castle", "manySplits_5");
    settings.SetToolTip("manySplits_5_1_cp1", "Only recommended for ILs");
    settings.Add("manySplits_5_1_cp2", false, "Big Doors 1", "manySplits_5");
    settings.SetToolTip("manySplits_5_1_cp2", "Only recommended for ILs");
    settings.Add("manySplits_5_1_cp3", false, "Big Doors 2", "manySplits_5");
    settings.SetToolTip("manySplits_5_1_cp3", "Only recommended for ILs");
    settings.Add("manySplits_pos_5", false, "Slap", "manySplits_5");
    settings.Add("manySplits_5_1_cp10", false, "Hyper Zone", "manySplits_5");

    settings.Add("manySplits_6_1_cp3", false, "Check-in", "manySplits_6_1");
    settings.Add("manySplits_6_2_cp1", false, "Job Start", "manySplits_6_2");
    settings.Add("manySplits_6_3_cp1", false, "Sink the Boat", "manySplits_6_3");
    settings.Add("manySplits_6_3_cp2", false, "First Group Saved", "manySplits_6_3");
    settings.Add("manySplits_6_3_cp3", false, "Second Group Saved", "manySplits_6_3");

    for (int j = 1; j <= 7; j++){
        for (int i = 1; i <= 7; i++){
            if (j <= 4 && string.Compare(actNames[j-1, i-1], "") != 0){
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

    settings.Add("manySplits_riftBlue", true, "Time Rift - Blue", "manySplits");
    settings.Add("manySplits_riftPurple", true, "Time Rift - Purple", "manySplits");

    string[,] riftNames = new string[2, 11]{
    {"The Gallery", "The Lab", "Sewers", "Bazaar", "The Owl Express", "The Moon", "Village", "Pipe", "Twilight Bell", "Curly Tail Trail", "Balcony"},
    {"Mafia of Cooks", "Dead Bird Studio", "Sleepy Subcon", "Alpine Skyline", "Deep Sea", "Rumbi Factory", "Tour", "", "", "", ""}};

    string[,] riftIds = new string[2, 11]{
    {"gallery", "lab", "sewers", "bazaar", "owlExpress", "moon", "village", "pipe", "twilight", "curly", "balcony"},
    {"moc", "dbs", "sleepy", "alpine", "deepSea", "rumbi", "tour", "", "", "", ""}};

    for (int i = 0; i <= 1; i++){
        for (int j = 0; j <= 10; j++){
            if (i == 0){ 
                settings.Add("manySplits_riftBlue_" + riftIds[0,j], true, riftNames[0, j], "manySplits_riftBlue");
                settings.Add("manySplits_riftBlue_" + riftIds[0,j] + "_entry", false, "Entry", "manySplits_riftBlue_" + riftIds[0,j]);
                settings.Add("manySplits_riftBlue_" + riftIds[0,j] + "_tp", true, "Time Piece", "manySplits_riftBlue_" + riftIds[0,j]);
            }
            else if (riftNames[1, j] != ""){
                settings.Add("manySplits_riftPurple_" + riftIds[1,j], true, riftNames[1, j], "manySplits_riftPurple");
                settings.Add("manySplits_riftPurple_" + riftIds[1,j] + "_entry", false, "Entry", "manySplits_riftPurple_" + riftIds[1,j]);
                settings.Add("manySplits_riftPurple_" + riftIds[1,j] + "_cp", false, "Room Completed", "manySplits_riftPurple_" + riftIds[1,j]);
                settings.Add("manySplits_riftPurple_" + riftIds[1,j] + "_tp", true, "Time Piece", "manySplits_riftPurple_" + riftIds[1,j]);
            }
        }
    }
    #endregion

    vars.lastChapter = 0; // used by seal the deal split
    vars.gameTimeFinal = 0.0; // game time used in gameTime{}
    vars.savedGameTime = 0.0; // used to save the game time at the start of each act
    vars.splitInLoadScreen = false;
    vars.currentRift = "none"; // indicates the current time rift, none -> not in a rift
    vars.justEnteredRift = false;
    vars.posSplitKey = 0f; // key for a position split to trigger, 0f -> no key currently in use
    vars.splitsLock = new Stopwatch(); // prevents double splits
    vars.splitsLock.Start();

    vars.splitActions = (EventHandler)((s, e) => {
        vars.splitsLock.Restart();
        vars.posSplitKey = 0f;
    });
    timer.OnSplit += vars.splitActions;
}

init {

    // signature scan thread
    vars.threadScan = new Thread(() => {

        var ptr = IntPtr.Zero;
        var saveDataPtrAddress = IntPtr.Zero;
        var actorsPrtAddress = IntPtr.Zero;
        var coordsOffsetPrtAddress = IntPtr.Zero;

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

        // save data scan
        vars.saveDataPtrType = "none";
        foreach (var page in game.MemoryPages(true).Reverse()) {
            var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);

            // scan for vacu pathces from 2022/13/01
            saveDataPtrAddress = scanner.Scan(vars.saveDataScanTargetVacu);
            if (saveDataPtrAddress != IntPtr.Zero) {
                vars.saveDataPtrType = "DLCPtr";
                break;
            }

            // scan for DLC patches
            saveDataPtrAddress = scanner.Scan(vars.saveDataScanTargetDLC);
            if (saveDataPtrAddress != IntPtr.Zero) {
                vars.saveDataPtrType = "DLCPtr";
                break;
            }

            // scan for pre DLC modding patches
            saveDataPtrAddress = scanner.Scan(vars.saveDataScanTargetModding);
            if (saveDataPtrAddress != IntPtr.Zero) {
                vars.saveDataPtrType = "ModdingPtr";
                break;
            }

            // scan for 1.0 and similar
            saveDataPtrAddress = scanner.Scan(vars.saveDataScanTargetoRelease);
            if (saveDataPtrAddress != IntPtr.Zero) {
                vars.saveDataPtrType = "1.0Ptr";
                break;
            }
        }

        // actors scan
        foreach (var page in game.MemoryPages(true).Reverse()) {
            var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);

            actorsPrtAddress = scanner.Scan(vars.actorsScanTarget);
            if (actorsPrtAddress != IntPtr.Zero) {
                break;
            }
        }

        // hatkid offset scan
        foreach (var page in game.MemoryPages(true).Reverse()) {
            var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);

            coordsOffsetPrtAddress = scanner.Scan(vars.hatKidScanTarget);
            if (coordsOffsetPrtAddress != IntPtr.Zero) {
                break;
            }
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


        // first the data at this address is read, it's an offset for the same address, used to jump to the save data address, which means...
        var saveDataPtrAddressOffset = memory.ReadValue<int>(saveDataPtrAddress);

        // by adding the previous address with the prevoiusly read offset and adding a manual offset of 4, we get to the address of the save data poiter
        var saveDataAddressFinal = (IntPtr)((long)saveDataPtrAddress + (long)saveDataPtrAddressOffset + (long)4);

        // this makes sure that the variable is initialized
        while (memory.ReadValue<int>(saveDataAddressFinal) == 0){
            Thread.Sleep(1000);
        }

        // here are the final memory watchers that are created using the pointer at the address that was just calculated
        // offsets for DLC patches
        if (vars.saveDataPtrType == "DLCPtr"){
            vars.yarn = new MemoryWatcher<int>(new DeepPointer(saveDataAddressFinal, 0x68, 0xF0));
            vars.chapter = new MemoryWatcher<int>(new DeepPointer(saveDataAddressFinal, 0x68, 0x108));
            vars.act = new MemoryWatcher<int>(new DeepPointer(saveDataAddressFinal, 0x68, 0x10C));
            vars.checkpoint = new MemoryWatcher<int>(new DeepPointer(saveDataAddressFinal, 0x68, 0x110));
        }
        // offsets for modding patch and similar
        else if (vars.saveDataPtrType == "ModdingPtr"){
            vars.yarn = new MemoryWatcher<int>(new DeepPointer(saveDataAddressFinal, 0x64, 0xE0));
            vars.chapter = new MemoryWatcher<int>(new DeepPointer(saveDataAddressFinal, 0x64, 0xF8));
            vars.act = new MemoryWatcher<int>(new DeepPointer(saveDataAddressFinal, 0x64, 0xFC));
            vars.checkpoint = new MemoryWatcher<int>(new DeepPointer(saveDataAddressFinal, 0x64, 0x100));
        }
        // offsets for 1.0 and similar and patches that don't find any signature (these should constantly return 0)
        else{
            vars.yarn = new MemoryWatcher<int>(new DeepPointer(saveDataAddressFinal, 0x64, 0xE0));
            vars.chapter = new MemoryWatcher<int>(new DeepPointer(saveDataAddressFinal, 0x64, 0xF4));
            vars.act = new MemoryWatcher<int>(new DeepPointer(saveDataAddressFinal, 0x64, 0xF8));
            vars.checkpoint = new MemoryWatcher<int>(new DeepPointer(saveDataAddressFinal, 0x64, 0xFC));
        }


        // first the data at this address is read, it's an offset for the same address, used to jump to the save data address, which means...
        // not sure if this is exactly for actors but I need to put a name...
        var actorsPtrAddressOffset = memory.ReadValue<int>(actorsPrtAddress);

        // by adding the previous address with the prevoiusly read offset and adding a manual offset of 4, we get to the address of the save data poiter
        var actorsAddressFinal = (IntPtr)((long)actorsPrtAddress + (long)actorsPtrAddressOffset + (long)4);

        // here is where the second to last offset that's different in some patches is read 
        var hatKidOffset = memory.ReadValue<int>(coordsOffsetPrtAddress);

        // this makes sure that the variable is initialized
        while (memory.ReadValue<int>(actorsAddressFinal) == 0){
            Thread.Sleep(1000);
        }

        // x y z coordinates memory watchers for all patches
        vars.x = new MemoryWatcher<float>(new DeepPointer(actorsAddressFinal, 0x6DC, 0x00, 0x68, hatKidOffset, 0x80));
        vars.y = new MemoryWatcher<float>(new DeepPointer(actorsAddressFinal, 0x6DC, 0x00, 0x68, hatKidOffset, 0x84));
        vars.z = new MemoryWatcher<float>(new DeepPointer(actorsAddressFinal, 0x6DC, 0x00, 0x68, hatKidOffset, 0x88));


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
            vars.timePieceCount,
            vars.yarn,
            vars.chapter,
            vars.act,
            vars.checkpoint,
            vars.x,
            vars.y,
            vars.z
        };
    });
    vars.threadScan.Start();

    if (timer.CurrentTimingMethod == TimingMethod.RealTime && settings["settings_gameTimeMsg"]){
        var message = MessageBox.Show(
            "Would you like to change the current timing method to\nGame Time instead of Real Time?", 
            "LiveSplit | A Hat in Time Auto Splitter", MessageBoxButtons.YesNo, MessageBoxIcon.Question);

        if (message == DialogResult.Yes){
            timer.CurrentTimingMethod = TimingMethod.GameTime;
        }
    }

    // MD5 code by CptBrian.
    string MD5Hash;
    using (var md5 = System.Security.Cryptography.MD5.Create())
        using (var s = File.Open(modules.First().FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
            MD5Hash = md5.ComputeHash(s).Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);

    switch (MD5Hash){
        case "D9898AF61F812A94D459A2949F6C44CB": version = "DLC 2.1"; break;
        case "1146D9624167F5B27316EA3186CE38BC": version = "110% Patch"; break;
        case "1A7ECB949C9E7AA43C30A8130E4BBFC7": version = "TAS Patch"; break;
        case "7E3BC291F73AFF33697D614E058F55FA": version = "DLC 1.5"; break;
        case "86BE2DADA5A75B451A413644245A2C36": version = "Modding"; break;
        case "ABF94326BBA029207F6537AA8EF21C0E": version = "1.0"; break;
        default: version = "Unknown"; break;
    }

    // volume "keys" dictionary that enables the volume split triggers
    // the main idea is making a volume trigger a split only when hat kid has gone through a certain other volume right before
    // key: chapter number, value: list of lists with coordinates of key volumes
    // format of lists: {min x, max x, min y, max y, min z, max z, key for position splits}
    // -2f: ignored coordinate
    Dictionary<int, List<List<float>>> posSplitKeysDict = new Dictionary<int, List<List<float>>>();

    List<List<float>> posVolumeKeysChFour = new List<List<float>>();
    posVolumeKeysChFour.Add (new List<float>() {-11000f, -9000f,  32000f,  34000f,  -1000f, 500f,   40f});  // birdhouse arrival (start of zipline)
    posVolumeKeysChFour.Add (new List<float>() {36500f,  38000f,  -13000f, -11000f, 4500f,  5500f,  41f});  // lava cake arrival (start of zipline)
    posVolumeKeysChFour.Add (new List<float>() {47000f,  49000f,  21000f,  22000f,  1000f,  2500f,  42f});  // windmill arrival (start of zipline)
    posVolumeKeysChFour.Add (new List<float>() {7000f,   8500f,   43000f,  45000f,  -1000f, 1000f,  43f});  // twilight bell arrival (start of zipline)
    posVolumeKeysChFour.Add (new List<float>() {-15300f, -14400f, 47750f,  49000f,  -1650f, -1300f, 44f});  // illness birdhouse warp (close to plant)
    posVolumeKeysChFour.Add (new List<float>() {41000f,  42500f,  29000f,  30500f,  2400f,  2800f,  45f});  // illness windmill warp (close to plant)
    posSplitKeysDict.Add (4, posVolumeKeysChFour);

    List<List<float>> posVolumeKeysChFive = new List<List<float>>();
    posVolumeKeysChFive.Add (new List<float>() {-30000f, -28000f, -2f, -2f, -2f, -2f, 5f}); // slap (around the final pillars)
    posSplitKeysDict.Add (5, posVolumeKeysChFive);

    vars.posSplitKeysDict = posSplitKeysDict;

    // position splits dictionary that uses a key given by the "volume keys" dictionary
    Dictionary<float, float[]> posSplitsDict = new Dictionary<float, float[]>();
    posSplitsDict.Add(40f, new float[6] {-24000f,  -23000f, 29000f,   30500f,   4000f,  6000f});    // birdhouse arrival
    posSplitsDict.Add(41f, new float[6] {3000f,    30400f,  -28500f,  -27353f,  3200f,  4000f});    // lava cake arrival
    posSplitsDict.Add(42f, new float[6] {71600f,   72300f,  21500f,   22700f,   1500f,  2100f});    // windmill arrival
    posSplitsDict.Add(43f, new float[6] {4600f,    8700f,   69000f,   70000f,   4000f,  5400f});    // twilight bell arrival
    posSplitsDict.Add(44f, new float[6] {-2f,      -2f,     -2f,      -2f,      -2f,    -9680f});   // illness birdhouse warp
    posSplitsDict.Add(45f, new float[6] {-2f,      -2f,     -2f,      -2f,      -2f,    -4230f});   // illness windmill warp
    posSplitsDict.Add(5f,  new float[6] {-38300f,  -38190f, -85000f,  -84000f,  -2f,    -2f});      // slap (5-1)
    vars.posSplitsDict = posSplitsDict;

    // position splits, note that these are only checked when their "volume key" is found in vars.posSplitKeyDict
    Func <float, float, float, float[], bool> ShouldSplitAtThisPos = (float x, float y, float z, float[] position) => {
        return ((x > position[0] || position[0] == -2f) && (x < position[1] || position[1] == -2f) && 
                (y > position[2] || position[2] == -2f) && (y < position[3] || position[3] == -2f) && 
                (z > position[4] || position[4] == -2f) && (z < position[5] || position[5] == -2f));
    };
    vars.ShouldSplitAtThisPos = ShouldSplitAtThisPos;

    // for certain splits that trigger when the timer is paused/unpaused while hat kid is at a certain position
    Func <int, float, float, float, bool> ShouldSplitAtThisPosPause = (int chapter, float x, float y, float z) => {
    return  chapter == 1 && settings["manySplits_1_4_cp0_pause_pos"] && x > 3500f  && x < 4500f  && y > -3500f  && y < -3000f && z > 8000f  && z < 9000f    ||   // enter mafia HQ (1-4)
            chapter == 2 && settings["manySplits_2_6_cp0_pause_pos"] && x > 5500f  && x < 9500f  && y > 5000f   && y < 12000f && z < 4000f                  ||   // basement boss entry (2-6)
            chapter == 3 && settings["manySplits_3_2_cp0_pause_pos"] && x > 15800f && x < 17000f && y > 10900f  && y < 11900f && z < 2000f                  ||   // inside well (3-2)
            chapter == 3 && settings["manySplits_3_4_cp0_pause_pos"] && x > -28000f&& x < -26000f&& y > 2000f   && y < 3400f  && z > 200f   && z < 1200f    ||   // qvm inside manor (3-4)
            chapter == 4 && settings["manySplits_4_99_cp0_pause_pos"]&& x > 37000f && x < 41000f && y > 47000f  && y < 51000f && z > -14000f&& z < -5000f;       // alpine intro (4-99)
    };
    vars.ShouldSplitAtThisPosPause = ShouldSplitAtThisPosPause;

    // returns the current rift based on hat kid's position, it's using either the rift orb to enter them or hat kid's position at the start of them
    Func <int, float, float, float, string> CurrentRiftCheck = (int chapter, float x, float y, float z) => {
        
        // purple rifts 
        if      (chapter == 1 && x > 4070f  && x < 4250f  && y > -5550f  && y < -5350f  && z > -900f  && z < -700f ||
                                 x > 13200f && x < 13250f && y > -120f   && y < -80f    && z > -250f )               return "manySplits_riftPurple_moc";
        else if (chapter == 2 && x > 8350f  && x < 8500f  && y > -2250f  && y < -2100f  && z > 2700f  && z < 2870f ||
                                 x > 7750f  && x < 7800f  && y > -10500f && y < -10400f && z > 1000f)                return "manySplits_riftPurple_dbs";
        else if (chapter == 3 && x > 13100f && x < 13300f && y > 25150f  && y < 25350f  && z > 2300f && z < 2500f  ||
                                 x > 6100f  && x < 6150f  && y > 32400f  && y < 32500f  && z > 550f)                 return "manySplits_riftPurple_sleepy"; 
        else if (chapter == 4 && x > 16700f && x < 16850f && y > 28750f  && y < 28900f  && z >-5100f  && z <-4800f ||
                                 x >-11700f && x <-11600f && y > -11700f && y <-11600f  && z >-4000f)                return "manySplits_riftPurple_alpine";
        else if (chapter == 6 && x > 1860f  && x < 3000f  && y > 6400f   && y < 6550f   && z > 4000f && z < 4200f  ||
                                 x > -15700f&& x < -15600f&& y > 870f    && y < 910f    && z > 3200f)                return "manySplits_riftPurple_deepSea";
        else if (chapter == 7 && x > 750f   && x < 900f   && y > 1200f   && y < 1350f   && z > 1250f && z < 1450f  ||
                                 x > -400f  && x < -300f  && y > -8400f  && y < -8300f  && z > 1000f)                return "manySplits_riftPurple_rumbi";
        else if (                x > -4220f && x < -4120f && y > -800f   && y < -710f   && z > 1300f && z < 1500f  ||
                                 x > 13100f && x < 13200f && y > -250f   && y < -200f   && z > 2650f)                return "manySplits_riftPurple_tour";
        
        // blue rifts
        else if (chapter == 1 && x > -200f  && x < -150f  && y > -410f   && y < -360f   && z > 60f   && z < 120f  ||
                                 x >  640f  && x <  850f  && y > 4000f   && y < 4140f   && z > 760f  && z < 960f)    return "manySplits_riftBlue_sewers";
        else if (chapter == 1 && x > -200f  && x < -150f  && y > -150f   && y < -120f   && z > 60f   && z < 120f  || 
                                 x > -3150f && x < -3030f && y > -2480f  && y < -2360f  && z > 400f  && z < 600f)    return "manySplits_riftBlue_bazaar";
        else if (chapter == 2 && x > -2710f && x < -2500f && y > 1020f   && y < 1230f   && z > 10f   && z < 100f  ||
                                 x > -53920f&& x < -53810f&& y > -9260f  && y < -9150f  && z > 100f  && z < 290f)    return "manySplits_riftBlue_owlExpress";
        else if (chapter == 2 && x > 2600f  && x < 2850   && y > 850f    && y < 1100f   && z > 0f    && z < 100f  ||
                                 x > -3950f && x < -3830f && y > -100f   && y < 0f      && z > 390f  && z < 570f)    return "manySplits_riftBlue_moon";
        else if (chapter == 3 && x > -2800f && x < -2400f && y > -1800f  && y < -1450f  && z > 60f   && z < 120f  ||
                                 x > 1190f  && x < 1290f  && y > 26250f  && y < 26350f  && z > 3450f && z < 3630f)   return "manySplits_riftBlue_village";
        else if (chapter == 3 && x > 1780f  && x < 2000f  && y > -11384f && y < -9350f  && z > 60f   && z < 120f  ||
                                 x > -130f  && x < -20f   && y > 7250f   && y < 7360f   && z > 500f  && z < 640f)    return "manySplits_riftBlue_pipe";
        else if (chapter == 4 && x > 7600f  && x < 7900f  && y > 1100f   && y < 1400f   && z > -500f && z < -100f ||
                                 x > 6330f  && x < 6450f  && y > 72060f  && y < 72180f  && z > 5150f && z < 5300f)   return "manySplits_riftBlue_twilight";
        else if (chapter == 4 && x > 5700f  && x < 6000f  && y > 3100f   && y < 3400f   && z > -500f && z < -100f ||
                                 x > 56380f && x < 56500f && y > 6740f   && y < 6840f   && z > -1690f&& z < -1500f)  return "manySplits_riftBlue_curly";
        else if (chapter == 6 && x > 3700f  && x < 3950f  && y > 4300f   && y < 4550f   && z > 1200f && z < 1400f ||
                                 x > -950f  && x < -840f  && y > -1410f  && y < -1310f  && z > 7690f && z < 7850f)   return "manySplits_riftBlue_balcony";
        else if (                x > -1180f && x < -920f  && y > 4050f   && y < 4350f   && z > 200f  && z < 300f  ||
                                 x > -3940f && x < -3840f && y > -80f    && y < 20f     && z > -520f && z < -350f)   return "manySplits_riftBlue_lab";
        else if (                x > 7250f  && x < 7550f  && y > 100f    && y < 400f    && z > -500f && z < -400f ||
                                 x > 3100f  && x < 3220f  && y > -2400f  && y < -2270f  && z > 130f  && z < 310f)    return "manySplits_riftBlue_gallery";
        else return "none";
    };
    vars.CurrentRiftCheck = CurrentRiftCheck;

    // checks if hat kid was moved to the hub
    Func <int, float, float, float, bool> BackToHubCheck = (int chapter, float x, float y, float z) => {
    return (                 x > -690f   && x < -660f   && y > 1525f  && y < 1555f  && z > 225f  && z < 260f   ||
            chapter == 1  && x > 195f    && x < 425f    && y > 0f     && y < 200f                              ||
            chapter == 2  && x > 2345f   && x < 2555f   && y > 110f   && y < 320f   && z > 0f    && z < 200f   ||
            chapter == 2  && x > 2300f   && x < 2550f   && y > -160f  && y < 60f    && z > 0f    && z < 200f   ||  // older patches
            chapter == 3  && x > -2120f  && x < -1910f  && y > -2010f && y < -1800f && z > 0f    && z < 150f   ||
            chapter == 4  && x > -690f   && x < -480f   && y > -4065f && y < -3855f && z > -325f && z < -240f  ||
            chapter == 5  && x > -1365f  && x < -1155f  && y > -125f  && y <  85f   && z > 280f  && z < 350f   ||
            chapter == 6  && x > 19365f  && x < 21375f  && y > -24840f&& y < -22830f&& z > 1200f && z < 1400f  ||
            chapter == 7  && x > 25260f  && x < 27270f  && y > -24015f&& y < -22005 && z > 1190f && z < 1500f  ||
            chapter == 97 && x > -2410f  && x < -2200f  && y > -2185f && y < -1975f && z > -65f  && z < 200f   ||  // death wish
            chapter == 99 && x > 1500f   && x < 1710f   && y > 1525f  && y < 1735f  && z > 400f  && z < 500f   );  // mod levels
    };
    vars.BackToHubCheck = BackToHubCheck;

}

update {
    if(vars.threadScan.IsAlive){
        return false;
    }

    vars.watchers.UpdateAll(game);

    if (vars.chapter.Current != vars.chapter.Old){
        vars.lastChapter = vars.chapter.Old;
    }

    // game time is saved here to change it easily in the update{} block
    vars.gameTimeFinal = vars.realGameTime.Current;

    // when an act starts the game time is saved to calculate the split time when grabbing a time piece with more precision
    if (vars.actTimerIsVisible.Current == 1 && vars.actTimerIsVisible.Old == 0){
        vars.savedGameTime = vars.gameTime.Current;
    }

    // delayed time piece split activation and game time adjustment when getting a time piece
    if (vars.timePieceCount.Current == vars.timePieceCount.Old + 1 || vars.justGotTimePiece.Current == 1 && vars.justGotTimePiece.Old == 0){
        // delayed time piece split activation
        if (settings["manySplits_" + vars.chapter.Current + "_" + vars.act.Current + "_tpDelayed"]){
            vars.splitInLoadScreen = true;
        }
        // game time adjustment for a more accurate timing, this condition makes sure that the time to replace isn't completely off
        if (vars.savedGameTime + vars.realActTime.Current > vars.realGameTime.Current - 0.1 && vars.savedGameTime + vars.realActTime.Current < vars.realGameTime.Current + 0.1){
            vars.gameTimeFinal = vars.savedGameTime + vars.realActTime.Current;
        }
    }
    // actions taken when timer unpauses
    if (vars.gameTimerIsPaused.Current == 0 && vars.gameTimerIsPaused.Old == 1){
        vars.splitInLoadScreen = false;
        vars.posSplitKey = 0f;
        vars.currentRift = (vars.BackToHubCheck(vars.chapter.Current, vars.x.Current, vars.y.Current, vars.z.Current) ? "none" : vars.currentRift);
    }
    if (vars.timerState.Current == 0){
        vars.currentRift = "none";
    }

    if (vars.justEnteredRift){
        vars.justEnteredRift = false;
    }
    // rift entry detection
    if (vars.gameTimerIsPaused.Changed && vars.currentRift == "none" && settings["manySplits"]){
        vars.currentRift = vars.CurrentRiftCheck(vars.chapter.Current, vars.x.Current, vars.y.Current, vars.z.Current);
        if (vars.currentRift != "none"){
            vars.justEnteredRift = true;
        }
    }
    // position split key detection, note that only chapters 4 and 5 have this kind of split so this is ignored for other chapters
    if (vars.chapter.Current == 4 || vars.chapter.Current == 5){
        foreach (var position in vars.posSplitKeysDict[vars.chapter.Current]){ 
            if ((vars.x.Current > position[0] || position[0] == -2f) && (vars.x.Current < position[1] || position[1] == -2f) && 
                (vars.y.Current > position[2] || position[2] == -2f) && (vars.y.Current < position[3] || position[3] == -2f) && 
                (vars.z.Current > position[4] || position[4] == -2f) && (vars.z.Current < position[5] || position[5] == -2f)){
                vars.posSplitKey = position[6];
            }
        }
    }

}

start {
    return (settings["settings_newFileStart"] && vars.timerState.Current == 1 && vars.timerState.Old == 0 && (vars.timePieceCount.Current == 0 || vars.timePieceCount.Current == -1))
        || (!settings["settings_newFileStart"] && vars.timerState.Current == 1 && vars.timerState.Old == 0)
        || (settings["settings_ILMode"] && vars.actTimerIsVisible.Current == 1 && vars.realActTime.Current == 0);
}

split {
    return  vars.splitsLock.ElapsedMilliseconds > 1000
            &&
            vars.timerState.Current != 0
            &&
            (
            settings["splits"] 
            &&
                (
                vars.timePieceCount.Current == vars.timePieceCount.Old + 1 && settings["splits_tp_new"]  // new time piece
                ||
                vars.justGotTimePiece.Current == 1 && vars.justGotTimePiece.Old == 0 && settings["splits_tp_any"] // any time piece
                ||
                vars.actTimerIsVisible.Current == 1 && vars.actTimerIsVisible.Old == 0 && vars.currentRift == "none" && settings["splits_actEntry"] && !settings["settings_ILMode"] // act entry
                ||
                vars.justGotTimePiece.Current == 1 && vars.justGotTimePiece.Old == 0  && vars.chapter.Current == 3 && vars.lastChapter == 5 && settings["splits_tp_std"]  // seal the deal time piece
                ||
                vars.chapter.Current == 97 && vars.chapter.Old != 97 && settings["splits_dwbth"] && (settings["splits_dwbth_doubleSplitNo"] && vars.splitsLock.ElapsedMilliseconds > 9000 || !settings["splits_dwbth_doubleSplitNo"])  // death wish back to hub
                ||
                vars.yarn.Current == vars.yarn.Old + 1 && settings["splits_yarn"] // yarn
                ||
                vars.checkpoint.Current != vars.checkpoint.Old && vars.checkpoint.Current != 0 && settings["splits_checkpoint"] // checkpoint
                )
            ||
            settings["manySplits"] && vars.currentRift == "none"
            &&
                (
                (vars.timePieceCount.Current == vars.timePieceCount.Old + 1 || vars.justGotTimePiece.Current == 1 && vars.justGotTimePiece.Old == 0) && (settings["manySplits_" + vars.chapter.Current + "_" + vars.act.Current + "_tp"] || settings["manySplits_" + vars.chapter.Current + "_tp"])  // custom time pieces
                ||
                vars.checkpoint.Current != vars.checkpoint.Old && settings["manySplits_" + vars.chapter.Current + "_" + vars.act.Current + "_cp" + vars.checkpoint.Current] // new act checkpoint
                ||
                vars.posSplitKey != 0f && settings["manySplits_pos_" + vars.posSplitKey.ToString()] && vars.ShouldSplitAtThisPos(vars.x.Current, vars.y.Current, vars.z.Current, vars.posSplitsDict[vars.posSplitKey]) // position splits
                ||
                vars.splitInLoadScreen && vars.gameTimerIsPaused.Current == 1 && vars.gameTimerIsPaused.Old == 0  // delayed custom time pieces
                ||
                vars.actTimerIsVisible.Current == 1 && vars.actTimerIsVisible.Old == 0 && !settings["settings_ILMode"] && (settings["manySplits_" + vars.chapter.Current + "_" + vars.act.Current + "_entry"] || settings["manySplits_" + vars.chapter.Current + "_entry"]) // custom act entry
                ||
                vars.gameTimerIsPaused.Current == 1 && vars.gameTimerIsPaused.Old == 0 && settings["manySplits_" + vars.chapter.Current + "_" + vars.act.Current + "_cp" + vars.checkpoint.Current + "_pause"] // paused with certain checkpoint
                ||
                vars.gameTimerIsPaused.Changed && vars.ShouldSplitAtThisPosPause(vars.chapter.Current, vars.x.Current, vars.y.Current, vars.z.Current) // position splits when timer is paused / unpaused
                )
            ||
            settings["manySplits"] && vars.currentRift != "none"
            &&
                (
                (vars.timePieceCount.Current == vars.timePieceCount.Old + 1 || vars.justGotTimePiece.Current == 1 && vars.justGotTimePiece.Old == 0) && (settings[vars.currentRift + "_tp"]) // custom time piece (rifts)
                ||
                vars.checkpoint.Current > vars.checkpoint.Old && settings[vars.currentRift + "_cp"] // new purple rift checkpoint
                ||
                vars.justEnteredRift && settings[vars.currentRift + "_entry"] && !settings["settings_ILMode"] && vars.splitsLock.ElapsedMilliseconds > 3000 // rift entry
                )
            );
}

reset {
    return (vars.timerState.Current == 0 && vars.timerState.Old == 1 
        || settings["settings_ILMode"] && (vars.actTimerIsVisible.Current == 0 && vars.actTimerIsVisible.Old == 1 || vars.realActTime.Current < vars.realActTime.Old && vars.realActTime.Current == 0f));
}

isLoading {
    return true;
}

gameTime {
    return settings["settings_ILMode"] ? TimeSpan.FromSeconds(vars.realActTime.Current) : TimeSpan.FromSeconds(vars.gameTimeFinal);
}

shutdown {
    timer.OnSplit -= vars.splitActions;
}