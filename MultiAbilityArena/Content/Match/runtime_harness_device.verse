using { /Fortnite.com/Devices }

runtime_harness_device := class<public><concrete>(creative_device):
    var GameStateManager : Core.game_state_manager = Core.game_state_manager{}
    var StateDebugListener : Core.state_debug_listener = Core.state_debug_listener{}
    var RuntimeCoordinator : Match.match_runtime_coordinator = Match.match_runtime_coordinator{}

    OnBegin<override>()<suspends> : void =
        GameStateManager.RegisterStateListener(RuntimeCoordinator)
        GameStateManager.RegisterStateListener(StateDebugListener)
