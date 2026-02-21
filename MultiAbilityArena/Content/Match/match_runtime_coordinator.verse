using { /Verse.org/Simulation }
# Sprint 2 core: runtime join/leave wiring beyond static team assignment.

match_runtime_coordinator := class(Core.game_state_listener):
    var RuntimeStateEventLog : []string = array{}

    OnRuntimePlayerJoined(
        Player : agent,
        CurrentState : Core.game_state,
        PlayerManager : Core.player_manager,
        TeamManager : Core.team_manager,
        HeroSelectManager : hero_select_manager,
        PopulationManager : match_population_manager
    ) : void =
        PlayerManager.OnPlayerJoined(Player, TeamManager)

        if (CurrentState = Core.game_state.HeroSelect):
            HeroSelectManager.RegisterEligiblePlayer(Player)

        if (CurrentState = Core.game_state.InProgress):
            # Late joiners in active match receive default hero assignment immediately.
            HeroSelectManager.ForceAssignDefaultHero(Player)

        PopulationManager.OnPlayerJoinedOrReturned(TeamManager)

    OnRuntimePlayerLeft(
        Player : agent,
        PlayerManager : Core.player_manager,
        TeamManager : Core.team_manager,
        HeroSelectManager : hero_select_manager,
        PopulationManager : match_population_manager
    ) : void =
        HeroSelectManager.RemoveEligiblePlayer(Player)
        PlayerManager.OnPlayerLeft(Player, TeamManager)
        PopulationManager.OnPlayerLeft(TeamManager)

    OnStateChanged(Previous : Core.game_state, Current : Core.game_state) : void =
        set RuntimeStateEventLog += array{"OnStateChanged: {Previous}->{Current}"}

    OnTransitionBlocked(From : Core.game_state, To : Core.game_state) : void =
        set RuntimeStateEventLog += array{"OnTransitionBlocked: {From}->{To}"}

