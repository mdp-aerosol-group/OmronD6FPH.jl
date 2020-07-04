using OmronD6FPH, PyCall

u6 = pyimport("u6")                         # import u6
(@isdefined handle) || (handle = u6.U6())   # only open device once

# Configure IO - see documentation for Labjack Python
handle.configIO(EnableCounter0 = false, EnableCounter1 = false, NumberTimersEnabled = 0)

# Initialize D6F-PH sensor - isInitialized should be tru
isInitialized = OmronD6FPH.initialize(handle; SDAP = 0, SCLP = 1)

# Read T in Celsius
T = OmronD6FPH.T(handle; SDAP = 0, SCLP = 1)

# read differential pressure in Pa 
dp = OmronD6FPH.dp(handle, "0505AD3"; SDAP = 0, SCLP = 1)

println("T = ", T, "  dp = ", dp)
