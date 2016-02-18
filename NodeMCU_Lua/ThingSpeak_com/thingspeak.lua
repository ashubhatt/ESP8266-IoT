----------------------------------------------------
-- Author: Ashutosh Bhatt
-- Email: ashubhatt.ec@gmail.com
-- Task: Attach a sensor or potentiometer to sample 
-- its analog value through NodeMCU and send these 
-- values to thingspeak.com to plot a graph online
-- *** Make sure the input voltage is less than 1.8 V
----------------------------------------------------

-- Your Wifi connection data
local SSID = "YOUR_SSID"
local SSID_PASSWORD = "YOUR_PASSWORD"

-- Data URL: https://thingspeak.com/channels/XXXXX/
privateKey = "XXXXXXXXXXXXXXXX"


-- Plotly Username and API key
host = "api.thingspeak.com"


-- Configure the ESP as a station (client)
wifi.setmode (wifi.STATION)
wifi.sta.config (SSID, SSID_PASSWORD, 1)

-- Add delay of 1 second
tmr.delay(1000)

-------------------------------------------------------

function findip()
    tmr.stop(2)
    -- Get ip, netmask, gateway address in station mode
    print("Current IP, Netmask, Gateway")
    if(not wifi.sta.getip()) then
        tmr.alarm(2,1000,1,findip)
    else
        startPlotting()
    end
    print(wifi.sta.getip())
end

-- send to https://www.thingspeak.com
function plotValues(value)
    header = 'GET /update?key=' .. privateKey ..
	'&field1=' .. value ..
	'HTTP/1.1\r\n' .. "Host: " .. host .. '\r\n' ..
	'Connection: close\r\n\r\n'
    
    print(header)
    conn = nil
    -- TCP connection with unsecure link
    conn = net.createConnection(net.TCP, 0)
    conn:on("receive", function(conn, payload) print(payload) end)
    conn:on("connection",
        function(conn, payload)
            conn:send(header)
        end)
    conn:on("disconnection", function(conn, payload) print('Disconnected') end)
    conn:connect(80,host)
end

-- Sample the Sensor Value
function startPlotting()
    -- tmr.time() gives time in second since startup
    plotValues(adc.read(0))
    --conn:close()            
    -- Continuosly sample the value of potentiometer every 5 seconds
    tmr.alarm(1, 10000, 1, startPlotting)
end


findip()