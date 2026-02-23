using { /Verse.org/Simulation }

titan_target_sample<public> := struct:
    Target<public> : agent
    DistanceMeters<public> : float
    AngleDegrees<public> : float
    OnChargePath<public> : logic
    ChargeImpactDistanceMeters<public> : float

hero_titan<public> := class:
    var SeismicSlamCooldownSeconds : float = 8.0
    var BarrierChargeCooldownSeconds : float = 12.0
    var EarthshatterCooldownSeconds : float = 60.0
    var FortifiedDamageMultiplier : float = 0.85
    var FortifiedStationaryThresholdSeconds : float = 1.0
    var SeismicSlamRadiusMeters : float = 6.0
    var EarthshatterRangeMeters : float = 12.0
    var EarthshatterConeHalfAngleDegrees : float = 35.0
    var BarrierChargeMaxDistanceMeters : float = 10.0

    var SeismicSlamDamage : float = 45.0
    var BarrierChargeDamage : float = 35.0
    var EarthshatterDamage : float = 90.0
    var BarrierChargeKnockbackForce : float = 1200.0

    var TitanEventLog : []string = array{}

    TryExecuteAbility<public>(
        Caster : agent,
        Slot : Combat.ability_slot,
        PotentialTargets : []agent,
        DamagePipeline : Combat.damage_pipeline,
        HealthManager : Combat.health_manager,
        StatusManager : Combat.status_effect_manager,
        KnockbackApplicator : Combat.knockback_applicator
    ) : Combat.ability_execution_result =
        Samples := BuildDefaultTargetSamples(PotentialTargets)

        if ((Slot = Combat.ability_slot.Primary)):
            SlamTargets := SelectSeismicSlamTargets(Caster, Samples)
            ExecuteSeismicSlam(Caster, SlamTargets, DamagePipeline, HealthManager, StatusManager)
            return Combat.ability_execution_result{Succeeded := true, CooldownSeconds := SeismicSlamCooldownSeconds, CooldownStartDelaySeconds := 0.0, AbilityLabel := "Seismic Slam"}

        if ((Slot = Combat.ability_slot.Secondary)):
            ChargeTargets := SelectBarrierChargeTargets(Caster, Samples)
            ChargeTravelDistance := ComputeBarrierChargeTravelDistance(Samples)
            ExecuteBarrierCharge(Caster, ChargeTargets, DamagePipeline, HealthManager, KnockbackApplicator, ChargeTravelDistance)
            return Combat.ability_execution_result{Succeeded := true, CooldownSeconds := BarrierChargeCooldownSeconds, CooldownStartDelaySeconds := 0.0, AbilityLabel := "Barrier Charge"}

        EarthshatterTargets := SelectEarthshatterTargets(Caster, Samples)
        ExecuteEarthshatter(Caster, EarthshatterTargets, DamagePipeline, HealthManager, StatusManager)
        return Combat.ability_execution_result{Succeeded := true, CooldownSeconds := EarthshatterCooldownSeconds, CooldownStartDelaySeconds := 1.0, AbilityLabel := "Earthshatter"}

    EvaluateFortifiedPassive<public>(Player : agent, StationarySeconds : float, DamagePipeline : Combat.damage_pipeline) : void =
        if ((StationarySeconds >= FortifiedStationaryThresholdSeconds)):
            DamagePipeline.SetDamageModifier(Player, FortifiedDamageMultiplier)
            set TitanEventLog += array{"FortifiedActive"}
            return

        DamagePipeline.SetDamageModifier(Player, 1.0)
        set TitanEventLog += array{"FortifiedInactive"}

    ExecuteSeismicSlam<public>(
        Caster : agent,
        PotentialTargets : []agent,
        DamagePipeline : Combat.damage_pipeline,
        HealthManager : Combat.health_manager,
        StatusManager : Combat.status_effect_manager
    ) : void =
        var HitCount : int = 0
        for (Target : PotentialTargets):
            if ((Target <> Caster)):
                DamagePipeline.ProcessDamage(Caster, Target, SeismicSlamDamage, Combat.damage_type.Ability, HealthManager)
                StatusManager.ApplySlow(Target, 1.5, 0.35, Caster)
                set HitCount = HitCount + 1

        set TitanEventLog += array{"SeismicSlam"}

    ExecuteBarrierCharge<public>(
        Caster : agent,
        PotentialTargets : []agent,
        DamagePipeline : Combat.damage_pipeline,
        HealthManager : Combat.health_manager,
        KnockbackApplicator : Combat.knockback_applicator,
        ChargeTravelDistanceMeters : float
    ) : void =
        var HitCount : int = 0
        for (Target : PotentialTargets):
            if ((Target <> Caster)):
                DamagePipeline.ProcessDamage(Caster, Target, BarrierChargeDamage, Combat.damage_type.Ability, HealthManager)
                KnockbackApplicator.ApplyKnockback(Caster, Target, BarrierChargeKnockbackForce)
                set HitCount = HitCount + 1

        if ((ChargeTravelDistanceMeters < BarrierChargeMaxDistanceMeters)):
            set TitanEventLog += array{"BarrierChargeTravelCollision"}
        else:
            set TitanEventLog += array{"BarrierChargeTravelFull"}
        set TitanEventLog += array{"BarrierCharge"}

    ExecuteEarthshatter<public>(
        Caster : agent,
        PotentialTargets : []agent,
        DamagePipeline : Combat.damage_pipeline,
        HealthManager : Combat.health_manager,
        StatusManager : Combat.status_effect_manager
    ) : void =
        var HitCount : int = 0
        for (Target : PotentialTargets):
            if ((Target <> Caster)):
                DamagePipeline.ProcessDamage(Caster, Target, EarthshatterDamage, Combat.damage_type.Ultimate, HealthManager)
                StatusManager.ApplyStun(Target, 2.0, Caster)
                set HitCount = HitCount + 1

        set TitanEventLog += array{"Earthshatter"}

    BuildDefaultTargetSamples(PotentialTargets : []agent) : []Heroes.titan_target_sample =
        var Samples : []Heroes.titan_target_sample = array{}
        for (Target : PotentialTargets):
            set Samples += array{
                Heroes.titan_target_sample{
                    Target := Target,
                    DistanceMeters := 0.0,
                    AngleDegrees := 0.0,
                    OnChargePath := true,
                    ChargeImpactDistanceMeters := BarrierChargeMaxDistanceMeters
                }
            }
        return Samples

    SelectSeismicSlamTargets<public>(Caster : agent, Samples : []Heroes.titan_target_sample) : []agent =
        var Selected : []agent = array{}
        for (Sample : Samples):
            InRange := IsWithinRange(Sample.DistanceMeters, SeismicSlamRadiusMeters)
            if (InRange = true and Sample.Target <> Caster):
                set Selected += array{Sample.Target}
        return Selected

    SelectEarthshatterTargets<public>(Caster : agent, Samples : []Heroes.titan_target_sample) : []agent =
        var Selected : []agent = array{}
        for (Sample : Samples):
            InRange := IsWithinRange(Sample.DistanceMeters, EarthshatterRangeMeters)
            InCone := IsWithinHalfAngle(Sample.AngleDegrees, EarthshatterConeHalfAngleDegrees)
            if (InRange = true and InCone = true and Sample.Target <> Caster):
                set Selected += array{Sample.Target}
        return Selected

    SelectBarrierChargeTargets<public>(Caster : agent, Samples : []Heroes.titan_target_sample) : []agent =
        var Selected : []agent = array{}
        for (Sample : Samples):
            if (Sample.OnChargePath = true and Sample.Target <> Caster):
                set Selected += array{Sample.Target}
        return Selected

    ComputeBarrierChargeTravelDistance<public>(Samples : []Heroes.titan_target_sample) : float =
        return FindClosestImpactDistance(Samples, BarrierChargeMaxDistanceMeters)

    SimulateBarrierChargePath<public>(RequestedDistanceMeters : float, CollisionDistanceMeters : float, HasCollision : logic) : float =
        SafeRequested := ClampFloat(RequestedDistanceMeters, 0.0, BarrierChargeMaxDistanceMeters)
        if (HasCollision = false):
            return SafeRequested
        SafeCollision := ClampFloat(CollisionDistanceMeters, 0.0, SafeRequested)
        return SafeCollision

    HasTitanEvent<public>(EventName : string) : logic =
        for (Logged : TitanEventLog):
            if ((Logged = EventName)):
                return true
        return false

    FindClosestImpactDistance(Samples : []Heroes.titan_target_sample, DefaultDistance : float) : float =
        var Best : float = DefaultDistance
        for (Sample : Samples):
            if (Sample.OnChargePath = true):
                Candidate := ClampFloat(Sample.ChargeImpactDistanceMeters, 0.0, DefaultDistance)
                if ((Candidate < Best)):
                    set Best = Candidate
        return Best

    IsWithinRange(Value : float, MaxRange : float) : logic =
        if ((Value <= MaxRange)):
            return true
        return false

    IsWithinHalfAngle(Value : float, HalfAngle : float) : logic =
        AbsoluteAngle := AbsFloat(Value)
        if ((AbsoluteAngle <= HalfAngle)):
            return true
        return false

    AbsFloat(Value : float) : float =
        if ((Value < 0.0)):
            return 0.0 - Value
        return Value

    ClampFloat(Value : float, MinValue : float, MaxValue : float) : float =
        if ((Value < MinValue)):
            return MinValue
        if ((Value > MaxValue)):
            return MaxValue
        return Value

