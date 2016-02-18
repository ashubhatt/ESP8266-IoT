/* 
 * Plotting data on thingspeak.com: Take analog input from ESP and pass that data 
 * to api.thingspeak.com and prepare an online graph.
 * Modify the parameters as per the requirement
 */
#include <ESP8266WiFi.h>

#define SENSOR A0


// Change SSID, PASSWORD and PrivateKey

const char* ssid     = "ssid";
const char* password = "password";

// Data URL: https://thingspeak.com/channels/XXXXX/
const char* privateKey = "XXXXXXXXXXXXXXXX";

const char* host = "api.thingspeak.com";

void setup() {
  Serial.begin(9600);
  delay(10);
  Serial.println();
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

float value = 0;

void loop() {
  delay(5000);
  value = analogRead(A0);

  Serial.print("connecting to ");
  Serial.println(host);

  // Use WiFiClient class to create TCP connections
  WiFiClient client;
  const int httpPort = 80;
  if (!client.connect(host, httpPort)) {
    Serial.println("connection failed");
    return;
  }
  Serial.println("connection done");
  // We now create a URI for the request
  String url = "/update?";
  url += "key=";
  url += privateKey;
  url += "&field1=";
  url += value;

  Serial.print("Requesting URL: ");
  Serial.println(url);

  // This will send the request to the server
  client.print(String("GET ") + url + " HTTP/1.1\r\n" +
               "Host: " + host + "\r\n" +
               "Connection: close\r\n\r\n");
  delay(10);

  // Read all the lines of the reply from server and print them to Serial
  while (client.available()) {
    String line = client.readStringUntil('\r');
    Serial.print(line);
  }

  Serial.println();
  Serial.println("closing connection");
}

