----------------------------------------------------
-- Author: Ashutosh Bhatt
-- Email: ashubhatt.ec@gmail.com
-- Task: Attach a sensor or potentiometer to sample 
-- its analog value through NodeMCU and send these 
-- values to plot.ly to plot a graph online
-- *** Make sure the input voltage is less than 1.8 V
----------------------------------------------------

-- Your Wifi connection data
local SSID = "YOUR WIFI SSID"
local SSID_PASSWORD = "YOUR SSID PASSPHRASE"

-- Plotly Username and API key
userName = "PLOTLY_USERNAME"
APIKey = "PLOTLY_API"
tokens = "PLOTLY_TOKKEN"

fileName = "test"
fileopt = "overwrite"
maxpoints = "40"
world_readable = true
convertTimestamp = true
timezone = "Asia/Kolkata"

success = false

-- Configure the ESP as a station (client)
wifi.setmode (wifi.STATION)
wifi.sta.config (SSID, SSID_PASSWORD, 1)

-- Add delay of 1 second
tmr.delay(1000)

-------------------------------------------------------
-- Calculate content length
contentLength = 126 + string.len(userName) + string.len(fileopt) + 87 + string.len(maxpoints) + string.len(fileName);
if(world_readable == true) then
    contentLength = contentLength + 4;
else
    contentLength = contentLength + 5;
end
header = 'POST /clientresp HTTP/1.1\r\n' ..
'Host: plot.ly:80\r\n' ..
'User-Agent: Arduino-/0.6.0\r\n' ..
'Content-Length:' .. contentLength .. '\r\n' ..
'Content-Type: application/x-www-form-urlencoded\r\n\r\n' ..
'version=2.3&origin=plot&platform=arduino'..
'&un=' .. userName ..
'&key=' .. APIKey .. 
'&args=[{"y": [], "x": [], "type": "scatter", "stream": {"token": "' .. tokens ..
'", "maxpoints": ' .. maxpoints .. '}}]' ..
'&kwargs={"fileopt": "' .. fileopt ..
'", "filename": "' .. fileName ..
'", "world_readable": '

if(world_readable == true) then
    header = header .. 'true}'
else 
    header = header .. 'false}'
end

header = header .. '}\r\n'

--print('--------------------------')
--print(header)
--print('--------------------------')
-------------------------------------------------------
----------------------------------------------------------------------------------
-- send to https://www.plot.ly
function plotly_init()
    conn = nil
    -- TCP connection with unsecure link
    conn = net.createConnection(net.TCP, 0)
    conn:on("receive", function(conn, payload)
        success = true 
        
        if(string.find(payload, '~')) then
            tmr.stop(1)
            print('Received Payload:')
            print(payload)
            tmr.alarm(1, 5000, 0, function()
                
                dofile('takeSample.lua')
            end)
        end
        end)
    conn:on("connection",
        function(conn, payload)
            conn:send(header)
                if(not success) then
                    tmr.alarm(1, 10000, 0, plotly_init)
                end
                
        end)
    conn:on("disconnection", function(conn, payload) print('Disconnected') end)
    conn:connect(80,'plot.ly')
end

function findip()
    tmr.stop(2)
    -- Get ip, netmask, gateway address in station mode
    print("Current IP, Netmask, Gateway")
    if(not wifi.sta.getip()) then
        tmr.alarm(2,1000,1,findip)
    else
        plotly_init()
    end
    print(wifi.sta.getip())
end

findip()


-- Reference Links: 
-- http://esp8266.fancon.cz/common/ts_fpdht.lua
-- https://hackaday.io/post/17879
-- http://www.esp8266.com/viewtopic.php?f=19&t=1470 