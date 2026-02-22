# Sprint 2/3 integration: concrete listener for game_state_manager callbacks.

state_debug_listener<public> := class(Core.game_state_listener):
    var ListenerEventLog : []string = array{}

    OnStateChanged<override>(Previous : Core.game_state, Current : Core.game_state) : void =
        set ListenerEventLog += array{"OnStateChanged"}

    OnTransitionBlocked<override>(From : Core.game_state, To : Core.game_state) : void =
        set ListenerEventLog += array{"OnTransitionBlocked"}
