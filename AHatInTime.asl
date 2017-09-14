state("HatinTimeGame") {}

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
}

init {
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
}

start {
    return vars.timerState.Current == 1 && vars.timerState.Old == 0;
}

split {
    return vars.timePieceCount.Current > vars.timePieceCount.Old || vars.timerState.Current == 2;
}

reset {
    return vars.timerState.Current == 0 && vars.timerState.Old == 1;
}

isLoading {
    return true;
}

gameTime {
	return TimeSpan.FromSeconds(vars.realGameTime.Current);
}
