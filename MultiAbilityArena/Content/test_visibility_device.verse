using { /Fortnite.com/Devices }

# Minimal placement test for Verse device discoverability in UEFN.
test_visibility_device := class<public><concrete>(creative_device):
    OnBegin<override>()<suspends> : void =
        return
