using OmronD6FPH, PyCall

u3 = pyimport("u3")                           # import u3
(@isdefined handle) || (handle = u3.U3())     # only open device once 

# Configure IO - see documentation for Labjack Python
handle.configIO(EnableCounter0 = false, EnableCounter1 = false, NumberOfTimersEnabled = 0)

# Initialize D6F-PH sensor - isInitialized should be true
isInitialized = OmronD6FPH.initialize(handle; SDAP = 4, SCLP = 5)

# Read T in Celsius
T = OmronD6FPH.T(handle; SDAP = 4, SCLP = 5)

# read differential pressure in Pa 
dp = OmronD6FPH.dp(handle, "0505AD3"; SDAP = 4, SCLP = 5)

println("T = ", T, "  dp = ", dp)
