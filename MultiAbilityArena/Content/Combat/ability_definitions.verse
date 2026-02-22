ability_slot<public> := enum:
    Primary
    Secondary
    Ultimate

ability_execution_result<public> := struct:
    Succeeded<public> : logic
    CooldownSeconds<public> : float
    CooldownStartDelaySeconds<public> : float
    AbilityLabel<public> : string
