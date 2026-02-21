using { /Verse.org/Simulation }
# Sprint 3 combat core: elimination detection and respawn handoff.

elimination_handler := class:
    var LastHitByPlayer : [agent]agent = map{}
    var LastDamageTimeByPlayer : [agent]float = map{}
    var EliminationEventLog : []string = array{}

    RegisterDamageEvent(Source : agent, Target : agent, TimestampSeconds : float) : void =
        if (set LastHitByPlayer[Target] = Source) {}
        if (set LastDamageTimeByPlayer[Target] = TimestampSeconds) {}

    HandlePostDamage(
        Target : agent,
        CurrentTimeSeconds : float,
        HealthManager : health_manager,
        RespawnManager : Match.respawn_manager
    ) : logic =
        if (HealthManager.GetCurrentHP(Target) > 0.0):
            return false

        if (not HealthManager.IsAlive(Target)):
            return false

        HealthManager.SetAliveState(Target, false)
        RespawnManager.StartRespawn(Target)

        EliminatorLabel := "Unknown"
        if (Killer := LastHitByPlayer[Target]):
            EliminatorLabel = "{Killer}"

        set EliminationEventLog += array{"Eliminated: Victim={Target} Killer={EliminatorLabel} Time={CurrentTimeSeconds}"}
        return true

