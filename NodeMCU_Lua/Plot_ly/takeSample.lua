function send2plotly(x, y)
    jsonlength = 18 + string.len(x) + string.len(y) 
    contentLength = jsonlength + 1 + string.len(string.format('%x', jsonlength))
    
    header = 'POST / HTTP/1.1\r\n' ..
    'Host: stream.plot.ly\r\n' ..
    'User-Agent: Arduino\r\n' ..
    'Transfer-Encoding: chunked\r\n' ..
    --'Connection: close\r\n' ..
    'plotly-streamtoken: ' .. tokens .. '\r\n' ..
    --'plotly-convertTimestamp: ' .. timezone .. '\r\n' ..
    'Content-Length: ' .. contentLength .. '\r\n' ..
    'Content-Type: text/plain\r\n'..
    '\r\n' ..
    string.format('%x', jsonlength) .. '\r\n' ..
    '{ "x": ' .. x .. ', "y": ' .. y .. ' }\n0\r\n'
    
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
    conn:connect(80,'stream.plot.ly')
    --conn:connect(80,'192.168.187.1')
end

function startPlotting()
    -- tmr.time() gives time in second since startup
    send2plotly(tmr.time(), adc.read(0))
    --conn:close()            
    -- Continuosly sample the value of potentiometer every 5 seconds
    tmr.alarm(1, 10000, 1, startPlotting)
end

tokens = "PLOTLY_TOKEN"
startPlotting()