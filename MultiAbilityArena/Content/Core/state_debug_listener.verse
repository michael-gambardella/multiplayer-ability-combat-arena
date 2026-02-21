# Sprint 2/3 integration: concrete listener for game_state_manager callbacks.

state_debug_listener := class(game_state_listener):
    var ListenerEventLog : []string = array{}

    OnStateChanged(Previous : game_state, Current : game_state) : void =
        set ListenerEventLog += array{"OnStateChanged: {Previous}->{Current}"}

    OnTransitionBlocked(From : game_state, To : game_state) : void =
        set ListenerEventLog += array{"OnTransitionBlocked: {From}->{To}"}
