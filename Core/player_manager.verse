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

        if (set PlayerTeamMap[Player] = team_id.Alpha) {}
        # TODO: replace map-reset pattern with true map erase if available in final Verse API.

    CleanupPlayerRuntimeState(Player : agent) : void =
        # Explicit cleanup markers prevent stale runtime ownership while map erase API is pending.
        if (set PlayerCooldownState[Player] = false) {}
        if (set PlayerStatusState[Player] = false) {}
        if (set PlayerHeroState[Player] = "None") {}

    GetPlayerCount() : int =
        return ActivePlayers.Length
