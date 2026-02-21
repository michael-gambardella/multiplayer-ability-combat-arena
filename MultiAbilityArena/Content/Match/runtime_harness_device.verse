using { /Fortnite.com/Devices }

# Runtime harness device: registers game-state listeners at startup.
# Place one instance in the level so OnBegin executes in-session.
runtime_harness_device := class<public><concrete>(creative_device):
    var GameStateManager : Core.game_state_manager = Core.game_state_manager{}
    var StateDebugListener : Core.state_debug_listener = Core.state_debug_listener{}
    var RuntimeCoordinator : match_runtime_coordinator = match_runtime_coordinator{}

    OnBegin<override>()<suspends> : void =
        GameStateManager.RegisterStateListener(RuntimeCoordinator)
        GameStateManager.RegisterStateListener(StateDebugListener)
