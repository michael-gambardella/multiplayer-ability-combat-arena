using { /Verse.org/Simulation }

match_runtime_coordinator<public> := class(Core.game_state_listener):
    var RuntimeStateEventLog : []string = array{}

    OnRuntimePlayerJoined<public>(
        Player : agent,
        CurrentState : Core.game_state,
        PlayerManager : Core.player_manager,
        TeamManager : Core.team_manager,
        HeroSelectManager : Match.hero_select_manager,
        PopulationManager : Match.match_population_manager
    ) : void =
        PlayerManager.OnPlayerJoined(Player, TeamManager)

        if ((CurrentState = Core.game_state.HeroSelect)):
            HeroSelectManager.RegisterEligiblePlayer(Player)

        if ((CurrentState = Core.game_state.InProgress)):
            HeroSelectManager.ForceAssignDefaultHero(Player)

        PopulationManager.OnPlayerJoinedOrReturned(TeamManager)

    OnRuntimePlayerLeft<public>(
        Player : agent,
        PlayerManager : Core.player_manager,
        TeamManager : Core.team_manager,
        HeroSelectManager : Match.hero_select_manager,
        PopulationManager : Match.match_population_manager
    ) : void =
        HeroSelectManager.RemoveEligiblePlayer(Player)
        PlayerManager.OnPlayerLeft(Player, TeamManager)
        PopulationManager.OnPlayerLeft(TeamManager)

    OnStateChanged<override>(Previous : Core.game_state, Current : Core.game_state) : void =
        set RuntimeStateEventLog += array{"OnStateChanged"}

    OnTransitionBlocked<override>(From : Core.game_state, To : Core.game_state) : void =
        set RuntimeStateEventLog += array{"OnTransitionBlocked"}

