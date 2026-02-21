# Sprint 2 core: state graph, guarded transitions, and transition log hooks.

game_state := enum:
    WaitingForPlayers
    HeroSelect
    Countdown
    InProgress
    MatchEnd

game_state_listener := interface:
    OnStateChanged(Previous : game_state, Current : game_state) : void
    OnTransitionBlocked(From : game_state, To : game_state) : void

game_state_manager := class:
    var CurrentState : game_state = game_state.WaitingForPlayers
    var TransitionLog : []string = array{}
    var StateListeners : []game_state_listener = array{}

    RegisterStateListener(Listener : game_state_listener) : void =
        if (not HasListener(Listener)):
            set StateListeners += array{Listener}

    UnregisterStateListener(Listener : game_state_listener) : void =
        var Filtered : []game_state_listener = array{}
        for (Existing : StateListeners):
            if (Existing <> Listener):
                set Filtered += array{Existing}
        set StateListeners = Filtered

    SetState(NewState : game_state) : void =
        Previous := CurrentState
        set CurrentState = NewState
        set TransitionLog += array{"State changed: {Previous} -> {NewState}"}
        DispatchStateChanged(Previous, NewState)

    CanTransition(From : game_state, To : game_state) : logic =
        if (From = game_state.WaitingForPlayers and To = game_state.HeroSelect):
            return true
        if (From = game_state.HeroSelect and To = game_state.Countdown):
            return true
        if (From = game_state.Countdown and To = game_state.InProgress):
            return true
        if (From = game_state.InProgress and To = game_state.MatchEnd):
            return true
        if (From = game_state.MatchEnd and To = game_state.WaitingForPlayers):
            return true
        return false

    TryTransition(To : game_state) : logic =
        if (CanTransition(CurrentState, To)):
            SetState(To)
            return true
        set TransitionLog += array{"Blocked transition from {CurrentState} to {To}"}
        DispatchTransitionBlocked(CurrentState, To)
        return false

    GetTransitionLog() : []string =
        return TransitionLog

    DispatchStateChanged(Previous : game_state, Current : game_state) : void =
        for (Listener : StateListeners):
            Listener.OnStateChanged(Previous, Current)

    DispatchTransitionBlocked(From : game_state, To : game_state) : void =
        for (Listener : StateListeners):
            Listener.OnTransitionBlocked(From, To)

    HasListener(Listener : game_state_listener) : logic =
        for (Existing : StateListeners):
            if (Existing = Listener):
                return true
        return false
