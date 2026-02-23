using { /Verse.org/Simulation }

elimination_handler<public> := class:
    var LastHitByPlayer : [agent]agent = map{}
    var LastDamageTimeByPlayer : [agent]float = map{}
    var EliminationEventLog : []string = array{}
    var LifecycleListeners : []Combat.combat_event_listener = array{}

    RegisterLifecycleListener<public>(Listener : Combat.combat_event_listener) : void =
        set LifecycleListeners += array{Listener}

    UnregisterAllLifecycleListeners<public>() : void =
        set LifecycleListeners = array{}

    RegisterDamageEvent<public>(Source : agent, Target : agent, TimestampSeconds : float) : void =
        if (set LastHitByPlayer[Target] = Source) {}
        if (set LastDamageTimeByPlayer[Target] = TimestampSeconds) {}

    HandlePostDamage<public>(
        Target : agent,
        CurrentTimeSeconds : float,
        HealthManager : Combat.health_manager,
        RespawnManager : Match.respawn_manager
    ) : logic =
        CurrentHP := HealthManager.GetCurrentHP(Target)
        if ((CurrentHP > 0.0)):
            return false

        HealthManager.SetAliveState(Target, false)
        RespawnManager.StartRespawn(Target)
        set EliminationEventLog += array{"Eliminated"}
        Source := GetLastDamageSourceOrTarget(Target)
        DispatchElimination(Source, Target)
        return true

    GetLastDamageSourceOrTarget(Target : agent) : agent =
        if (Source := LastHitByPlayer[Target]):
            return Source
        return Target

    DispatchElimination(Source : agent, Target : agent) : void =
        for (Listener : LifecycleListeners):
            Listener.OnElimination(Source, Target)

