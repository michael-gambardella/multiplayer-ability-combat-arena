using { /Verse.org/Simulation }

ability_system<public> := class:
    var HeroByPlayer : [agent]string = map{}
    var AbilitiesEnabled : logic = true
    var AbilityEventLog : []string = array{}

    RegisterHero<public>(Player : agent, HeroId : string) : void =
        if (set HeroByPlayer[Player] = HeroId) {}
        set AbilityEventLog += array{"RegisterHero"}

    SetAbilitiesEnabled<public>(Enabled : logic) : void =
        set AbilitiesEnabled = Enabled
        set AbilityEventLog += array{"SetAbilitiesEnabled"}

    TryActivate<public>(
        Player : agent,
        Slot : Combat.ability_slot,
        CurrentTimeSeconds : float,
        PotentialTargets : []agent,
        CooldownTracker : Combat.cooldown_tracker,
        Titan : Heroes.hero_titan,
        Specter : Heroes.hero_specter,
        Sage : Heroes.hero_sage,
        DamagePipeline : Combat.damage_pipeline,
        HealthManager : Combat.health_manager,
        StatusManager : Combat.status_effect_manager,
        KnockbackApplicator : Combat.knockback_applicator,
        ProjectileSimulator : Devices.projectile_simulator,
        AreaEffectZone : Devices.area_effect_zone
    ) : logic =
        if (AbilitiesEnabled = false):
            set AbilityEventLog += array{"BlockedDisabled"}
            return false

        IsOnCooldown := CooldownTracker.IsOnCooldown(Player, Slot, CurrentTimeSeconds)
        if (IsOnCooldown = true):
            set AbilityEventLog += array{"BlockedCooldown"}
            return false

        HeroId := GetHeroId(Player)
        if ((HeroId = "Titan")):
            Result := Titan.TryExecuteAbility(Player, Slot, PotentialTargets, DamagePipeline, HealthManager, StatusManager, KnockbackApplicator)
            if (Result.Succeeded = true):
                CooldownTracker.StartCooldown(Player, Slot, CurrentTimeSeconds, Result.CooldownSeconds, Result.CooldownStartDelaySeconds)
                set AbilityEventLog += array{"Activated"}
                return true

            set AbilityEventLog += array{"ActivationFailed"}
            return false

        if ((HeroId = "Specter")):
            Result := Specter.TryExecuteAbility(Player, Slot, PotentialTargets, DamagePipeline, HealthManager, StatusManager)
            if (Result.Succeeded = true):
                CooldownTracker.StartCooldown(Player, Slot, CurrentTimeSeconds, Result.CooldownSeconds, Result.CooldownStartDelaySeconds)
                set AbilityEventLog += array{"Activated"}
                return true

            set AbilityEventLog += array{"ActivationFailed"}
            return false

        if ((HeroId = "Sage")):
            Result := Sage.TryExecuteAbility(Player, Slot, PotentialTargets, DamagePipeline, HealthManager, StatusManager, ProjectileSimulator, AreaEffectZone)
            if (Result.Succeeded = true):
                CooldownTracker.StartCooldown(Player, Slot, CurrentTimeSeconds, Result.CooldownSeconds, Result.CooldownStartDelaySeconds)
                set AbilityEventLog += array{"Activated"}
                return true

            set AbilityEventLog += array{"ActivationFailed"}
            return false

        set AbilityEventLog += array{"BlockedUnknownHero"}
        return false

    GetRemainingCooldown<public>(
        Player : agent,
        Slot : Combat.ability_slot,
        CurrentTimeSeconds : float,
        CooldownTracker : Combat.cooldown_tracker
    ) : float =
        return CooldownTracker.GetRemainingCooldown(Player, Slot, CurrentTimeSeconds)

    GetHeroId<public>(Player : agent) : string =
        if (Value := HeroByPlayer[Player]):
            return Value
        return "Titan"

