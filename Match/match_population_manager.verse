# Sprint 2 core: minimum-player pause/backfill handling.

match_population_manager := class:
    var MinPlayersToRun : int = 4
    var BackfillGraceSeconds : float = 30.0
    var RemainingBackfillSeconds : float = 30.0
    var IsPausedForBackfill : logic = false
    var ForfeitTriggered : logic = false

    EvaluatePopulation(TeamManager : team_manager) : void =
        CurrentPlayers := TeamManager.GetTotalPlayers()
        if (CurrentPlayers < MinPlayersToRun):
            if (not IsPausedForBackfill):
                set IsPausedForBackfill = true
                set RemainingBackfillSeconds = BackfillGraceSeconds
        else:
            set IsPausedForBackfill = false
            set RemainingBackfillSeconds = BackfillGraceSeconds
            set ForfeitTriggered = false

    TickBackfill(DeltaTime : float) : logic =
        if (not IsPausedForBackfill):
            return false

        set RemainingBackfillSeconds = RemainingBackfillSeconds - DeltaTime
        if (RemainingBackfillSeconds <= 0.0):
            set ForfeitTriggered = true
            return true
        return false

    OnPlayerJoinedOrReturned(TeamManager : team_manager) : void =
        EvaluatePopulation(TeamManager)

    OnPlayerLeft(TeamManager : team_manager) : void =
        EvaluatePopulation(TeamManager)
