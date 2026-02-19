# Sprint 2 core: state graph, guarded transitions, and transition log hooks.

game_state := enum:
    WaitingForPlayers
    HeroSelect
    Countdown
    InProgress
    MatchEnd

# TODO: replace debug list with listenable events once full device wiring is in place.
game_state_manager := class:
    var CurrentState : game_state = game_state.WaitingForPlayers
    var TransitionLog : []string = array{}

    SetState(NewState : game_state) : void =
        Previous := CurrentState
        set CurrentState = NewState
        set TransitionLog += array{"State changed: {Previous} -> {NewState}"}

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
        return false

    GetTransitionLog() : []string =
        return TransitionLog
