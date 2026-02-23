using { /Verse.org/Simulation }

projectile_record<public> := struct:
    RemainingDistance<public> : float
    SpeedPerSecond<public> : float
    IsActive<public> : logic
    IsBlocked<public> : logic

projectile_simulator<public> := class:
    var NextProjectileId : int = 1
    var ProjectileById : [int]Devices.projectile_record = map{}
    var GlobalProjectileBlock : logic = false
    var ProjectileEventLog : []string = array{}

    SpawnProjectile<public>(SpeedPerSecond : float, MaxRangeMeters : float) : int =
        SafeSpeed := MaxFloat(SpeedPerSecond, 0.0)
        SafeRange := MaxFloat(MaxRangeMeters, 0.0)
        ProjectileId := NextProjectileId
        if (set ProjectileById[ProjectileId] = Devices.projectile_record{RemainingDistance := SafeRange, SpeedPerSecond := SafeSpeed, IsActive := true, IsBlocked := false}) {}
        set NextProjectileId = NextProjectileId + 1
        set ProjectileEventLog += array{"SpawnProjectile"}
        return ProjectileId

    Tick<public>(DeltaTime : float) : void =
        for (ProjectileId -> Projectile : ProjectileById):
            if (Projectile.IsActive = true):
                if (GlobalProjectileBlock = true):
                    if (set ProjectileById[ProjectileId] = Devices.projectile_record{RemainingDistance := Projectile.RemainingDistance, SpeedPerSecond := Projectile.SpeedPerSecond, IsActive := false, IsBlocked := true}) {}
                    set ProjectileEventLog += array{"ProjectileBlockedBySanctuary"}
                else:
                    DistanceStep := Projectile.SpeedPerSecond * MaxFloat(DeltaTime, 0.0)
                    NewRemainingDistance := Projectile.RemainingDistance - DistanceStep
                    if ((NewRemainingDistance <= 0.0)):
                        if (set ProjectileById[ProjectileId] = Devices.projectile_record{RemainingDistance := 0.0, SpeedPerSecond := Projectile.SpeedPerSecond, IsActive := false, IsBlocked := false}) {}
                        set ProjectileEventLog += array{"ProjectileExpiredAtRange"}
                    else:
                        if (set ProjectileById[ProjectileId] = Devices.projectile_record{RemainingDistance := NewRemainingDistance, SpeedPerSecond := Projectile.SpeedPerSecond, IsActive := true, IsBlocked := false}) {}

    SetGlobalProjectileBlock<public>(Enabled : logic) : void =
        set GlobalProjectileBlock = Enabled
        set ProjectileEventLog += array{"SetGlobalProjectileBlock"}

    IsProjectileBlocked<public>(ProjectileId : int) : logic =
        if (Projectile := ProjectileById[ProjectileId]):
            return Projectile.IsBlocked
        return false

    IsProjectileActive<public>(ProjectileId : int) : logic =
        if (Projectile := ProjectileById[ProjectileId]):
            return Projectile.IsActive
        return false

    MaxFloat(A : float, B : float) : float =
        if ((A > B)):
            return A
        return B
