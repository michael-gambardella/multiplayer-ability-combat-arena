using { /Fortnite.com/Devices }
using { /Fortnite.com/Playspaces }
using { /Verse.org/Simulation }

combat_event_probe_listener := class<public>(Combat.combat_event_listener):
    var EventLog : []string = array{}

    OnDamageProcessed<override>(Source : agent, Target : agent, Amount : float, Type : Combat.damage_type) : void =
        set EventLog += array{"OnDamageProcessed"}

    OnDamageBlockedByInvulnerability<override>(Source : agent, Target : agent, Type : Combat.damage_type) : void =
        set EventLog += array{"OnDamageBlockedByInvulnerability"}

    OnHealingProcessed<override>(Source : agent, Target : agent, Amount : float) : void =
        set EventLog += array{"OnHealingProcessed"}

    OnElimination<override>(Source : agent, Target : agent) : void =
        set EventLog += array{"OnElimination"}

    OnRespawnStarted<override>(Target : agent) : void =
        set EventLog += array{"OnRespawnStarted"}

    OnRespawnFinalized<override>(Target : agent) : void =
        set EventLog += array{"OnRespawnFinalized"}

    OnRespawnInvulnerabilityExpired<override>(Target : agent) : void =
        set EventLog += array{"OnRespawnInvulnerabilityExpired"}

