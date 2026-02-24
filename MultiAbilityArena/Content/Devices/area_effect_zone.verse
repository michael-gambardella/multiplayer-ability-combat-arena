using { /Verse.org/Simulation }

area_effect_zone<public> := class:
    var SanctuaryActive : logic = false
    var SanctuaryRemainingSeconds : float = 0.0
    var SanctuaryHealPerTick : float = 0.0
    var SanctuaryBlocksProjectiles : logic = false
    var SanctuaryTickIntervalSeconds : float = 0.2
    var SanctuaryTickAccumulatorSeconds : float = 0.0

    var GravitySnareActive : logic = false
    var GravitySnareRemainingSeconds : float = 0.0
    var GravitySnarePullForce : float = 0.0
    var GravitySnareTickIntervalSeconds : float = 0.4
    var GravitySnareTickAccumulatorSeconds : float = 0.0

    var OrbitalBarrageActive : logic = false
    var OrbitalBarrageRemainingBursts : int = 0
    var OrbitalBarrageIntervalSeconds : float = 0.7
    var OrbitalBarrageTickAccumulatorSeconds : float = 0.0
    var OrbitalBarrageDamagePerBurst : float = 0.0
    var OrbitalBarrageRadiusMeters : float = 0.0

    var ZoneEventLog : []string = array{}

    ActivateSanctuary<public>(DurationSeconds : float, HealPerTick : float, BlocksProjectiles : logic) : void =
        SafeDuration := MaxFloat(DurationSeconds, 0.0)
        SafeHeal := MaxFloat(HealPerTick, 0.0)
        set SanctuaryActive = true
        set SanctuaryRemainingSeconds = SafeDuration
        set SanctuaryHealPerTick = SafeHeal
        set SanctuaryBlocksProjectiles = BlocksProjectiles
        set SanctuaryTickAccumulatorSeconds = 0.0
        set ZoneEventLog += array{"ActivateSanctuary"}

    ActivateGravitySnare<public>(DurationSeconds : float, PullForce : float, TickIntervalSeconds : float) : void =
        SafeDuration := MaxFloat(DurationSeconds, 0.0)
        SafePull := MaxFloat(PullForce, 0.0)
        SafeInterval := MaxFloat(TickIntervalSeconds, 0.05)
        set GravitySnareActive = true
        set GravitySnareRemainingSeconds = SafeDuration
        set GravitySnarePullForce = SafePull
        set GravitySnareTickIntervalSeconds = SafeInterval
        set GravitySnareTickAccumulatorSeconds = 0.0
        set ZoneEventLog += array{"ActivateGravitySnare"}

    ActivateOrbitalBarrage<public>(BurstCount : int, IntervalSeconds : float, DamagePerBurst : float, RadiusMeters : float) : void =
        SafeBursts := MaxInt(BurstCount, 0)
        SafeInterval := MaxFloat(IntervalSeconds, 0.05)
        SafeDamage := MaxFloat(DamagePerBurst, 0.0)
        SafeRadius := MaxFloat(RadiusMeters, 0.0)
        set OrbitalBarrageActive = true
        set OrbitalBarrageRemainingBursts = SafeBursts
        set OrbitalBarrageIntervalSeconds = SafeInterval
        set OrbitalBarrageTickAccumulatorSeconds = 0.0
        set OrbitalBarrageDamagePerBurst = SafeDamage
        set OrbitalBarrageRadiusMeters = SafeRadius
        set ZoneEventLog += array{"ActivateOrbitalBarrage"}

    Tick<public>(
        DeltaTime : float,
        AllyTargets : []agent,
        HealthManager : Combat.health_manager,
        ProjectileSimulator : Devices.projectile_simulator,
        KnockbackApplicator : Combat.knockback_applicator
    ) : void =
        Delta := MaxFloat(DeltaTime, 0.0)

        if (SanctuaryActive = true):
            ProjectileSimulator.SetGlobalProjectileBlock(SanctuaryBlocksProjectiles)
            NewRemaining := SanctuaryRemainingSeconds - Delta
            set SanctuaryRemainingSeconds = NewRemaining
            set SanctuaryTickAccumulatorSeconds = SanctuaryTickAccumulatorSeconds + Delta

            if (SanctuaryTickAccumulatorSeconds >= SanctuaryTickIntervalSeconds):
                set SanctuaryTickAccumulatorSeconds = 0.0
                for (Target : AllyTargets):
                    HealthManager.ApplyHealing(Target, SanctuaryHealPerTick)
                set ZoneEventLog += array{"SanctuaryHealTick"}

            if (SanctuaryRemainingSeconds <= 0.0):
                set SanctuaryActive = false
                set SanctuaryRemainingSeconds = 0.0
                set SanctuaryBlocksProjectiles = false
                ProjectileSimulator.SetGlobalProjectileBlock(false)
                set ZoneEventLog += array{"SanctuaryExpired"}
        else:
            ProjectileSimulator.SetGlobalProjectileBlock(false)

        if (GravitySnareActive = true):
            NewRemaining := GravitySnareRemainingSeconds - Delta
            set GravitySnareRemainingSeconds = NewRemaining
            set GravitySnareTickAccumulatorSeconds = GravitySnareTickAccumulatorSeconds + Delta

            if (GravitySnareTickAccumulatorSeconds >= GravitySnareTickIntervalSeconds):
                set GravitySnareTickAccumulatorSeconds = 0.0
                for (Target : AllyTargets):
                    KnockbackApplicator.ApplyKnockback(Target, Target, GravitySnarePullForce)
                set ZoneEventLog += array{"GravitySnareTick"}

            if (GravitySnareRemainingSeconds <= 0.0):
                set GravitySnareActive = false
                set GravitySnareRemainingSeconds = 0.0
                set ZoneEventLog += array{"GravitySnareExpired"}

        if (OrbitalBarrageActive = true):
            set OrbitalBarrageTickAccumulatorSeconds = OrbitalBarrageTickAccumulatorSeconds + Delta
            if (OrbitalBarrageTickAccumulatorSeconds >= OrbitalBarrageIntervalSeconds):
                set OrbitalBarrageTickAccumulatorSeconds = 0.0
                if (OrbitalBarrageRemainingBursts > 0):
                    for (Target : AllyTargets):
                        HealthManager.ApplyDamage(Target, OrbitalBarrageDamagePerBurst, Combat.damage_type.Ultimate)
                    set OrbitalBarrageRemainingBursts = OrbitalBarrageRemainingBursts - 1
                    set ZoneEventLog += array{"OrbitalBarrageBurst"}

                if (OrbitalBarrageRemainingBursts <= 0):
                    set OrbitalBarrageActive = false
                    set ZoneEventLog += array{"OrbitalBarrageComplete"}

    IsSanctuaryActive<public>() : logic =
        return SanctuaryActive

    IsBlockingProjectiles<public>() : logic =
        return SanctuaryBlocksProjectiles

    IsGravitySnareActive<public>() : logic =
        return GravitySnareActive

    IsOrbitalBarrageActive<public>() : logic =
        return OrbitalBarrageActive

    HasZoneEvent<public>(EventName : string) : logic =
        for (Logged : ZoneEventLog):
            if ((Logged = EventName)):
                return true
        return false

    MaxFloat(A : float, B : float) : float =
        if ((A > B)):
            return A
        return B

    MaxInt(A : int, B : int) : int =
        if ((A > B)):
            return A
        return B
