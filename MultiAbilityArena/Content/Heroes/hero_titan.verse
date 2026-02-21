using { /Verse.org/Simulation }
# Sprint 4 hero implementation: Titan ability kit + Fortified passive.

hero_titan := class:
    var SeismicSlamCooldownSeconds : float = 8.0
    var BarrierChargeCooldownSeconds : float = 12.0
    var EarthshatterCooldownSeconds : float = 60.0
    var FortifiedDamageMultiplier : float = 0.85
    var FortifiedStationaryThresholdSeconds : float = 1.0

    var SeismicSlamDamage : float = 45.0
    var BarrierChargeDamage : float = 35.0
    var EarthshatterDamage : float = 90.0
    var BarrierChargeKnockbackForce : float = 1200.0

    var TitanEventLog : []string = array{}

    TryExecuteAbility(
        Caster : agent,
        Slot : Combat.ability_slot,
        PotentialTargets : []agent,
        DamagePipeline : Combat.damage_pipeline,
        HealthManager : Combat.health_manager,
        StatusManager : Combat.status_effect_manager,
        KnockbackApplicator : Combat.knockback_applicator
    ) : Combat.ability_execution_result =
        if (Slot = Combat.ability_slot.Primary):
            ExecuteSeismicSlam(Caster, PotentialTargets, DamagePipeline, HealthManager, StatusManager)
            return Combat.ability_execution_result{Succeeded := true, CooldownSeconds := SeismicSlamCooldownSeconds, CooldownStartDelaySeconds := 0.0, AbilityLabel := "Seismic Slam"}

        if (Slot = Combat.ability_slot.Secondary):
            ExecuteBarrierCharge(Caster, PotentialTargets, DamagePipeline, HealthManager, KnockbackApplicator)
            return Combat.ability_execution_result{Succeeded := true, CooldownSeconds := BarrierChargeCooldownSeconds, CooldownStartDelaySeconds := 0.0, AbilityLabel := "Barrier Charge"}

        ExecuteEarthshatter(Caster, PotentialTargets, DamagePipeline, HealthManager, StatusManager)
        # Earthshatter cooldown begins after 1s wind-up/effect lead time.
        return Combat.ability_execution_result{Succeeded := true, CooldownSeconds := EarthshatterCooldownSeconds, CooldownStartDelaySeconds := 1.0, AbilityLabel := "Earthshatter"}

    EvaluateFortifiedPassive(Player : agent, StationarySeconds : float, DamagePipeline : Combat.damage_pipeline) : void =
        if (StationarySeconds >= FortifiedStationaryThresholdSeconds):
            DamagePipeline.SetDamageModifier(Player, FortifiedDamageMultiplier)
            set TitanEventLog += array{"FortifiedActive: {Player} Mult={FortifiedDamageMultiplier}"}
            return

        DamagePipeline.SetDamageModifier(Player, 1.0)
        set TitanEventLog += array{"FortifiedInactive: {Player}"}

    ExecuteSeismicSlam(
        Caster : agent,
        PotentialTargets : []agent,
        DamagePipeline : Combat.damage_pipeline,
        HealthManager : Combat.health_manager,
        StatusManager : Combat.status_effect_manager
    ) : void =
        HitCount := 0
        for (Target : PotentialTargets):
            if (Target <> Caster):
                DamagePipeline.ProcessDamage(Caster, Target, SeismicSlamDamage, Combat.damage_type.Ability, HealthManager)
                StatusManager.ApplySlow(Target, 1.5, 0.35, Caster)
                set HitCount = HitCount + 1

        set TitanEventLog += array{"SeismicSlam: {Caster} Hits={HitCount}"}

    ExecuteBarrierCharge(
        Caster : agent,
        PotentialTargets : []agent,
        DamagePipeline : Combat.damage_pipeline,
        HealthManager : Combat.health_manager,
        KnockbackApplicator : Combat.knockback_applicator
    ) : void =
        HitCount := 0
        for (Target : PotentialTargets):
            if (Target <> Caster):
                DamagePipeline.ProcessDamage(Caster, Target, BarrierChargeDamage, Combat.damage_type.Ability, HealthManager)
                KnockbackApplicator.ApplyKnockback(Caster, Target, BarrierChargeKnockbackForce)
                set HitCount = HitCount + 1

        set TitanEventLog += array{"BarrierCharge: {Caster} Hits={HitCount}"}

    ExecuteEarthshatter(
        Caster : agent,
        PotentialTargets : []agent,
        DamagePipeline : Combat.damage_pipeline,
        HealthManager : Combat.health_manager,
        StatusManager : Combat.status_effect_manager
    ) : void =
        HitCount := 0
        for (Target : PotentialTargets):
            if (Target <> Caster):
                DamagePipeline.ProcessDamage(Caster, Target, EarthshatterDamage, Combat.damage_type.Ultimate, HealthManager)
                StatusManager.ApplyStun(Target, 2.0, Caster)
                set HitCount = HitCount + 1

        set TitanEventLog += array{"Earthshatter: {Caster} Hits={HitCount}"}

