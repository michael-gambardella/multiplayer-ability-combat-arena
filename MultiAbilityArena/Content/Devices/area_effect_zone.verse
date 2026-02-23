using { /Verse.org/Simulation }

area_effect_zone<public> := class:
    var SanctuaryActive : logic = false
    var SanctuaryRemainingSeconds : float = 0.0
    var SanctuaryHealPerTick : float = 0.0
    var SanctuaryBlocksProjectiles : logic = false
    var TickIntervalSeconds : float = 0.2
    var TickAccumulatorSeconds : float = 0.0
    var ZoneEventLog : []string = array{}

    ActivateSanctuary<public>(DurationSeconds : float, HealPerTick : float, BlocksProjectiles : logic) : void =
        SafeDuration := MaxFloat(DurationSeconds, 0.0)
        SafeHeal := MaxFloat(HealPerTick, 0.0)
        set SanctuaryActive = true
        set SanctuaryRemainingSeconds = SafeDuration
        set SanctuaryHealPerTick = SafeHeal
        set SanctuaryBlocksProjectiles = BlocksProjectiles
        set TickAccumulatorSeconds = 0.0
        set ZoneEventLog += array{"ActivateSanctuary"}

    Tick<public>(
        DeltaTime : float,
        AllyTargets : []agent,
        HealthManager : Combat.health_manager,
        ProjectileSimulator : Devices.projectile_simulator
    ) : void =
        if (SanctuaryActive = false):
            ProjectileSimulator.SetGlobalProjectileBlock(false)
            return

        ProjectileSimulator.SetGlobalProjectileBlock(SanctuaryBlocksProjectiles)

        Delta := MaxFloat(DeltaTime, 0.0)
        NewRemaining := SanctuaryRemainingSeconds - Delta
        set SanctuaryRemainingSeconds = NewRemaining
        set TickAccumulatorSeconds = TickAccumulatorSeconds + Delta

        if (TickAccumulatorSeconds >= TickIntervalSeconds):
            set TickAccumulatorSeconds = 0.0
            for (Target : AllyTargets):
                HealthManager.ApplyHealing(Target, SanctuaryHealPerTick)
            set ZoneEventLog += array{"SanctuaryHealTick"}

        if (SanctuaryRemainingSeconds <= 0.0):
            set SanctuaryActive = false
            set SanctuaryRemainingSeconds = 0.0
            set SanctuaryBlocksProjectiles = false
            ProjectileSimulator.SetGlobalProjectileBlock(false)
            set ZoneEventLog += array{"SanctuaryExpired"}

    IsSanctuaryActive<public>() : logic =
        return SanctuaryActive

    IsBlockingProjectiles<public>() : logic =
        return SanctuaryBlocksProjectiles

    MaxFloat(A : float, B : float) : float =
        if ((A > B)):
            return A
        return B
