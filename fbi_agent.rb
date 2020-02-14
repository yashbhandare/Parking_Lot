class FBIAgent
    include Observer
    attr_reader :reported_vehicles
    def initialize *parking_spaces
        @parking_spaces = parking_spaces
        @parking_spaces.each { |parking_space| parking_space.add_observer(self) } 
        @reported_vehicles = {}      
    end
    def update_car_not_available(parking_space,parking_token)
        puts "Car having token #{parking_token} is not available in parking space #{parking_space}"
        @reported_vehicles.merge!( parking_token => parking_space )
    end
end