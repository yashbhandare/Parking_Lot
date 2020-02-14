require 'minitest/autorun'
require_relative '../parking_space'
require_relative '../owner'
require_relative '../attendant'
require_relative '../parking_lot'
require_relative '../fbi_agent'
require_relative '../police_department'
require 'time'

describe ParkingSpace do
    system 'clear'
    before do 
        @parking_space_1 = ParkingSpace.new 3
        @honda_city = Object.new
        @_10am = Time.parse("2011-1-2 10:00:00")
    end
    it "Police dept finds all blue cars in parkinglot" do
        parking_lot = ParkingLot.new @parking_space_1
        police_department = PoliceDepartment.new parking_lot
        @parking_space_1.park @honda_city,@_10am, 'blue'
        blue_colored_vehicles = police_department.find_specific_colored_vehicles('blue').first
        assert_equal(@honda_city.object_id,blue_colored_vehicles)
    end

    it "Police dept finds all blue cars in parkinglot" do
        parking_space_2 = ParkingSpace.new 3
        parking_lot = ParkingLot.new @parking_space_1,parking_space_2
        police_department = PoliceDepartment.new parking_lot
        audi = Object.new
        mini = Object.new
        @parking_space_1.park @honda_city,@_10am, 'blue'
        parking_space_2.park mini
        parking_space_2.park audi, @_10am,'blue'
        blue_colored_vehicles = police_department.find_specific_colored_vehicles('blue')
        assert_equal([@honda_city.object_id,audi.object_id],blue_colored_vehicles)
    end

    it "finds out cars parked between 8am to 10am" do
        parking_lot = ParkingLot.new @parking_space_1
        police_department = PoliceDepartment.new parking_lot
        @parking_space_1.park @honda_city, Time.parse("2011-1-2 09:00:00")
        _8am = Time.parse("2011-1-2 08:00:00")
        assert_equal([@honda_city.object_id],police_department.find_parked_between(_8am,@_10am))
    end

    it "finds out cars parked between 8am to 10am" do
        parking_lot = ParkingLot.new @parking_space_1
        police_department = PoliceDepartment.new parking_lot
        @parking_space_1.park @honda_city, Time.parse("2011-1-2 11:00:00")
        _8am = Time.parse("2011-1-2 08:00:00")
        refute_equal([@honda_city.object_id],police_department.find_parked_between(_8am,@_10am))
    end

    it "finds out cars parked between 8am to 10am" do
        parking_lot = ParkingLot.new @parking_space_1
        police_department = PoliceDepartment.new parking_lot
        _9am = Time.parse("2011-1-2 09:00:00")
        _8am = Time.parse("2011-1-2 08:00:00")
        Time.stub :now, Time.at(_9am) do
            @parking_space_1.park @honda_city, Time.now
        end
        assert_equal([@honda_city.object_id],police_department.find_parked_between(_8am,@_10am))
    end



end


