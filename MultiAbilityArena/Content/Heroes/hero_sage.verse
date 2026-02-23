using { /Verse.org/Simulation }

hero_sage<public> := class:
    var HealingOrbCooldownSeconds : float = 7.0
    var PurifyCooldownSeconds : float = 12.0
    var SanctuaryCooldownSeconds : float = 55.0
    var HealingOrbHealAmount : float = 40.0
    var HealingOrbDamageAmount : float = 35.0
    var SanctuaryDurationSeconds : float = 5.0
    var SanctuaryHealPerTick : float = 6.0
    var SageEventLog : []string = array{}

    TryExecuteAbility<public>(
        Caster : agent,
        Slot : Combat.ability_slot,
        PotentialTargets : []agent,
        DamagePipeline : Combat.damage_pipeline,
        HealthManager : Combat.health_manager,
        StatusManager : Combat.status_effect_manager,
        ProjectileSimulator : Devices.projectile_simulator,
        AreaEffectZone : Devices.area_effect_zone
    ) : Combat.ability_execution_result =
        if ((Slot = Combat.ability_slot.Primary)):
            Target := SelectPrimaryTarget(Caster, PotentialTargets)
            IsAlly := IsAllyTarget(Caster, Target)
            ResolveHealingOrbTarget(Target, IsAlly, Caster, DamagePipeline, HealthManager)
            return Combat.ability_execution_result{Succeeded := true, CooldownSeconds := HealingOrbCooldownSeconds, CooldownStartDelaySeconds := 0.0, AbilityLabel := "Healing Orb"}

        if ((Slot = Combat.ability_slot.Secondary)):
            ExecutePurify(Caster, PotentialTargets, StatusManager)
            return Combat.ability_execution_result{Succeeded := true, CooldownSeconds := PurifyCooldownSeconds, CooldownStartDelaySeconds := 0.0, AbilityLabel := "Purify"}

        ExecuteSanctuary(Caster, AreaEffectZone)
        return Combat.ability_execution_result{Succeeded := true, CooldownSeconds := SanctuaryCooldownSeconds, CooldownStartDelaySeconds := 0.0, AbilityLabel := "Sanctuary"}

    ResolveHealingOrbTarget<public>(
        Target : agent,
        IsAlly : logic,
        Source : agent,
        DamagePipeline : Combat.damage_pipeline,
        HealthManager : Combat.health_manager
    ) : void =
        if (IsAlly = true):
            HealthManager.ApplyHealing(Target, HealingOrbHealAmount)
            set SageEventLog += array{"HealingOrbAllyHeal"}
            return

        DamagePipeline.ProcessDamage(Source, Target, HealingOrbDamageAmount, Combat.damage_type.Ability, HealthManager)
        set SageEventLog += array{"HealingOrbEnemyDamage"}

    ExecutePurify<public>(Caster : agent, PotentialTargets : []agent, StatusManager : Combat.status_effect_manager) : void =
        var AppliedToAny : logic = false
        for (Target : PotentialTargets):
            TargetIsAlly := IsAllyTarget(Caster, Target)
            if (TargetIsAlly = true):
                StatusManager.PurgeNegativeEffects(Target)
                set AppliedToAny = true

        if (AppliedToAny = false):
            StatusManager.PurgeNegativeEffects(Caster)

        set SageEventLog += array{"Purify"}

    ExecuteSanctuary<public>(Caster : agent, AreaEffectZone : Devices.area_effect_zone) : void =
        AreaEffectZone.ActivateSanctuary(SanctuaryDurationSeconds, SanctuaryHealPerTick, true)
        set SageEventLog += array{"Sanctuary"}

    HasSageEvent<public>(EventName : string) : logic =
        for (Logged : SageEventLog):
            if ((Logged = EventName)):
                return true
        return false

    GetHealingOrbHealAmount<public>() : float =
        return HealingOrbHealAmount

    GetHealingOrbDamageAmount<public>() : float =
        return HealingOrbDamageAmount

    SelectPrimaryTarget(Caster : agent, PotentialTargets : []agent) : agent =
        for (Target : PotentialTargets):
            if ((Target <> Caster)):
                return Target
        return Caster

    IsAllyTarget(Caster : agent, Target : agent) : logic =
        if ((Target = Caster)):
            return true
        return false
