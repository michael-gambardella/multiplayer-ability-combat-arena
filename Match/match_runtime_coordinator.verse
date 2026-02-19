# Sprint 2 core: runtime join/leave wiring beyond static team assignment.

match_runtime_coordinator := class:
    OnRuntimePlayerJoined(
        Player : agent,
        CurrentState : game_state,
        PlayerManager : player_manager,
        TeamManager : team_manager,
        HeroSelectManager : hero_select_manager,
        PopulationManager : match_population_manager
    ) : void =
        PlayerManager.OnPlayerJoined(Player, TeamManager)

        if (CurrentState = game_state.HeroSelect):
            HeroSelectManager.RegisterEligiblePlayer(Player)

        if (CurrentState = game_state.InProgress):
            # Late joiners in active match receive default hero assignment immediately.
            HeroSelectManager.ForceAssignDefaultHero(Player)

        PopulationManager.OnPlayerJoinedOrReturned(TeamManager)

    OnRuntimePlayerLeft(
        Player : agent,
        PlayerManager : player_manager,
        TeamManager : team_manager,
        HeroSelectManager : hero_select_manager,
        PopulationManager : match_population_manager
    ) : void =
        HeroSelectManager.RemoveEligiblePlayer(Player)
        PlayerManager.OnPlayerLeft(Player, TeamManager)
        PopulationManager.OnPlayerLeft(TeamManager)
