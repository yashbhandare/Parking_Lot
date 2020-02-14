class PoliceDepartment 
    def initialize parking_lot
        @parking_lot = parking_lot
    end

    def find_specific_colored_vehicles color
        @parking_lot.find_specific_colored_vehicles color
    end

    def find_parked_between from_time, to_time
        @parking_lot.find_parked_between from_time,to_time
    end
end