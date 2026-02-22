using { /Verse.org/Simulation }

cooldown_tracker<public> := class:
    var PrimaryCooldownEndByPlayer : [agent]float = map{}
    var SecondaryCooldownEndByPlayer : [agent]float = map{}
    var UltimateCooldownEndByPlayer : [agent]float = map{}
    var CooldownEventLog : []string = array{}

    StartCooldown<public>(
        Player : agent,
        Slot : Combat.ability_slot,
        CurrentTimeSeconds : float,
        CooldownSeconds : float,
        DelaySeconds : float
    ) : void =
        SafeCooldown := MaxFloat(CooldownSeconds, 0.0)
        SafeDelay := MaxFloat(DelaySeconds, 0.0)
        EndTime := CurrentTimeSeconds + SafeDelay + SafeCooldown

        if ((Slot = Combat.ability_slot.Primary)):
            if (set PrimaryCooldownEndByPlayer[Player] = EndTime) {}
        if ((Slot = Combat.ability_slot.Secondary)):
            if (set SecondaryCooldownEndByPlayer[Player] = EndTime) {}
        if ((Slot = Combat.ability_slot.Ultimate)):
            if (set UltimateCooldownEndByPlayer[Player] = EndTime) {}

        set CooldownEventLog += array{"StartCooldown"}

    GetRemainingCooldown<public>(Player : agent, Slot : Combat.ability_slot, CurrentTimeSeconds : float) : float =
        EndTime := GetCooldownEndTime(Player, Slot)
        Remaining := EndTime - CurrentTimeSeconds
        if ((Remaining < 0.0)):
            return 0.0
        return Remaining

    IsOnCooldown<public>(Player : agent, Slot : Combat.ability_slot, CurrentTimeSeconds : float) : logic =
        Remaining := GetRemainingCooldown(Player, Slot, CurrentTimeSeconds)
        if ((Remaining > 0.0)):
            return true
        return false

    ClearPlayerCooldowns<public>(Player : agent) : void =
        if (set PrimaryCooldownEndByPlayer[Player] = 0.0) {}
        if (set SecondaryCooldownEndByPlayer[Player] = 0.0) {}
        if (set UltimateCooldownEndByPlayer[Player] = 0.0) {}
        set CooldownEventLog += array{"ClearPlayerCooldowns"}

    GetCooldownEndTime<public>(Player : agent, Slot : Combat.ability_slot) : float =
        if ((Slot = Combat.ability_slot.Primary)):
            if (Value := PrimaryCooldownEndByPlayer[Player]):
                return Value
            return 0.0

        if ((Slot = Combat.ability_slot.Secondary)):
            if (Value := SecondaryCooldownEndByPlayer[Player]):
                return Value
            return 0.0

        if (Value := UltimateCooldownEndByPlayer[Player]):
            return Value
        return 0.0

    MaxFloat(A : float, B : float) : float =
        if ((A > B)):
            return A
        return B

