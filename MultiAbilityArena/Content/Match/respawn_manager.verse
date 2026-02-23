using { /Verse.org/Simulation }

respawn_manager<public> := class:
    var RespawnDelaySeconds : float = 4.0
    var SpawnInvulnerabilitySeconds : float = 2.0
    var PendingRespawnTimerByPlayer : [agent]float = map{}
    var PendingInvulnerabilityTimerByPlayer : [agent]float = map{}
    var RespawnEventLog : []string = array{}
    var LifecycleListeners : []Combat.combat_event_listener = array{}

    RegisterLifecycleListener<public>(Listener : Combat.combat_event_listener) : void =
        set LifecycleListeners += array{Listener}

    UnregisterAllLifecycleListeners<public>() : void =
        set LifecycleListeners = array{}

    StartRespawn<public>(Player : agent) : void =
        if (set PendingRespawnTimerByPlayer[Player] = RespawnDelaySeconds) {}
        set RespawnEventLog += array{"StartRespawn"}
        DispatchRespawnStarted(Player)

    Tick<public>(
        DeltaTime : float,
        HealthManager : Combat.health_manager,
        DamagePipeline : Combat.damage_pipeline
    ) : void =
        var ClearedRespawnPlayers : []agent = array{}
        for (Player -> TimeRemaining : PendingRespawnTimerByPlayer):
            NewRemaining := TimeRemaining - DeltaTime
            if ((NewRemaining <= 0.0)):
                FinalizeRespawn(Player, HealthManager, DamagePipeline)
                set ClearedRespawnPlayers += array{Player}
            else:
                if (set PendingRespawnTimerByPlayer[Player] = NewRemaining) {}

        for (PlayerToClear : ClearedRespawnPlayers):
            RemovePendingRespawnTimer(PlayerToClear)

        var ClearedInvulnerabilityPlayers : []agent = array{}
        for (Player -> InvulnRemaining : PendingInvulnerabilityTimerByPlayer):
            NewInvulnRemaining := InvulnRemaining - DeltaTime
            if ((NewInvulnRemaining <= 0.0)):
                DamagePipeline.SetInvulnerable(Player, false)
                set ClearedInvulnerabilityPlayers += array{Player}
                set RespawnEventLog += array{"InvulnerabilityExpired"}
                DispatchRespawnInvulnerabilityExpired(Player)
            else:
                if (set PendingInvulnerabilityTimerByPlayer[Player] = NewInvulnRemaining) {}

        for (PlayerToClear : ClearedInvulnerabilityPlayers):
            RemovePendingInvulnerabilityTimer(PlayerToClear)

    FinalizeRespawn<public>(
        Player : agent,
        HealthManager : Combat.health_manager,
        DamagePipeline : Combat.damage_pipeline
    ) : void =
        HealthManager.ResetToFullHealth(Player)
        DamagePipeline.SetInvulnerable(Player, true)
        if (set PendingInvulnerabilityTimerByPlayer[Player] = SpawnInvulnerabilitySeconds) {}
        set RespawnEventLog += array{"FinalizeRespawn"}
        DispatchRespawnFinalized(Player)

    SetRespawnSettings<public>(DelaySeconds : float, InvulnerabilitySeconds : float) : void =
        if ((DelaySeconds > 0.0)):
            set RespawnDelaySeconds = DelaySeconds
        if ((InvulnerabilitySeconds > 0.0)):
            set SpawnInvulnerabilitySeconds = InvulnerabilitySeconds

    RemovePendingRespawnTimer(Player : agent) : void =
        var Filtered : [agent]float = map{}
        for (ExistingPlayer -> ExistingValue : PendingRespawnTimerByPlayer):
            if ((ExistingPlayer <> Player)):
                if (set Filtered[ExistingPlayer] = ExistingValue) {}
        set PendingRespawnTimerByPlayer = Filtered

    RemovePendingInvulnerabilityTimer(Player : agent) : void =
        var Filtered : [agent]float = map{}
        for (ExistingPlayer -> ExistingValue : PendingInvulnerabilityTimerByPlayer):
            if ((ExistingPlayer <> Player)):
                if (set Filtered[ExistingPlayer] = ExistingValue) {}
        set PendingInvulnerabilityTimerByPlayer = Filtered

    DispatchRespawnStarted(Target : agent) : void =
        for (Listener : LifecycleListeners):
            Listener.OnRespawnStarted(Target)

    DispatchRespawnFinalized(Target : agent) : void =
        for (Listener : LifecycleListeners):
            Listener.OnRespawnFinalized(Target)

    DispatchRespawnInvulnerabilityExpired(Target : agent) : void =
        for (Listener : LifecycleListeners):
            Listener.OnRespawnInvulnerabilityExpired(Target)

