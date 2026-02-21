using { /Verse.org/Simulation }
# Sprint 3 combat core: respawn timing and post-spawn invulnerability windows.

respawn_manager := class:
    var RespawnDelaySeconds : float = 4.0
    var SpawnInvulnerabilitySeconds : float = 2.0
    var PendingRespawnTimerByPlayer : [agent]float = map{}
    var PendingInvulnerabilityTimerByPlayer : [agent]float = map{}
    var RespawnEventLog : []string = array{}

    StartRespawn(Player : agent) : void =
        if (set PendingRespawnTimerByPlayer[Player] = RespawnDelaySeconds) {}
        set RespawnEventLog += array{"StartRespawn: {Player} Delay={RespawnDelaySeconds}"}

    Tick(
        DeltaTime : float,
        HealthManager : Combat.health_manager,
        DamagePipeline : Combat.damage_pipeline
    ) : void =
        for (Player -> TimeRemaining : PendingRespawnTimerByPlayer):
            NewRemaining := TimeRemaining - DeltaTime
            if (NewRemaining <= 0.0):
                FinalizeRespawn(Player, HealthManager, DamagePipeline)
                if (set PendingRespawnTimerByPlayer[Player] = 0.0) {}
            else:
                if (set PendingRespawnTimerByPlayer[Player] = NewRemaining) {}

        for (Player -> InvulnRemaining : PendingInvulnerabilityTimerByPlayer):
            NewInvulnRemaining := InvulnRemaining - DeltaTime
            if (NewInvulnRemaining <= 0.0):
                DamagePipeline.SetInvulnerable(Player, false)
                if (set PendingInvulnerabilityTimerByPlayer[Player] = 0.0) {}
                set RespawnEventLog += array{"InvulnerabilityExpired: {Player}"}
            else:
                if (set PendingInvulnerabilityTimerByPlayer[Player] = NewInvulnRemaining) {}

    FinalizeRespawn(
        Player : agent,
        HealthManager : Combat.health_manager,
        DamagePipeline : Combat.damage_pipeline
    ) : void =
        HealthManager.ResetToFullHealth(Player)
        DamagePipeline.SetInvulnerable(Player, true)
        if (set PendingInvulnerabilityTimerByPlayer[Player] = SpawnInvulnerabilitySeconds) {}
        set RespawnEventLog += array{"FinalizeRespawn: {Player} Invuln={SpawnInvulnerabilitySeconds}"}

    SetRespawnSettings(DelaySeconds : float, InvulnerabilitySeconds : float) : void =
        if (DelaySeconds > 0.0):
            set RespawnDelaySeconds = DelaySeconds
        if (InvulnerabilitySeconds > 0.0):
            set SpawnInvulnerabilitySeconds = InvulnerabilitySeconds

