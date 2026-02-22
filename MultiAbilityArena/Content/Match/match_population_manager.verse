match_population_manager<public> := class:
    var MinPlayersToRun : int = 4
    var BackfillGraceSeconds : float = 30.0
    var RemainingBackfillSeconds : float = 30.0
    var IsPausedForBackfill : logic = false
    var ForfeitTriggered : logic = false

    EvaluatePopulation<public>(TeamManager : Core.team_manager) : void =
        CurrentPlayers := TeamManager.GetTotalPlayers()
        if ((CurrentPlayers < MinPlayersToRun)):
            if ((IsPausedForBackfill = false)):
                set IsPausedForBackfill = true
                set RemainingBackfillSeconds = BackfillGraceSeconds
        else:
            set IsPausedForBackfill = false
            set RemainingBackfillSeconds = BackfillGraceSeconds
            set ForfeitTriggered = false

    TickBackfill<public>(DeltaTime : float) : logic =
        if ((IsPausedForBackfill = false)):
            return false

        set RemainingBackfillSeconds = RemainingBackfillSeconds - DeltaTime
        if ((RemainingBackfillSeconds <= 0.0)):
            set ForfeitTriggered = true
            return true
        return false

    OnPlayerJoinedOrReturned<public>(TeamManager : Core.team_manager) : void =
        EvaluatePopulation(TeamManager)

    OnPlayerLeft<public>(TeamManager : Core.team_manager) : void =
        EvaluatePopulation(TeamManager)

