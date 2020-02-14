# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../parking_space'
require_relative '../attendant'
require_relative '../coordinator'

describe Attendant do
  before do
    @honda_city = Object.new
    @parking_space_1 = ParkingSpace.new 1
    @parking_space_2 = ParkingSpace.new 2
  end
  it 'Ensures that an attendant is directing car to ther respective space' do
    attendant = Attendant.new(@parking_space_1, @parking_space_2)
    expected = @honda_city.object_id
    actual = attendant.direct(@honda_city)
    assert_equal(expected, actual)
  end

  it 'Ensures that an attendant is directing car to ther respective space' do
    attendant = Attendant.new(@parking_space_1, @parking_space_2)
    honda_civic = Object.new
    expected = honda_civic.object_id
    attendant.direct(@honda_city, ParkingSpace::WITH_FIRST_AVAILABLE)
    actual = attendant.direct(honda_civic, ParkingSpace::WITH_FIRST_AVAILABLE)
    assert_equal(expected, actual)
  end

  it 'Ensures that an attendant is not directing car if there is no space' do
    attendant = Attendant.new(@parking_space_1, @parking_space_2)
    honda_civic = Object.new
    audi = Object.new
    honda_accord = Object.new
    attendant.direct(@honda_city, ParkingSpace::WITH_FIRST_AVAILABLE)
    attendant.direct(honda_civic, ParkingSpace::WITH_FIRST_AVAILABLE)
    attendant.direct(audi, ParkingSpace::WITH_FIRST_AVAILABLE)
    assert_raises(RuntimeError) do
      attendant.direct(honda_accord, ParkingSpace::WITH_FIRST_AVAILABLE)
    end
  end

  it 'attendant directs car to the parking space which has more free slots ' do
    attendant = Attendant.new(@parking_space_1, @parking_space_2)
    attendant.direct(@honda_city, ParkingSpace::WITH_MORE_SLOTS)
    p2_vehicles = @parking_space_2.vehicles.values
    assert_includes(p2_vehicles, @honda_city)
  end

  it 'attendant directs car to the parking space which has more free slots ' do
    attendant = Attendant.new(@parking_space_1, @parking_space_2)
    attendant.direct(@honda_city, ParkingSpace::WITH_LIMITED_SLOTS)
    p1_vehicles = @parking_space_1.vehicles.values
    assert_includes(p1_vehicles, @honda_city)
  end

  it 'marks full parking space as full' do
    attendant = Attendant.new @parking_space_1
    attendant.direct @honda_city
    refute_includes(attendant.available_parkings,@parking_space_1)
  end

  it 'updates full parking space from full to open when it becomes open' do
    attendant = Attendant.new @parking_space_1
    attendant.direct @honda_city
    @parking_space_1.unpark @honda_city.object_id
    assert_includes(attendant.available_parkings,@parking_space_1)
  end

  it 'ensures coordinator is notified whenever all parking spaces are full for an attendant' do
    attendant = Attendant.new @parking_space_1,@parking_space_2
    coordinator = Minitest::Mock.new
    attendant.add_observer coordinator
    coordinator.expect :update_on_space_full, attendant, [Object]
    coordinator.expect :update_on_space_full, attendant, [Object]
    honda_civic = Object.new
    honda_accord = Object.new
    @parking_space_1.park @honda_city
    @parking_space_2.park honda_civic
    @parking_space_2.park honda_accord
    
    assert coordinator.verify
  end

  it "attendant sends notification to his coordinator when he has no parkings available" do
    attendant = Attendant.new @parking_space_1,@parking_space_2
    coordinator = Coordinator.new attendant
    @parking_space_1.park Object.new
    @parking_space_2.park Object.new
    @parking_space_2.park Object.new 
    refute_includes(coordinator.available_attendants, attendant)
  end

  it "attendant sends notification to his coordinator when he has no parkings available" do
    attendant_1 = Attendant.new @parking_space_1
    attendant_2 = Attendant.new @parking_space_2
    coordinator = Minitest::Mock.new 
    attendant_1.add_observer coordinator
    attendant_2.add_observer coordinator
    coordinator.expect :update_on_space_full, attendant_1, [Attendant]
    @parking_space_1.park Object.new
    assert coordinator.verify
  end

  it "attendant sends notification to his coordinator when he has no parkings available" do
    attendant_1 = Attendant.new @parking_space_1
    attendant_2 = Attendant.new @parking_space_2
    coordinator = Coordinator.new attendant_1, attendant_2
    @parking_space_1.park Object.new
    refute_includes(coordinator.available_attendants,attendant_1)
  end

  it "Ensures an unavailable attendant, when gets available is notified to coordinator" do
    attendant = Attendant.new @parking_space_1
    coordinator = Minitest::Mock.new
    attendant.add_observer coordinator
    coordinator.expect :update_on_space_full, attendant, [Attendant]
    coordinator.expect :update_on_space_open, attendant, [Attendant]
    @parking_space_1.park @honda_city
    @parking_space_1.unpark @honda_city.object_id
    assert coordinator.verify
  end

  it "Ensures an unavailable attendant, when gets available is notified to coordinator" do
    attendant = Attendant.new @parking_space_1
    coordinator = Coordinator.new attendant
    @parking_space_1.park @honda_city
    @parking_space_1.unpark @honda_city.object_id
    assert_includes(coordinator.available_attendants,attendant)
  end

end
