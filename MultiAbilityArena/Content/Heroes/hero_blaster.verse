using { /Verse.org/Simulation }

hero_blaster<public> := class:
    var ConcussionRocketCooldownSeconds : float = 9.0
    var GravitySnareCooldownSeconds : float = 14.0
    var OrbitalBarrageCooldownSeconds : float = 55.0

    var ConcussionRocketDamage : float = 50.0
    var ConcussionRocketKnockbackForce : float = 950.0
    var ConcussionRocketEasingSeconds : float = 0.25
    var ConcussionRocketMaxForce : float = 1200.0

    var GravitySnareDurationSeconds : float = 4.0
    var GravitySnarePullForce : float = 240.0
    var GravitySnareTickIntervalSeconds : float = 0.4

    var OrbitalBarrageBurstCount : int = 3
    var OrbitalBarrageIntervalSeconds : float = 0.7
    var OrbitalBarrageDamagePerBurst : float = 35.0
    var OrbitalBarrageRadiusMeters : float = 6.0

    var BlasterEventLog : []string = array{}

    TryExecuteAbility<public>(
        Caster : agent,
        Slot : Combat.ability_slot,
        PotentialTargets : []agent,
        DamagePipeline : Combat.damage_pipeline,
        HealthManager : Combat.health_manager,
        KnockbackApplicator : Combat.knockback_applicator,
        AreaEffectZone : Devices.area_effect_zone
    ) : Combat.ability_execution_result =
        if ((Slot = Combat.ability_slot.Primary)):
            ExecuteConcussionRocket(Caster, PotentialTargets, DamagePipeline, HealthManager, KnockbackApplicator)
            return Combat.ability_execution_result{Succeeded := true, CooldownSeconds := ConcussionRocketCooldownSeconds, CooldownStartDelaySeconds := 0.0, AbilityLabel := "Concussion Rocket"}

        if ((Slot = Combat.ability_slot.Secondary)):
            ExecuteGravitySnare(Caster, AreaEffectZone)
            return Combat.ability_execution_result{Succeeded := true, CooldownSeconds := GravitySnareCooldownSeconds, CooldownStartDelaySeconds := 0.0, AbilityLabel := "Gravity Snare"}

        ExecuteOrbitalBarrage(Caster, AreaEffectZone)
        return Combat.ability_execution_result{Succeeded := true, CooldownSeconds := OrbitalBarrageCooldownSeconds, CooldownStartDelaySeconds := 0.5, AbilityLabel := "Orbital Barrage"}

    ExecuteConcussionRocket<public>(
        Caster : agent,
        PotentialTargets : []agent,
        DamagePipeline : Combat.damage_pipeline,
        HealthManager : Combat.health_manager,
        KnockbackApplicator : Combat.knockback_applicator
    ) : void =
        var HitCount : int = 0
        for (Target : PotentialTargets):
            if ((Target <> Caster)):
                DamagePipeline.ProcessDamage(Caster, Target, ConcussionRocketDamage, Combat.damage_type.Ability, HealthManager)
                KnockbackApplicator.ApplyKnockbackEased(Caster, Target, ConcussionRocketKnockbackForce, ConcussionRocketEasingSeconds, ConcussionRocketMaxForce)
                set HitCount = HitCount + 1

        if (HitCount <= 0):
            DamagePipeline.ProcessDamage(Caster, Caster, 0.0, Combat.damage_type.Ability, HealthManager)
            KnockbackApplicator.ApplyKnockbackEased(Caster, Caster, ConcussionRocketKnockbackForce, ConcussionRocketEasingSeconds, ConcussionRocketMaxForce)
        set BlasterEventLog += array{"ConcussionRocket"}

    ExecuteGravitySnare<public>(Caster : agent, AreaEffectZone : Devices.area_effect_zone) : void =
        AreaEffectZone.ActivateGravitySnare(GravitySnareDurationSeconds, GravitySnarePullForce, GravitySnareTickIntervalSeconds)
        set BlasterEventLog += array{"GravitySnare"}

    ExecuteOrbitalBarrage<public>(Caster : agent, AreaEffectZone : Devices.area_effect_zone) : void =
        AreaEffectZone.ActivateOrbitalBarrage(OrbitalBarrageBurstCount, OrbitalBarrageIntervalSeconds, OrbitalBarrageDamagePerBurst, OrbitalBarrageRadiusMeters)
        set BlasterEventLog += array{"OrbitalBarrage"}

    HasBlasterEvent<public>(EventName : string) : logic =
        for (Logged : BlasterEventLog):
            if ((Logged = EventName)):
                return true
        return false
