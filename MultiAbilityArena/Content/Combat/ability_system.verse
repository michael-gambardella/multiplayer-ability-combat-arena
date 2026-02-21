using { /Verse.org/Simulation }
# Sprint 4 ability framework: activation routing + cooldown gate + Titan integration.

ability_system := class:
    var HeroByPlayer : [agent]string = map{}
    var AbilitiesEnabled : logic = true
    var AbilityEventLog : []string = array{}

    RegisterHero(Player : agent, HeroId : string) : void =
        if (set HeroByPlayer[Player] = HeroId) {}
        set AbilityEventLog += array{"RegisterHero: {Player} Hero={HeroId}"}

    SetAbilitiesEnabled(Enabled : logic) : void =
        set AbilitiesEnabled = Enabled
        set AbilityEventLog += array{"SetAbilitiesEnabled: {Enabled}"}

    TryActivate(
        Player : agent,
        Slot : ability_slot,
        CurrentTimeSeconds : float,
        PotentialTargets : []agent,
        CooldownTracker : cooldown_tracker,
        Titan : Heroes.hero_titan,
        DamagePipeline : damage_pipeline,
        HealthManager : health_manager,
        StatusManager : status_effect_manager,
        KnockbackApplicator : knockback_applicator
    ) : logic =
        if (not AbilitiesEnabled):
            set AbilityEventLog += array{"BlockedDisabled: {Player} Slot={Slot}"}
            return false

        if (CooldownTracker.IsOnCooldown(Player, Slot, CurrentTimeSeconds)):
            Remaining := CooldownTracker.GetRemainingCooldown(Player, Slot, CurrentTimeSeconds)
            set AbilityEventLog += array{"BlockedCooldown: {Player} Slot={Slot} Remaining={Remaining}"}
            return false

        HeroId := GetHeroId(Player)
        if (HeroId = "Titan"):
            Result := Titan.TryExecuteAbility(Player, Slot, PotentialTargets, DamagePipeline, HealthManager, StatusManager, KnockbackApplicator)
            if (Result.Succeeded):
                CooldownTracker.StartCooldown(Player, Slot, CurrentTimeSeconds, Result.CooldownSeconds, Result.CooldownStartDelaySeconds)
                set AbilityEventLog += array{"Activated: {Player} Hero={HeroId} Ability={Result.AbilityLabel}"}
                return true

            set AbilityEventLog += array{"ActivationFailed: {Player} Hero={HeroId} Slot={Slot}"}
            return false

        set AbilityEventLog += array{"BlockedUnknownHero: {Player} Hero={HeroId}"}
        return false

    GetRemainingCooldown(
        Player : agent,
        Slot : ability_slot,
        CurrentTimeSeconds : float,
        CooldownTracker : cooldown_tracker
    ) : float =
        return CooldownTracker.GetRemainingCooldown(Player, Slot, CurrentTimeSeconds)

    GetHeroId(Player : agent) : string =
        if (Value := HeroByPlayer[Player]):
            return Value
        return "Titan"

