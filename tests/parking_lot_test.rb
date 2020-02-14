require "minitest/autorun"
require_relative "../parking_space"
require_relative "../parking_lot"
require_relative "../attendant"
require_relative "../owner"
require_relative "../traffic_police_dept"

describe ParkingLot do

    before do
        @honda_city = Object.new
        @honda_accord= Object.new
        @honda_civic = Object.new
        @audi= Object.new
        @mini = Object.new
    end

    it 'ensures that Parkinglot sends notification to owner if 100% occupied' do
        parking_space_1 = ParkingSpace.new 2
        parking_space_2 = ParkingSpace.new 4
        parking_lot = ParkingLot.new parking_space_1,parking_space_2
        owner = Minitest::Mock.new 
        parking_lot.add_observer owner
        owner.expect :update_on_80_percent_occupancy, parking_lot, [Object]###
        owner.expect :update_on_space_full, parking_lot, [Object]
        owner.expect :update_on_space_full, parking_lot, [Object]
        parking_space_1.park(@honda_city)
        parking_space_1.park(@honda_civic)
        parking_space_2.park(@honda_accord)
        parking_space_2.park(@audi)
        parking_space_2.park(@mini)
        parking_space_2.park(@honda_civic)

        assert owner.verify
    end

    it 'ensures that Parkinglot sends notification to owner if 100% occupied' do
        parking_space_1 = ParkingSpace.new 1
        parking_space_2 = ParkingSpace.new 2
        parking_lot = ParkingLot.new parking_space_1,parking_space_2
        owner = Owner.new parking_lot 
        parking_space_1.park(@honda_city)
        parking_space_2.park(@honda_accord)
        parking_space_2.park(@audi)

        assert_equal(0,owner.available_parkings.count)
    end

    it 'Parkinglot sends notification to owner after parking is available' do
        parking_space_1 = ParkingSpace.new 1
        parking_space_2 = ParkingSpace.new 2
        parking_lot = ParkingLot.new parking_space_1,parking_space_2
        owner = Owner.new parking_lot 
        parking_space_1.park(@honda_city)
        parking_space_2.park(@honda_accord)
        parking_space_2.park(@audi)
        parking_space_1.unpark(@honda_city.object_id)
        
        assert_includes(owner.available_parkings,parking_lot)
    end

    it "ensures owner is aware that parking lot is available even if one of its parkingspace gets available" do  
        parking_space_1 = ParkingSpace.new 1
        parking_space_2 = ParkingSpace.new 1
        parking_lot = ParkingLot.new parking_space_1,parking_space_2
        owner = Owner.new parking_lot
        parking_space_1.park @honda_city
        parking_space_2.park @audi
        parking_space_2.unpark @audi.object_id
        
        assert_includes(owner.available_parkings,parking_lot)
    end

    it 'ensures that Parkinglot sends notification to trafficpolice dept if 80% occupied' do
        parking_space_1 = ParkingSpace.new 2
        parking_space_2 = ParkingSpace.new 4
        parking_lot = ParkingLot.new parking_space_1,parking_space_2
        traffic_police_department = Minitest::Mock.new 
        parking_lot.add_observer traffic_police_department
        traffic_police_department.expect :update_on_80_percent_occupancy, parking_lot, [Object]
        parking_space_1.park(@honda_city)
        parking_space_1.park(@honda_civic)
        parking_space_2.park(@honda_accord)
        parking_space_2.park(@audi)
        parking_space_2.park(@mini)

        assert traffic_police_department.verify
    end

    it 'ensures Parkinglot does not send notification to traffic police dept twice' do
        parking_space_1 = ParkingSpace.new 2
        parking_space_2 = ParkingSpace.new 5
        parking_lot = ParkingLot.new parking_space_1,parking_space_2
        traffic_police_department = Minitest::Mock.new 
        parking_lot.add_observer traffic_police_department
        traffic_police_department.expect :update_on_80_percent_occupancy, parking_lot, [Object]
        sumo = Object.new
        parking_space_1.park(@honda_city)
        parking_space_1.park(@honda_civic)
        parking_space_2.park(@honda_accord)
        parking_space_2.park(@audi)
        parking_space_2.park(@mini)
        parking_space_2.park(sumo)

        assert traffic_police_department.verify
    end

    it "ensures parking lot sends notifications to Traffic police dept after 80% occupancy" do
        parking_space_1 = ParkingSpace.new 2
        parking_space_2 = ParkingSpace.new 4
        parking_lot = ParkingLot.new parking_space_1,parking_space_2
        traffic_police_department = TrafficPoliceDepartment.new parking_lot
        parking_space_1.park(@honda_city)
        parking_space_1.park(@honda_civic)
        parking_space_2.park(@honda_accord)
        parking_space_2.park(@audi)
        parking_space_2.park(@mini)
        
        assert(1,traffic_police_department.updates_received_count)
    end

    it 'ensures Parkinglot does not send notification to traffic police dept twice' do
        parking_space_1 = ParkingSpace.new 2
        parking_space_2 = ParkingSpace.new 5
        parking_lot = ParkingLot.new parking_space_1,parking_space_2
        traffic_police_department = TrafficPoliceDepartment.new parking_lot
        sumo = Object.new
        parking_space_1.park(@honda_city)
        parking_space_1.park(@honda_civic)
        parking_space_2.park(@honda_accord)
        parking_space_2.park(@audi)
        parking_space_2.park(@mini)
        parking_space_2.park(sumo)

        assert_equal(1,traffic_police_department.updates_received_count)
    end

    it 'Parkinglot sends notification to police dept after AGAIN exceeding 80%' do
        parking_space_1 = ParkingSpace.new 2
        parking_space_2 = ParkingSpace.new 5
        parking_lot = ParkingLot.new parking_space_1,parking_space_2
        traffic_police_department = TrafficPoliceDepartment.new parking_lot
        sumo = Object.new
        parking_space_1.park(@honda_city)
        parking_space_1.park(@honda_civic)
        parking_space_2.park(@honda_accord)
        parking_space_2.park(@audi)
        parking_space_2.park(@mini)
        parking_space_2.park(sumo)
        parking_space_2.unpark(sumo.object_id)
        parking_space_2.unpark(@mini.object_id)
        parking_space_2.park(@honda_city)
        parking_space_2.park(@honda_civic)

        assert_equal(2,traffic_police_department.updates_received_count)
    end

end
