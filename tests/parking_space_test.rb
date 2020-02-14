# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../parking_space'
require_relative '../owner'
require_relative '../attendant'
require_relative '../parking_lot'
require_relative '../fbi_agent'

describe ParkingSpace do
  system 'clear'
  before do
    @parking_space_1 = ParkingSpace.new 1
    @parking_space_2 = ParkingSpace.new 2
    @honda_city = Object.new
    @honda_civic = Object.new
  end
  it 'ensures that the car is parked' do
    honda_city_parked = @parking_space_1.park(@honda_city)
    assert_equal(@honda_city.object_id, honda_city_parked)
  end

  it 'ensures that 2 cars are parked' do
    assert_equal(@honda_city.object_id, @parking_space_2.park(@honda_city))
    assert_equal(@honda_civic.object_id, @parking_space_2.park(@honda_civic))
  end

  it 'ensures that only first car is allowed to park' do
    assert_equal(@honda_city.object_id, @parking_space_1.park(@honda_city))
    refute(@parking_space_1.park(@honda_civic))
  end

  it 'ensure that the car is unparked' do
    @parking_space_1.park(@honda_city)
    expected = @parking_space_1.unpark(@honda_city.object_id)
    assert_equal(@honda_city, expected)
  end

  it 'ensures that same car cannot be parked twice before unparking' do
    assert_equal(@honda_city.object_id, @parking_space_2.park(@honda_city))
    refute(@parking_space_2.park(@honda_city))
    assert_equal(@honda_city, @parking_space_2.unpark(@honda_city.object_id))
    assert_equal(@honda_city.object_id, @parking_space_2.park(@honda_city))
  end

  it 'ensures that unparked car cannot be unparked' do
    assert_raises(RuntimeError) { @parking_space_1.unpark @honda_city.object_id }
  end

  it 'gives the number of available slots' do
    parking_space_3 = ParkingSpace.new 10
    parking_space_3.park(Object.new)
    available_slots = parking_space_3.available_slots
    assert_equal(9, available_slots)
  end

  it 'owner is sent notification when the parking space is full' do
    mock = Minitest::Mock.new
    @parking_space_1.add_observer mock
    mock.expect :update_occupancy, @parking_space_1, [Object] #####
    mock.expect :update_on_space_full, @parking_space_1, [Object]
    @parking_space_1.park(@honda_city)
    assert mock.verify
  end

  it 'ensures owner is notified when all parking spaces are full' do
    owner = Owner.new @parking_space_1,@parking_space_2
    @parking_space_1.park Object.new
    @parking_space_2.park Object.new
    @parking_space_2.park Object.new
    assert_equal(0,owner.available_parkings.length)
  end

  it 'ensures owner is notified when parking is free' do
    mock = Minitest::Mock.new
    @parking_space_1.add_observer mock
    mock.expect :update_occupancy, @parking_space_1, [Object] ###
    mock.expect :update_on_space_full, @parking_space_1, [Object]
    @parking_space_1.park(@honda_city)
    mock.expect :update_on_space_open, @parking_space_1, [Object]
    mock.expect :update_occupancy, @parking_space_1, [Object] ###
    @parking_space_1.unpark(@honda_city.object_id)
    mock.verify
  end

  it 'owner is sent notification when the parking space is full' do
    owner = Owner.new @parking_space_1
    @parking_space_1.park(@honda_city)
    assert_equal(0,owner.available_parkings.count)
  end

  it 'owner is sent notification when the parking space is full' do
    owner = Owner.new @parking_space_1,@parking_space_2
    @parking_space_1.park(@honda_city)
    @parking_space_2.park(@honda_city)
    @parking_space_2.park(@honda_civic)
    assert_equal(0,owner.available_parkings.count)
  end

  it 'ensures attendant receives notification when the parking space is full' do
    attendant = Minitest::Mock.new
    @parking_space_1.add_observer attendant
    attendant.expect :update_occupancy,@parking_space_1,[Object]###
    attendant.expect :update_on_space_full,@parking_space_1,[Object]
    @parking_space_1.park(@honda_city)
    assert attendant.verify
  end

  it "ensures after unpark, the car token is added to used_tokens" do
    car_token = @parking_space_2.park @honda_city
    @parking_space_2.unpark car_token
    assert_equal(1,@parking_space_2.used_tokens.count)
  end
  
  it 'ensures sending notification to fbi agent when car is not available in parking lot' do
    fbi_agent = Minitest::Mock.new
    @parking_space_2.add_observer fbi_agent
    fbi_agent.expect :update_occupancy, @parking_space_2, [Object]
    fbi_agent.expect :update_occupancy, @parking_space_2, [Object]
    parking_token = @parking_space_2.park(@honda_city)
    @parking_space_2.unpark(parking_token)
    fbi_agent.expect :update_car_not_available, [@parking_space_2, parking_token],[Object,Object]
    @parking_space_2.unpark(parking_token)
    fbi_agent.verify
  end

  it 'ensures fbi is notified when car is not available in parking' do
    fbi_agent = FBIAgent.new @parking_space_2
    @parking_space_2.park @honda_city
    @parking_space_2.unpark(@honda_city.object_id)
    @parking_space_2.unpark(@honda_city.object_id)
    assert_includes(fbi_agent.reported_vehicles,@honda_city.object_id)
  end

  it 'ensures fbi is not notified if an unparked car was tried to be unparked' do
    fbi_agent = FBIAgent.new @parking_space_2
    assert_raises(RuntimeError) { @parking_space_2.unpark(@honda_city.object_id) }
    refute_includes(fbi_agent.reported_vehicles,@honda_city.object_id)
  end

  it 'ensures fbi is not notified if an unparked car was tried to be unparked' do
    fbi_agent = Minitest::Mock.new
    @parking_space_2.add_observer fbi_agent
    parking_token = @honda_city.object_id
    fbi_agent.expect :update_car_not_available, [parking_token, @parking_space_2], [Object,ParkingSpace]
    assert_raises(RuntimeError) do
       @parking_space_2.unpark(@honda_city.object_id) 
       refute fbi_agent.verify
    end
  end

  it 'Parkinglot is notified when all parking spaces are full ' do
    parking_lot = ParkingLot.new @parking_space_1,@parking_space_2
    honda_accord = Object.new
    @parking_space_1.park(@honda_city)
    @parking_space_2.park(@honda_civic)
    @parking_space_2.park(honda_accord)
    assert_equal(0,parking_lot.available_parking_spaces.count)
  end
  
  it 'Parkinglot is notified when all parking spaces are full ' do
    mock = Minitest::Mock.new
    @parking_space_1.add_observer mock
    @parking_space_2.add_observer mock
    mock.expect :update_occupancy, @parking_space_1, [ParkingSpace]
    mock.expect :update_on_space_full, @parking_space_1, [ParkingSpace]
    mock.expect :update_occupancy, @parking_space_2, [ParkingSpace]
    mock.expect :update_occupancy, @parking_space_2, [ParkingSpace]
    mock.expect :update_on_space_full, @parking_space_2, [ParkingSpace]
    honda_accord = Object.new
    @parking_space_1.park(@honda_city)
    @parking_space_2.park(@honda_civic)
    @parking_space_2.park(honda_accord)

    assert mock.verify
  end 

  it 'Parkinglot is notified when its parking space gets open ' do
    mock = Minitest::Mock.new
    @parking_space_1.add_observer mock
    @parking_space_2.add_observer mock
    mock.expect :update_occupancy, @parking_space_1, [ParkingSpace]
    mock.expect :update_on_space_full, @parking_space_1, [ParkingSpace]
    mock.expect :update_occupancy, @parking_space_2, [ParkingSpace]
    mock.expect :update_occupancy, @parking_space_2, [ParkingSpace]
    mock.expect :update_on_space_full, @parking_space_2, [ParkingSpace]
    mock.expect :update_occupancy, @parking_space_1, [ParkingSpace]
    mock.expect :update_on_space_open, @parking_space_1, [ParkingSpace]
    honda_accord = Object.new
    @parking_space_1.park(@honda_city)
    @parking_space_2.park(@honda_civic)
    @parking_space_2.park(honda_accord)
    @parking_space_1.unpark(@honda_city.object_id)

    assert mock.verify
  end 

  it 'Parkinglot is notified when a parking space gets open ' do
    parking_lot = ParkingLot.new @parking_space_1,@parking_space_2
    honda_accord = Object.new
    @parking_space_1.park(@honda_city)
    @parking_space_2.park(honda_accord)
    @parking_space_2.park(@honda_city)
    @parking_space_2.unpark(@honda_city.object_id)
    assert_includes(parking_lot.available_parking_spaces,@parking_space_2)
  end 

end