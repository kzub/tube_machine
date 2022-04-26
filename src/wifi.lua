print("Loading wifi.lua")
WIFI_STA_IP = ""

-- Define WiFi station event callbacks
wifi_connect_event = function(T)
  print("Connection to AP("..T.SSID..") established!")
  print("Waiting for IP address...")
  if disconnect_ct ~= nil then disconnect_ct = nil end
end

wifi_got_ip_event = function(T)
  -- Note: Having an IP address does not mean there is internet access!
  -- Internet connectivity can be determined with net.dns.resolve().
  print("Wifi connection is ready! IP address is: "..T.IP)
  WIFI_STA_IP = T.IP
end

wifi_disconnect_event = function(T)
  if T.reason == wifi.eventmon.reason.ASSOC_LEAVE then
    --the station has disassociated from a previously connected AP
    return
  end
  -- total_tries: how many times the station will attempt to connect to the AP. Should consider AP reboot duration.
  local total_tries = 75
  print("\nWiFi connection to AP("..T.SSID..") has failed!")

  --There are many possible disconnect reasons, the following iterates through
  --the list and returns the string corresponding to the disconnect reason.
  for key,val in pairs(wifi.eventmon.reason) do
    if val == T.reason then
      print("Disconnect reason: "..val.."("..key..")")
      break
    end
  end

  if disconnect_ct == nil then
    disconnect_ct = 1
  else
    disconnect_ct = disconnect_ct + 1
  end
  if disconnect_ct < total_tries then
    print("Retrying connection...(attempt "..(disconnect_ct+1).." of "..total_tries..")")
  else
    wifi.sta.disconnect()
    print("Aborting connection to AP!")
    disconnect_ct = nil
    -- try to reconnect
    tmr.create():alarm(3000, tmr.ALARM_SINGLE, wifi.sta.connect)
  end
end

-- Register WiFi Station event callbacks
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, wifi_connect_event)
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, wifi_got_ip_event)
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, wifi_disconnect_event)

local wifiInitilized = false
function wifiModeSTA(ssid, password)
  if wifiInitilized and ssid == SSID and password == PASSWORD then
    print("ingore connectiong to same wifi network")
    return
  end
  wifiInitilized = true
  print("Connecting to WiFi AP:("..ssid..") PASS:("..password..")")
  file.open("credentials.lua", "w+")
  file.write('SSID="'..ssid..'"\nPASSWORD="'..password..'"\n');
  file.close()
  wifi.setmode(wifi.STATIONAP)
  wifi.sta.config({ssid=ssid, pwd=password})
  wifi.sta.connect() -- not necessary because config() uses auto-connect=true by default
end


print("initializing Soft-AP: 192.168.81.1")
wifi.setmode(wifi.SOFTAP)
wifi.ap.config({ ssid="TubesMachine", auth=wifi.OPEN })
wifi.ap.setip({ ip="192.168.81.1", netmask="255.255.255.0", gateway="192.168.81.1" })
wifi.ap.dhcp.config({ start="192.168.81.2" })
wifi.ap.dhcp.start()

if file.open("credentials.lua") then
  file.close()
  print("loading wifi credentials form file...")
  dofile("credentials.lua")
  wifiModeSTA(SSID, PASSWORD)
end


