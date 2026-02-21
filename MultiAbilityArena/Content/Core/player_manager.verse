using { /Verse.org/Simulation }
# Sprint 2 core: player join/leave lifecycle with team mapping and cleanup.

player_manager := class:
    var ActivePlayers : []agent = array{}
    var PlayerTeamMap : [agent]team_id = map{}
    # Placeholder runtime-state caches so leave cleanup has explicit ownership.
    var PlayerCooldownState : [agent]logic = map{}
    var PlayerStatusState : [agent]logic = map{}
    var PlayerHeroState : [agent]string = map{}

    OnPlayerJoined(Player : agent, TeamManager : team_manager) : void =
        set ActivePlayers += array{Player}
        AssignedTeam := TeamManager.AssignToSmallerTeam(Player)
        if (set PlayerTeamMap[Player] = AssignedTeam) {}
        if (set PlayerCooldownState[Player] = false) {}
        if (set PlayerStatusState[Player] = false) {}
        if (set PlayerHeroState[Player] = "None") {}
        # TODO: call hero initialization from hero select or runtime coordinator.

    OnPlayerLeft(Player : agent, TeamManager : team_manager) : void =
        var NewActivePlayers : []agent = array{}
        for (RosterPlayer : ActivePlayers):
            if (RosterPlayer <> Player):
                set NewActivePlayers += array{RosterPlayer}
        set ActivePlayers = NewActivePlayers

        TeamManager.Remove(Player)
        CleanupPlayerRuntimeState(Player)
        RemovePlayerTeamMapping(Player)

    CleanupPlayerRuntimeState(Player : agent) : void =
        RemovePlayerCooldownState(Player)
        RemovePlayerStatusState(Player)
        RemovePlayerHeroState(Player)

    GetPlayerCount() : int =
        return ActivePlayers.Length

    RemovePlayerTeamMapping(Player : agent) : void =
        var Filtered : [agent]team_id = map{}
        for (ExistingPlayer -> ExistingTeam : PlayerTeamMap):
            if (ExistingPlayer <> Player):
                if (set Filtered[ExistingPlayer] = ExistingTeam) {}
        set PlayerTeamMap = Filtered

    RemovePlayerCooldownState(Player : agent) : void =
        var Filtered : [agent]logic = map{}
        for (ExistingPlayer -> ExistingValue : PlayerCooldownState):
            if (ExistingPlayer <> Player):
                if (set Filtered[ExistingPlayer] = ExistingValue) {}
        set PlayerCooldownState = Filtered

    RemovePlayerStatusState(Player : agent) : void =
        var Filtered : [agent]logic = map{}
        for (ExistingPlayer -> ExistingValue : PlayerStatusState):
            if (ExistingPlayer <> Player):
                if (set Filtered[ExistingPlayer] = ExistingValue) {}
        set PlayerStatusState = Filtered

    RemovePlayerHeroState(Player : agent) : void =
        var Filtered : [agent]string = map{}
        for (ExistingPlayer -> ExistingValue : PlayerHeroState):
            if (ExistingPlayer <> Player):
                if (set Filtered[ExistingPlayer] = ExistingValue) {}
        set PlayerHeroState = Filtered

