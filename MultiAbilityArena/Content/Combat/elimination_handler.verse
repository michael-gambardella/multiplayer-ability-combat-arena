using { /Verse.org/Simulation }

elimination_handler<public> := class:
    var LastHitByPlayer : [agent]agent = map{}
    var LastDamageTimeByPlayer : [agent]float = map{}
    var EliminationEventLog : []string = array{}

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

        TargetAlive := HealthManager.IsAlive(Target)
        if (TargetAlive = false):
            return false

        HealthManager.SetAliveState(Target, false)
        RespawnManager.StartRespawn(Target)
        set EliminationEventLog += array{"Eliminated"}
        return true

