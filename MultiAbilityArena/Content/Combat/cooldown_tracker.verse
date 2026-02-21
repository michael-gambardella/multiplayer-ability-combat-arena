using { /Verse.org/Simulation }
# Sprint 4 ability framework: per-agent/per-slot cooldown tracking.

cooldown_tracker := class:
    var PrimaryCooldownEndByPlayer : [agent]float = map{}
    var SecondaryCooldownEndByPlayer : [agent]float = map{}
    var UltimateCooldownEndByPlayer : [agent]float = map{}
    var CooldownEventLog : []string = array{}

    StartCooldown(
        Player : agent,
        Slot : ability_slot,
        CurrentTimeSeconds : float,
        CooldownSeconds : float,
        DelaySeconds : float
    ) : void =
        SafeCooldown := MaxFloat(CooldownSeconds, 0.0)
        SafeDelay := MaxFloat(DelaySeconds, 0.0)
        EndTime := CurrentTimeSeconds + SafeDelay + SafeCooldown

        if (Slot = ability_slot.Primary):
            if (set PrimaryCooldownEndByPlayer[Player] = EndTime) {}
        if (Slot = ability_slot.Secondary):
            if (set SecondaryCooldownEndByPlayer[Player] = EndTime) {}
        if (Slot = ability_slot.Ultimate):
            if (set UltimateCooldownEndByPlayer[Player] = EndTime) {}

        set CooldownEventLog += array{"StartCooldown: {Player} Slot={Slot} End={EndTime}"}

    GetRemainingCooldown(Player : agent, Slot : ability_slot, CurrentTimeSeconds : float) : float =
        EndTime := GetCooldownEndTime(Player, Slot)
        Remaining := EndTime - CurrentTimeSeconds
        if (Remaining < 0.0):
            return 0.0
        return Remaining

    IsOnCooldown(Player : agent, Slot : ability_slot, CurrentTimeSeconds : float) : logic =
        return GetRemainingCooldown(Player, Slot, CurrentTimeSeconds) > 0.0

    ClearPlayerCooldowns(Player : agent) : void =
        if (set PrimaryCooldownEndByPlayer[Player] = 0.0) {}
        if (set SecondaryCooldownEndByPlayer[Player] = 0.0) {}
        if (set UltimateCooldownEndByPlayer[Player] = 0.0) {}
        set CooldownEventLog += array{"ClearPlayerCooldowns: {Player}"}

    GetCooldownEndTime(Player : agent, Slot : ability_slot) : float =
        if (Slot = ability_slot.Primary):
            if (Value := PrimaryCooldownEndByPlayer[Player]):
                return Value
            return 0.0

        if (Slot = ability_slot.Secondary):
            if (Value := SecondaryCooldownEndByPlayer[Player]):
                return Value
            return 0.0

        if (Value := UltimateCooldownEndByPlayer[Player]):
            return Value
        return 0.0

    MaxFloat(A : float, B : float) : float =
        if (A > B):
            return A
        return B