runtime_harness_device := class<public><concrete>(creative_device):
    var GameStateManager : Core.game_state_manager = Core.game_state_manager{}
    var StateDebugListener : Core.state_debug_listener = Core.state_debug_listener{}
    var RuntimeCoordinator : Match.match_runtime_coordinator = Match.match_runtime_coordinator{}
    var HealthManager : Combat.health_manager = Combat.health_manager{}
    var DamagePipeline : Combat.damage_pipeline = Combat.damage_pipeline{}
    var EliminationHandler : Combat.elimination_handler = Combat.elimination_handler{}
    var RespawnManager : Match.respawn_manager = Match.respawn_manager{}
    var AbilitySystem : Combat.ability_system = Combat.ability_system{}
    var CooldownTracker : Combat.cooldown_tracker = Combat.cooldown_tracker{}
    var StatusManager : Combat.status_effect_manager = Combat.status_effect_manager{}
    var KnockbackApplicator : Combat.knockback_applicator = Combat.knockback_applicator{}
    var Titan : Heroes.hero_titan = Heroes.hero_titan{}
    var Specter : Heroes.hero_specter = Heroes.hero_specter{}
    var Sage : Heroes.hero_sage = Heroes.hero_sage{}
    var ProjectileSimulator : Devices.projectile_simulator = Devices.projectile_simulator{}
    var AreaEffectZone : Devices.area_effect_zone = Devices.area_effect_zone{}
    var CombatEventProbe : combat_event_probe_listener = combat_event_probe_listener{}
    var Sprint3SmokeRanByPlayer : [agent]logic = map{}

    OnBegin<override>()<suspends> : void =
        GameStateManager.RegisterStateListener(RuntimeCoordinator)
        GameStateManager.RegisterStateListener(StateDebugListener)
        DamagePipeline.RegisterLifecycleListener(CombatEventProbe)
        EliminationHandler.RegisterLifecycleListener(CombatEventProbe)
        RespawnManager.RegisterLifecycleListener(CombatEventProbe)
        RespawnManager.SetRespawnSettings(4.0, 2.0)

        for (Player : GetPlayspace().GetPlayers()):
            SetupSprint3Player(Player)

        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerAdded)
        spawn { TickCombatRuntime() }

    OnPlayerAdded(Player : player) : void =
        SetupSprint3Player(Player)

    SetupSprint3Player(Player : player) : void =
        AlreadyRan := HasRunSprint3Smoke(Player)
        if (AlreadyRan = true):
            return

        HealthManager.RegisterPlayer(Player, 100.0)
        AbilitySystem.RegisterHero(Player, "Titan")
        if (set Sprint3SmokeRanByPlayer[Player] = true) {}
        spawn { RunSprint3Smoke(Player) }

    HasRunSprint3Smoke(Player : player) : logic =
        if (Value := Sprint3SmokeRanByPlayer[Player]):
            return Value
        return false

    TickCombatRuntime()<suspends> : void =
        loop:
            RespawnManager.Tick(0.1, HealthManager, DamagePipeline)
            StatusManager.Tick(0.1)
            AllyTargets := GetCurrentPlayersAsAgents()
            ProjectileSimulator.Tick(0.1)
            AreaEffectZone.Tick(0.1, AllyTargets, HealthManager, ProjectileSimulator)
            Sleep(0.1)

    GetCurrentPlayersAsAgents() : []agent =
        var Agents : []agent = array{}
        for (Player : GetPlayspace().GetPlayers()):
            set Agents += array{Player}
        return Agents

    RunSprint3Smoke(Player : player)<suspends> : void =
        Print("S3_SMOKE_BEGIN")

        DamagePipeline.ProcessDamage(Player, Player, 30.0, Combat.damage_type.Physical, HealthManager)
        Sleep(0.1)

        DamagePipeline.ProcessHealing(Player, Player, 20.0, HealthManager)
        Sleep(0.1)

        DamagePipeline.ProcessDamage(Player, Player, 500.0, Combat.damage_type.Environmental, HealthManager)
        EliminationHandler.RegisterDamageEvent(Player, Player, 0.0)
        Eliminated := EliminationHandler.HandlePostDamage(Player, 0.0, HealthManager, RespawnManager)
        if (Eliminated = true):
            Print("S3_SMOKE_ELIM_OK")
        else:
            Print("S3_SMOKE_ELIM_MISSED")

        Sleep(4.2)
        InvulnerableNow := DamagePipeline.IsInvulnerable(Player)
        if (InvulnerableNow = true):
            Print("S3_SMOKE_INVULN_ACTIVE")
        else:
            Print("S3_SMOKE_INVULN_MISSING")

        Sleep(2.2)
        InvulnerableAfter := DamagePipeline.IsInvulnerable(Player)
        if (InvulnerableAfter = false):
            Print("S3_SMOKE_INVULN_EXPIRED")
        else:
            Print("S3_SMOKE_INVULN_STUCK")

        VerifySprint3EventSubscriberWiring()
        Print("S3_SMOKE_END")
        RunSprint4Smoke(Player)

    VerifySprint3EventSubscriberWiring() : void =
        HasDamage := HasCombatEvent("OnDamageProcessed")
        HasHealing := HasCombatEvent("OnHealingProcessed")
        HasElimination := HasCombatEvent("OnElimination")
        HasRespawnStarted := HasCombatEvent("OnRespawnStarted")
        HasRespawnFinalized := HasCombatEvent("OnRespawnFinalized")
        HasInvulnExpired := HasCombatEvent("OnRespawnInvulnerabilityExpired")

        if (HasDamage = true and HasHealing = true and HasElimination = true and HasRespawnStarted = true and HasRespawnFinalized = true and HasInvulnExpired = true):
            Print("S3_EVT_PASS")
            return

        Print("S3_EVT_FAIL")

    HasCombatEvent(EventName : string) : logic =
        for (LoggedEvent : CombatEventProbe.EventLog):
            if ((LoggedEvent = EventName)):
                return true
        return false

    RunSprint4Smoke(Player : player) : void =
        Print("S4_SMOKE_BEGIN")

        SelfOnlyTargets : []agent = array{Player}
        PrimaryActivated := AbilitySystem.TryActivate(Player, Combat.ability_slot.Primary, 0.0, SelfOnlyTargets, CooldownTracker, Titan, Specter, Sage, DamagePipeline, HealthManager, StatusManager, KnockbackApplicator, ProjectileSimulator, AreaEffectZone)
        PrimaryBlocked := AbilitySystem.TryActivate(Player, Combat.ability_slot.Primary, 0.1, SelfOnlyTargets, CooldownTracker, Titan, Specter, Sage, DamagePipeline, HealthManager, StatusManager, KnockbackApplicator, ProjectileSimulator, AreaEffectZone)
        PrimaryRemaining := AbilitySystem.GetRemainingCooldown(Player, Combat.ability_slot.Primary, 0.1, CooldownTracker)

        if (PrimaryActivated = true and PrimaryBlocked = false and PrimaryRemaining > 0.0):
            Print("S4_COOLDOWN_PASS")
        else:
            Print("S4_COOLDOWN_FAIL")

        FullTravel := Titan.SimulateBarrierChargePath(10.0, 0.0, false)
        CollisionTravel := Titan.SimulateBarrierChargePath(10.0, 3.0, true)
        if ((FullTravel = 10.0 and CollisionTravel = 3.0)):
            Print("S4_PATH_PASS")
        else:
            Print("S4_PATH_FAIL")

        SecondaryActivated := AbilitySystem.TryActivate(Player, Combat.ability_slot.Secondary, 13.0, SelfOnlyTargets, CooldownTracker, Titan, Specter, Sage, DamagePipeline, HealthManager, StatusManager, KnockbackApplicator, ProjectileSimulator, AreaEffectZone)
        UltimateActivated := AbilitySystem.TryActivate(Player, Combat.ability_slot.Ultimate, 80.0, SelfOnlyTargets, CooldownTracker, Titan, Specter, Sage, DamagePipeline, HealthManager, StatusManager, KnockbackApplicator, ProjectileSimulator, AreaEffectZone)
        if (SecondaryActivated = true and UltimateActivated = true):
            Print("S4_ACTIVATION_PASS")
        else:
            Print("S4_ACTIVATION_FAIL")

        HasSlam := Titan.HasTitanEvent("SeismicSlam")
        HasCharge := Titan.HasTitanEvent("BarrierCharge")
        HasShatter := Titan.HasTitanEvent("Earthshatter")
        if (HasSlam = true and HasCharge = true and HasShatter = true):
            Print("S4_TITAN_EVENTS_PASS")
        else:
            Print("S4_TITAN_EVENTS_FAIL")

        Print("S4_SMOKE_END")
        RunSprint5Smoke(Player)

    RunSprint5Smoke(Player : player) : void =
        Print("S5_SMOKE_BEGIN")
        AbilitySystem.RegisterHero(Player, "Specter")

        StatusManager.ApplySlowFromSourceKey(Player, 2.0, 0.20, 1)
        StatusManager.ApplySlowFromSourceKey(Player, 5.0, 0.20, 1)
        SlowAfterRefresh := StatusManager.GetSlowRemaining(Player)
        if (SlowAfterRefresh >= 5.0):
            Print("S5_SAME_SOURCE_REFRESH_PASS")
        else:
            Print("S5_SAME_SOURCE_REFRESH_FAIL")

        StatusManager.ApplySlowFromSourceKey(Player, 3.0, 0.60, 2)
        SlowMagnitude := StatusManager.GetSlowMagnitude(Player)
        if (SlowMagnitude >= 0.60):
            Print("S5_STRONGEST_SOURCE_PASS")
        else:
            Print("S5_STRONGEST_SOURCE_FAIL")

        StatusManager.ApplyInvisibility(Player, 3.0, Player)
        var InvisibleBeforePurge : logic = false
        InvisibleBeforeValue := StatusManager.IsInvisible(Player)
        if (InvisibleBeforeValue = true):
            set InvisibleBeforePurge = true

        StatusManager.ApplyStunFromSourceKey(Player, 2.0, 2)
        StatusManager.ApplyDeathMarkFromSourceKey(Player, 4.0, 0.25, 2)
        StatusManager.PurgeNegativeEffects(Player)
        var ClearedStun : logic = true
        StunnedAfterPurge := StatusManager.IsStunned(Player)
        if (StunnedAfterPurge = true):
            set ClearedStun = false

        var ClearedMark : logic = true
        MarkedAfterPurge := StatusManager.IsMarked(Player)
        if (MarkedAfterPurge = true):
            set ClearedMark = false

        var InvisibleAfterPurge : logic = false
        InvisibleAfterValue := StatusManager.IsInvisible(Player)
        if (InvisibleAfterValue = true):
            set InvisibleAfterPurge = true

        if (InvisibleBeforePurge = true and InvisibleAfterPurge = true and ClearedStun = true and ClearedMark = true):
            Print("S5_PURGE_RULES_PASS")
        else:
            Print("S5_PURGE_RULES_FAIL")

        SelfOnlyTargets : []agent = array{Player}
        SpecterInvisActivated := AbilitySystem.TryActivate(Player, Combat.ability_slot.Secondary, 200.0, SelfOnlyTargets, CooldownTracker, Titan, Specter, Sage, DamagePipeline, HealthManager, StatusManager, KnockbackApplicator, ProjectileSimulator, AreaEffectZone)
        SpecterMarkActivated := AbilitySystem.TryActivate(Player, Combat.ability_slot.Ultimate, 260.0, SelfOnlyTargets, CooldownTracker, Titan, Specter, Sage, DamagePipeline, HealthManager, StatusManager, KnockbackApplicator, ProjectileSimulator, AreaEffectZone)
        SpecterStrikeActivated := AbilitySystem.TryActivate(Player, Combat.ability_slot.Primary, 300.0, SelfOnlyTargets, CooldownTracker, Titan, Specter, Sage, DamagePipeline, HealthManager, StatusManager, KnockbackApplicator, ProjectileSimulator, AreaEffectZone)

        MarkedStrikeDamage := Specter.GetMarkedStrikeDamage(Player, StatusManager)
        BaseStrikeDamage := Specter.GetTeleportStrikeDamage()
        if (MarkedStrikeDamage > BaseStrikeDamage):
            Print("S5_MARK_AMPLIFY_PASS")
        else:
            Print("S5_MARK_AMPLIFY_FAIL")

        HasTeleport := Specter.HasSpecterEvent("TeleportStrike")
        HasInvisibility := Specter.HasSpecterEvent("SmokeInvisibility")
        HasMark := Specter.HasSpecterEvent("DeathMark")
        if (SpecterInvisActivated = true and SpecterMarkActivated = true and SpecterStrikeActivated = true and HasTeleport = true and HasInvisibility = true and HasMark = true):
            Print("S5_SPECTER_KIT_PASS")
        else:
            Print("S5_SPECTER_KIT_FAIL")

        Print("S5_SMOKE_END")
        RunSprint6Smoke(Player)

    RunSprint6Smoke(Player : player) : void =
        Print("S6_SMOKE_BEGIN")
        AbilitySystem.RegisterHero(Player, "Sage")

        HealthManager.ResetToFullHealth(Player)
        DamagePipeline.ProcessDamage(Player, Player, 30.0, Combat.damage_type.Physical, HealthManager)
        HPBeforeAllyHeal := HealthManager.GetCurrentHP(Player)

        SelfOnlyTargets : []agent = array{Player}
        AllyOrbActivated := AbilitySystem.TryActivate(Player, Combat.ability_slot.Primary, 400.0, SelfOnlyTargets, CooldownTracker, Titan, Specter, Sage, DamagePipeline, HealthManager, StatusManager, KnockbackApplicator, ProjectileSimulator, AreaEffectZone)
        HPAfterAllyHeal := HealthManager.GetCurrentHP(Player)

        Sage.ResolveHealingOrbTarget(Player, false, Player, DamagePipeline, HealthManager)
        HPAfterEnemyDamage := HealthManager.GetCurrentHP(Player)

        var AllyHealWorked : logic = false
        if (HPAfterAllyHeal > HPBeforeAllyHeal):
            set AllyHealWorked = true

        var EnemyDamageWorked : logic = false
        if (HPAfterEnemyDamage < HPAfterAllyHeal):
            set EnemyDamageWorked = true
        if (AllyOrbActivated = true and AllyHealWorked = true and EnemyDamageWorked = true):
            Print("S6_HEALING_ORB_PASS")
        else:
            Print("S6_HEALING_ORB_FAIL")

        StatusManager.ApplyInvisibility(Player, 3.0, Player)
        StatusManager.ApplySlowFromSourceKey(Player, 2.0, 0.4, 2)
        StatusManager.ApplyStunFromSourceKey(Player, 2.0, 2)
        StatusManager.ApplyDeathMarkFromSourceKey(Player, 3.0, 0.2, 2)
        PurifyActivated := AbilitySystem.TryActivate(Player, Combat.ability_slot.Secondary, 500.0, SelfOnlyTargets, CooldownTracker, Titan, Specter, Sage, DamagePipeline, HealthManager, StatusManager, KnockbackApplicator, ProjectileSimulator, AreaEffectZone)

        var PurifyClearedSlow : logic = false
        PurifySlowMagnitude := StatusManager.GetSlowMagnitude(Player)
        if (PurifySlowMagnitude <= 0.0):
            set PurifyClearedSlow = true

        var PurifyClearedStun : logic = true
        PurifyStunned := StatusManager.IsStunned(Player)
        if (PurifyStunned = true):
            set PurifyClearedStun = false

        var PurifyClearedMark : logic = true
        PurifyMarked := StatusManager.IsMarked(Player)
        if (PurifyMarked = true):
            set PurifyClearedMark = false

        var PurifyKeptInvisibility : logic = false
        PurifyInvisible := StatusManager.IsInvisible(Player)
        if (PurifyInvisible = true):
            set PurifyKeptInvisibility = true

        if (PurifyActivated = true and PurifyClearedSlow = true and PurifyClearedStun = true and PurifyClearedMark = true and PurifyKeptInvisibility = true):
            Print("S6_PURIFY_PASS")
        else:
            Print("S6_PURIFY_FAIL")

        DamagePipeline.ProcessDamage(Player, Player, 10.0, Combat.damage_type.Physical, HealthManager)
        HPBeforeSanctuary := HealthManager.GetCurrentHP(Player)
        SanctuaryActivated := AbilitySystem.TryActivate(Player, Combat.ability_slot.Ultimate, 600.0, SelfOnlyTargets, CooldownTracker, Titan, Specter, Sage, DamagePipeline, HealthManager, StatusManager, KnockbackApplicator, ProjectileSimulator, AreaEffectZone)
        SpawnedProjectileId := ProjectileSimulator.SpawnProjectile(20.0, 100.0)

        AreaEffectZone.Tick(0.2, SelfOnlyTargets, HealthManager, ProjectileSimulator)
        ProjectileSimulator.Tick(0.2)
        HPAfterSanctuaryTick := HealthManager.GetCurrentHP(Player)
        var ProjectileBlocked : logic = false
        ProjectileBlockedValue := ProjectileSimulator.IsProjectileBlocked(SpawnedProjectileId)
        if (ProjectileBlockedValue = true):
            set ProjectileBlocked = true

        var SanctuaryActive : logic = false
        SanctuaryActiveValue := AreaEffectZone.IsSanctuaryActive()
        if (SanctuaryActiveValue = true):
            set SanctuaryActive = true

        var SanctuaryBlocking : logic = false
        SanctuaryBlockingValue := AreaEffectZone.IsBlockingProjectiles()
        if (SanctuaryBlockingValue = true):
            set SanctuaryBlocking = true

        AreaEffectZone.Tick(6.0, SelfOnlyTargets, HealthManager, ProjectileSimulator)
        var SanctuaryExpired : logic = false
        var SanctuaryActiveAfterDuration : logic = false
        SanctuaryActiveAfterValue := AreaEffectZone.IsSanctuaryActive()
        if (SanctuaryActiveAfterValue = true):
            set SanctuaryActiveAfterDuration = true

        if (SanctuaryActiveAfterDuration = false):
            set SanctuaryExpired = true

        var SanctuaryHealed : logic = false
        if (HPAfterSanctuaryTick > HPBeforeSanctuary):
            set SanctuaryHealed = true
        if (SanctuaryActivated = true and SanctuaryActive = true and SanctuaryBlocking = true and ProjectileBlocked = true and SanctuaryHealed = true and SanctuaryExpired = true):
            Print("S6_SANCTUARY_PASS")
        else:
            Print("S6_SANCTUARY_FAIL")

        var HasHealingOrb : logic = false
        HasHealingOrbValue := Sage.HasSageEvent("HealingOrbAllyHeal")
        if (HasHealingOrbValue = true):
            set HasHealingOrb = true

        var HasPurify : logic = false
        HasPurifyValue := Sage.HasSageEvent("Purify")
        if (HasPurifyValue = true):
            set HasPurify = true

        var HasSanctuary : logic = false
        HasSanctuaryValue := Sage.HasSageEvent("Sanctuary")
        if (HasSanctuaryValue = true):
            set HasSanctuary = true
        if (HasHealingOrb = true and HasPurify = true and HasSanctuary = true):
            Print("S6_SAGE_KIT_PASS")
        else:
            Print("S6_SAGE_KIT_FAIL")

        Print("S6_SMOKE_END")
