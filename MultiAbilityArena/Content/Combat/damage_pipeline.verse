using { /Verse.org/Simulation }
# Sprint 3 combat core: damage pipeline with invulnerability and modifiers.

damage_pipeline := class:
    var InvulnerablePlayers : [agent]logic = map{}
    var DamageModifierByPlayer : [agent]float = map{}
    var DamageEventLog : []string = array{}

    SetInvulnerable(Player : agent, Enabled : logic) : void =
        if (set InvulnerablePlayers[Player] = Enabled) {}
        set DamageEventLog += array{"SetInvulnerable: {Player}={Enabled}"}

    SetDamageModifier(Player : agent, Multiplier : float) : void =
        SafeMultiplier := MaxFloat(Multiplier, 0.0)
        if (set DamageModifierByPlayer[Player] = SafeMultiplier) {}
        set DamageEventLog += array{"SetDamageModifier: {Player}={SafeMultiplier}"}

    ProcessDamage(
        Source : agent,
        Target : agent,
        IncomingAmount : float,
        Type : damage_type,
        HealthManager : health_manager
    ) : float =
        if (IsInvulnerable(Target)):
            set DamageEventLog += array{"BlockedByInvulnerability: {Source}->{Target}"}
            return 0.0

        BaseAmount := MaxFloat(IncomingAmount, 0.0)
        ModifiedAmount := BaseAmount * GetDamageModifier(Target)
        Applied := HealthManager.ApplyDamage(Target, ModifiedAmount, Type)

        set DamageEventLog += array{"ProcessDamage: {Source}->{Target} Incoming={IncomingAmount} Modified={ModifiedAmount} Applied={Applied}"}
        return Applied

    ProcessHealing(Source : agent, Target : agent, IncomingAmount : float, HealthManager : health_manager) : float =
        BaseAmount := MaxFloat(IncomingAmount, 0.0)
        Applied := HealthManager.ApplyHealing(Target, BaseAmount)
        set DamageEventLog += array{"ProcessHealing: {Source}->{Target} Incoming={IncomingAmount} Applied={Applied}"}
        return Applied

    IsInvulnerable(Player : agent) : logic =
        if (Value := InvulnerablePlayers[Player]):
            return Value
        return false

    GetDamageModifier(Player : agent) : float =
        if (Value := DamageModifierByPlayer[Player]):
            return Value
        return 1.0

    MaxFloat(A : float, B : float) : float =
        if (A > B):
            return A
        return B

