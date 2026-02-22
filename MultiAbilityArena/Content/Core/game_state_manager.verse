# Sprint 2 core: state graph, guarded transitions, and transition log hooks.

game_state<public> := enum:
    WaitingForPlayers
    HeroSelect
    Countdown
    InProgress
    MatchEnd

game_state_listener<public> := interface:
    OnStateChanged<public>(Previous : game_state, Current : game_state) : void
    OnTransitionBlocked<public>(From : game_state, To : game_state) : void

game_state_manager<public> := class:
    var CurrentState : game_state = game_state.WaitingForPlayers
    var TransitionLog : []string = array{}
    var StateListeners : []game_state_listener = array{}

    RegisterStateListener<public>(Listener : game_state_listener) : void =
        set StateListeners += array{Listener}

    UnregisterAllStateListeners<public>() : void =
        set StateListeners = array{}

    SetState<public>(NewState : game_state) : void =
        Previous := CurrentState
        set CurrentState = NewState
        set TransitionLog += array{"StateChanged"}
        DispatchStateChanged(Previous, NewState)

    CanTransition<public>(From : game_state, To : game_state) : logic =
        if ((From = game_state.WaitingForPlayers and To = game_state.HeroSelect)):
            return true
        if ((From = game_state.HeroSelect and To = game_state.Countdown)):
            return true
        if ((From = game_state.Countdown and To = game_state.InProgress)):
            return true
        if ((From = game_state.InProgress and To = game_state.MatchEnd)):
            return true
        if ((From = game_state.MatchEnd and To = game_state.WaitingForPlayers)):
            return true
        return false

    TryTransition<public>(To : game_state) : logic =
        TransitionAllowed := CanTransition(CurrentState, To)
        if (TransitionAllowed = true):
            SetState(To)
            return true
        set TransitionLog += array{"TransitionBlocked"}
        DispatchTransitionBlocked(CurrentState, To)
        return false

    GetTransitionLog<public>() : []string =
        return TransitionLog

    DispatchStateChanged(Previous : game_state, Current : game_state) : void =
        for (Listener : StateListeners):
            Listener.OnStateChanged(Previous, Current)

    DispatchTransitionBlocked(From : game_state, To : game_state) : void =
        for (Listener : StateListeners):
            Listener.OnTransitionBlocked(From, To)

