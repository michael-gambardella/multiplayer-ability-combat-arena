# Sprint 3 combat core: health ownership, clamping, and lifecycle helpers.

damage_type := enum:
    Physical
    Ability
    Ultimate
    Environmental

health_record := struct:
    MaxHP : float
    CurrentHP : float
    IsAlive : logic

health_manager := class:
    var HealthByPlayer : [agent]health_record = map{}
    var LastDamageTypeByPlayer : [agent]damage_type = map{}
    var LastHealthEventLog : []string = array{}

    RegisterPlayer(Player : agent, MaxHP : float) : void =
        if (set HealthByPlayer[Player] = health_record{MaxHP := MaxHP, CurrentHP := MaxHP, IsAlive := true}) {}
        if (set LastDamageTypeByPlayer[Player] = damage_type.Physical) {}
        set LastHealthEventLog += array{"RegisterPlayer: {Player} HP={MaxHP}"}

    GetCurrentHP(Player : agent) : float =
        if (Health := HealthByPlayer[Player]):
            return Health.CurrentHP
        return 0.0

    GetMaxHP(Player : agent) : float =
        if (Health := HealthByPlayer[Player]):
            return Health.MaxHP
        return 0.0

    IsAlive(Player : agent) : logic =
        if (Health := HealthByPlayer[Player]):
            return Health.IsAlive
        return false

    ApplyDamage(Player : agent, Amount : float, Type : damage_type) : float =
        if (Health := HealthByPlayer[Player]):
            ClampedDamage := ClampFloat(Amount, 0.0, Health.CurrentHP)
            NewHP := Health.CurrentHP - ClampedDamage
            NewAlive := NewHP > 0.0
            if (set HealthByPlayer[Player] = health_record{MaxHP := Health.MaxHP, CurrentHP := NewHP, IsAlive := NewAlive}) {}
            if (set LastDamageTypeByPlayer[Player] = Type) {}
            set LastHealthEventLog += array{"ApplyDamage: {Player} Amount={ClampedDamage} HP={NewHP}"}
            return ClampedDamage
        return 0.0

    ApplyHealing(Player : agent, Amount : float) : float =
        if (Health := HealthByPlayer[Player]):
            if (not Health.IsAlive):
                return 0.0
            TargetHP := Health.CurrentHP + Amount
            NewHP := ClampFloat(TargetHP, 0.0, Health.MaxHP)
            AppliedHealing := NewHP - Health.CurrentHP
            if (set HealthByPlayer[Player] = health_record{MaxHP := Health.MaxHP, CurrentHP := NewHP, IsAlive := true}) {}
            set LastHealthEventLog += array{"ApplyHealing: {Player} Amount={AppliedHealing} HP={NewHP}"}
            return AppliedHealing
        return 0.0

    SetAliveState(Player : agent, Alive : logic) : void =
        if (Health := HealthByPlayer[Player]):
            if (set HealthByPlayer[Player] = health_record{MaxHP := Health.MaxHP, CurrentHP := Health.CurrentHP, IsAlive := Alive}) {}

    ResetToFullHealth(Player : agent) : void =
        if (Health := HealthByPlayer[Player]):
            if (set HealthByPlayer[Player] = health_record{MaxHP := Health.MaxHP, CurrentHP := Health.MaxHP, IsAlive := true}) {}
            set LastHealthEventLog += array{"ResetToFullHealth: {Player}"}

    ClampFloat(Value : float, MinValue : float, MaxValue : float) : float =
        if (Value < MinValue):
            return MinValue
        if (Value > MaxValue):
            return MaxValue
        return Value
