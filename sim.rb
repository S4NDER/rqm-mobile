#!/data/data/com.termux/files/usr/bin/ruby

require 'mqtt'
require 'json'

$min_luminosity = 0
$max_luminosity = 1000

$min_dB = 20
$max_dB = 110

$min_humidity = 0
$max_humidiy = 10

$min_temp = 5
$max_temp = 45

$send_interval = 10     #Time to wait between sending data

$float_accuracy = 2
$float_factor_min = 1.1
$float_factor_max = 1.5

$device_count = 3

$mqtt_client = MQTT::Client.connect('mqtt.labict.be')
$sensor_topic = 'IoTdevices/RoomMonitor'

class Sensor_Simulator

    attr_accessor:hash

    def send_to_mqtt
        get_random_hash_for_json
        payload = JSON.generate(get_random_hash_for_json)
        puts "#{payload}"
        puts "\n"
        $mqtt_client.publish($sensor_topic, payload, retain = false)
    end

    def run_simulator
        while true
            begin
                send_to_mqtt
                begin
                    wait_x_seconds
                rescue
                    puts "Something went wrong while waiting"
                    puts "Trying to restart simulator"
                ensure
                    run_simulator
                end
            rescue MQTT::ProtocolException
                puts "Something went wrong with MQTT"
                puts "Trying to restart simulator"
            ensure
                run_simulator
            end


        end
    end

    def get_random_dB
        return (rand($min_dB..$max_dB)/rand($float_factor_min..$float_factor_max)).round($float_accuracy)
    end

    def get_random_temperature
        return (rand($min_temp..$max_temp)/rand($float_factor_min..$float_factor_max)).round($float_accuracy)
    end

    def get_random_luminosity
        return (rand($min_luminosity..$max_luminosity)/rand($float_factor_min..$float_factor_max)).round($float_accuracy)
    end

    def get_random_humidity
        return (rand($min_humidity..$max_humidiy)/rand($float_factor_min..$float_factor_max)).round($float_accuracy)
    end

    def wait_x_seconds
        sleep $send_interval
    end

    def get_random_device_name
        return "simulator_#{rand(0..$device_count)}"
    end

    def get_random_hash_for_json
        random = Random.new
        random_value = random.rand(1..16)

        hash =  {}

        hash["audio_level"] = get_random_dB if (random_value / 1) % 2 == 0
        hash["temp_raw"] = get_random_temperature if (random_value / 2) % 2 == 0
        hash["humidity"] = get_random_humidity if (random_value / 4) % 2 == 0
        hash["luminosity"] = get_random_luminosity if (random_value / 8) % 2 == 0
        hash["device_name"] = get_random_device_name

        return hash
    end
end
puts "Sensor topic: 'IoTdevices/RoomMonitor'"
puts "MQTT broker: 'mqtt.labict.be'"
puts "Simulator can be ended by pressing Ctrl+Pause/Break"
sensor_simulator = Sensor_Simulator.new
sensor_simulator.run_simulator
