using { /Verse.org/Simulation }

hero_specter<public> := class:
    var TeleportStrikeCooldownSeconds : float = 9.0
    var SmokeInvisibilityCooldownSeconds : float = 14.0
    var DeathMarkCooldownSeconds : float = 45.0
    var TeleportStrikeBaseDamage : float = 55.0
    var SmokeInvisibilityDurationSeconds : float = 3.5
    var DeathMarkDurationSeconds : float = 6.0
    var DeathMarkAmplify : float = 0.25

    var SpecterEventLog : []string = array{}

    TryExecuteAbility<public>(
        Caster : agent,
        Slot : Combat.ability_slot,
        PotentialTargets : []agent,
        DamagePipeline : Combat.damage_pipeline,
        HealthManager : Combat.health_manager,
        StatusManager : Combat.status_effect_manager
    ) : Combat.ability_execution_result =
        if ((Slot = Combat.ability_slot.Primary)):
            ExecuteTeleportStrike(Caster, PotentialTargets, DamagePipeline, HealthManager, StatusManager)
            return Combat.ability_execution_result{Succeeded := true, CooldownSeconds := TeleportStrikeCooldownSeconds, CooldownStartDelaySeconds := 0.0, AbilityLabel := "Teleport Strike"}

        if ((Slot = Combat.ability_slot.Secondary)):
            ExecuteSmokeInvisibility(Caster, StatusManager)
            return Combat.ability_execution_result{Succeeded := true, CooldownSeconds := SmokeInvisibilityCooldownSeconds, CooldownStartDelaySeconds := 0.0, AbilityLabel := "Smoke Invisibility"}

        ExecuteDeathMark(Caster, PotentialTargets, StatusManager)
        return Combat.ability_execution_result{Succeeded := true, CooldownSeconds := DeathMarkCooldownSeconds, CooldownStartDelaySeconds := 0.0, AbilityLabel := "Death Mark"}

    ExecuteTeleportStrike<public>(
        Caster : agent,
        PotentialTargets : []agent,
        DamagePipeline : Combat.damage_pipeline,
        HealthManager : Combat.health_manager,
        StatusManager : Combat.status_effect_manager
    ) : void =
        Target := SelectPrimaryTarget(Caster, PotentialTargets)
        Damage := GetMarkedStrikeDamage(Target, StatusManager)
        DamagePipeline.ProcessDamage(Caster, Target, Damage, Combat.damage_type.Ability, HealthManager)
        set SpecterEventLog += array{"TeleportStrike"}

    ExecuteSmokeInvisibility<public>(Caster : agent, StatusManager : Combat.status_effect_manager) : void =
        StatusManager.ApplyInvisibility(Caster, SmokeInvisibilityDurationSeconds, Caster)
        set SpecterEventLog += array{"SmokeInvisibility"}

    ExecuteDeathMark<public>(Caster : agent, PotentialTargets : []agent, StatusManager : Combat.status_effect_manager) : void =
        for (Target : PotentialTargets):
            if ((Target <> Caster)):
                StatusManager.ApplyDeathMark(Target, DeathMarkDurationSeconds, DeathMarkAmplify, Caster)

        MarkedTargetPresent := HasMarkedTarget(Caster, PotentialTargets)
        if (MarkedTargetPresent = false):
            StatusManager.ApplyDeathMark(Caster, DeathMarkDurationSeconds, DeathMarkAmplify, Caster)

        set SpecterEventLog += array{"DeathMark"}

    GetTeleportStrikeDamage<public>() : float =
        return TeleportStrikeBaseDamage

    GetMarkedStrikeDamage<public>(Target : agent, StatusManager : Combat.status_effect_manager) : float =
        return TeleportStrikeBaseDamage * StatusManager.GetDamageAmplifierFromMark(Target)

    HasSpecterEvent<public>(EventName : string) : logic =
        for (Logged : SpecterEventLog):
            if ((Logged = EventName)):
                return true
        return false

    SelectPrimaryTarget(Caster : agent, PotentialTargets : []agent) : agent =
        for (Target : PotentialTargets):
            if ((Target <> Caster)):
                return Target
        return Caster

    HasMarkedTarget(Caster : agent, PotentialTargets : []agent) : logic =
        for (Target : PotentialTargets):
            if ((Target <> Caster)):
                return true
        return false
