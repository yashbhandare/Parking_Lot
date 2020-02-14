#require_relative "parking_staff"
class Coordinator < ParkingStaff
   attr_reader :available_attendants
    def initialize *parking_attendants
        super()
        @parking_attendants = parking_attendants
        @parking_attendants.each { |staff| staff.add_observer(self) }
        @available_attendants = Array.new @parking_attendants #available_staff
    end

    def direct vehicle
        @parking_attendants.each do |parking_staff|
            next if parking_staff.kind_of?(Coordinator) && parking_staff.available_attendants.length == 0 #not reqd
            return parking_staff.direct vehicle 
        end    
        raise "Parking Full!"
    end

    def update_on_space_full staff
        @available_attendants.delete staff
        notify_on_space_full self if @available_attendants.empty?
    end

    def update_on_space_open staff
        @available_attendants << staff
        notify_on_space_open self
    end
end
