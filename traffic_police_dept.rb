class TrafficPoliceDepartment
    attr_reader :updates_received_count
    def initialize parking_lot
        @parking_lot = parking_lot
        @parking_lot.add_observer self
        @updates_received_count = 0
    end

    def update_on_80_percent_occupancy parking_lot
        #puts "Received update from parking lot"
        @updates_received_count += 1
    end

end