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
        DamagePipeline : Combat.damage_pipeline,
        HealthManager : Combat.health_manager,
        StatusManager : Combat.status_effect_manager,
        KnockbackApplicator : Combat.knockback_applicator
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

