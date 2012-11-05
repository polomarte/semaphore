require 'bundler'
Bundler.require

require "net/http"

sp = SerialPort.new("/dev/ttyUSB0", 9600)

# wait for connection
sleep(1)

# create a new Faraday connection with the Jenkins server to read the status of each job
conn = Faraday.new('http://127.0.0.1:8080')
puts 'go to loop'

loop do
  begin
    # grab the json from the jenkins api
    response = conn.get('/job/Posto%20Zero/api/json?tree=color')
    # parse the response into a list of jobs that are being monitored
    json = JSON.parse(response.body)

    # search each job to see if it contains either "anime" (building) or "red" (failing)
    should_blink = json["color"] =~ /anime/
    should_red   = json["color"] =~ /red/
  rescue => e
    puts e.message
    # if no response, assume server is down – turn on Red and Yellow lights solid
    server_down = true
  end

  # check results of job colors
  if should_blink
    # something is building... flash yellow light!
    puts "Something is building... flash yellow light!"
    sp.write("1")
  else
    # nothing is building... turn yellow light Off.
    sp.write("2")
  end

  if should_red
    # something is red... turn On red light!
    puts "Something is broken... turn On red light!"
    sp.write("3")
  else
    # nothing is red... turn On green light.
    sp.write("4")
  end

  if server_down
    sp.write("5")
  end

  # wait 5 seconds
  sleep(5)
end

# close serial data line
sp.close
