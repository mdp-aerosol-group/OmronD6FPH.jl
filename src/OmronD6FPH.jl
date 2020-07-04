module OmronD6FPH

# Author: Markus Petters
#         mdpetter@ncsu.edu

using PyCall

const D6FPH_ADDRESS = 0x6C
const START_ADDRESS = 0x00
const BUFFER_0 = 0x07
const CTRL_REG = 0x0B

const SENS_CTRL_MS = 2
const SENS_CTRL_DV_PWR = 1
const SENS_CTRL_VAL = (0x01 << SENS_CTRL_MS | 0x01 << SENS_CTRL_DV_PWR)

const SERIAL_CTRL_D_BYTE_CNT3 = 5
const SERIAL_CTRL_REQ = 3
const SERIAL_CTRL_R_WZ = 2
const SERIAL_CTRL_VAL =
    (0x01 << SERIAL_CTRL_R_WZ | 0x01 << SERIAL_CTRL_REQ | 0x01 << SERIAL_CTRL_D_BYTE_CNT3)


"""
	initialize(handle; SDAP = 0, SCLP = 1)

Initialize the sensor using the i2c bus tied to a LabJack device with handle handle. SDAP and SCLP are the i2c channel numbers 0 = FIO0, 1 = FIO1 (etc).
"""
function initialize(handle; SDAP = 0, SCLP = 1)
    ret = handle.i2c(
        D6FPH_ADDRESS,
        PyVector([CTRL_REG, START_ADDRESS]),
        SDAPinNum = SDAP,
        SCLPinNum = SCLP,
    )
    if ret["AckArray"][1] == 0
        println("Got Ack 0: Something went wrong")
        println("Do you have the right FIO channels?")
        println("Did you turn off the counters and timers?")
        println("Is your device connected?")
        return false
    end
    return true
end

"""
	temperature(handle)

Read the temperature from the device in degree C
"""
function T(handle; SDAP = 0, SCLP = 1)
    handle.i2c(
        D6FPH_ADDRESS,
        PyVector([START_ADDRESS, 0xD0, 0x61, SERIAL_CTRL_VAL]),
        SDAPinNum = SDAP,
        SCLPinNum = SCLP,
    )
    sleep(33 / 1000)
    handle.i2c(
        D6FPH_ADDRESS,
        PyVector([START_ADDRESS, 0xD0, 0x40, 0x18, SENS_CTRL_VAL]),
        SDAPinNum = SDAP,
        SCLPinNum = SCLP,
    )
    sleep(33 / 1000)
    ret = handle.i2c(
        D6FPH_ADDRESS,
        PyVector([BUFFER_0]),
        NumI2CBytesToReceive = 2,
        SDAPinNum = SDAP,
        SCLPinNum = SCLP,
    )
    if ret["AckArray"][1] == 0
        println("Got Ack 0: Something went wrong")
        println("Did you correctly initialize the sensor?")
        return nothing
    else
        n = ret["I2CBytes"]
        return (((n[1] << 8) | n[2]) - 10214) / 37.39
    end
end

"""
	dp(handle, sensor)

Read the differential pressure from the device in Pa. The sensor is a string that
specifies the range of the device and one of the following three:

"5050AD3"
"0505AD3"
"0025AD1"

"""
function dp(handle, sensor; SDAP = 0, SCLP = 1)
    if sensor == "5050AD3"
        rangeMode = 500
    elseif sensor == "0505AD3"
        rangeMode = 50
    elseif sensor == "0025AD1"
        rangeMode = 250
    else
        println("Error: Sensor type unknown")
        return nothing
    end

    handle.i2c(
        D6FPH_ADDRESS,
        PyVector([START_ADDRESS, 0xD0, 0x40, 0x18, SENS_CTRL_VAL]),
        SDAPinNum = SDAP,
        SCLPinNum = SCLP,
    )
    sleep(33 / 1000)
    handle.i2c(
        D6FPH_ADDRESS,
        PyVector([START_ADDRESS, 0xD0, 0x51, SERIAL_CTRL_VAL]),
        SDAPinNum = SDAP,
        SCLPinNum = SCLP,
    )
    sleep(33 / 1000)
    ret = handle.i2c(
        D6FPH_ADDRESS,
        PyVector([BUFFER_0]),
        NumI2CBytesToReceive = 2,
        SDAPinNum = SDAP,
        SCLPinNum = SCLP,
    )
    if ret["AckArray"][1] == 0
        println("Got Ack 0: Something went wrong")
        println("Did you correctly initialize the sensor?")
        return nothing
    else
        n = ret["I2CBytes"]
        raw = ((n[1] << 8) | n[2])
        return (raw - 1024) * rangeMode * 2 / 60000 - rangeMode
    end
end

end
