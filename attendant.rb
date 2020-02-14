# frozen_string_literal: true
require_relative 'parking_staff'
class Attendant < ParkingStaff
 
  attr_reader :available_parkings
  def initialize(*parking_spaces)
    super()
    @parking_spaces = parking_spaces
    @direction_strategy = ParkingSpace::WITH_FIRST_AVAILABLE
    @parking_spaces.each { |parking_space| parking_space.add_observer(self) }
    @available_parkings = Array.new @parking_spaces
  end

  def direct(vehicle, another_direction_strategy = nil)
    strategy = another_direction_strategy.nil? ? @direction_strategy : another_direction_strategy
    raise 'Parking Full' if @available_parkings.empty?
    parking_space = strategy.call(@available_parkings)
    parking_space.park(vehicle)
  end

  def update_on_space_open(parking_space)
    @available_parkings << parking_space
    notify_on_space_open self #notify to coordinator
  end

  def update_on_space_full(parking_space)
    @available_parkings.delete parking_space
    notify_on_space_full self #notify to coordinator
  end

end
