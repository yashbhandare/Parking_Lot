# frozen_string_literal: true

require_relative 'observer'

class ParkingSpace
  attr_accessor :observers
  attr_reader :slots, :vehicles, :occupied, :used_tokens
  include Observer
  WITH_MORE_SLOTS = proc do |parking_spaces|
    champion = parking_spaces[0]
    parking_spaces.each do |challenger|
      if challenger.available_slots > champion.available_slots
        champion = challenger
      end
    end
    champion
  end

  WITH_LIMITED_SLOTS = proc do |parking_spaces|
    champion = parking_spaces[0]
    parking_spaces.each do |challenger|
      if challenger.available_slots < champion.available_slots
        champion = challenger
      end
    end
    champion
  end

  WITH_FIRST_AVAILABLE = proc do |parking_spaces|
    champion = parking_spaces[0]
    parking_spaces.each do |challenger|
      unless challenger.parking_full?
        champion = challenger
        break
      end
    end
    champion
  end

  def initialize(slots)
    @observers = []
    @slots = slots
    @occupied = 0
    @vehicles = {}
    @used_tokens = []
    @vehicle_color = {}
    @vehicle_time = {}
  end

  def park(vehicle, parked_time = Time.now, vehicle_color = nil)
    return false if @vehicles.values.include?(vehicle) || parking_full?
    @occupied += 1
    @vehicles[vehicle.object_id] = vehicle
    notify_on_space_full(self) if parking_full?
    notify_occupancy(self)
    #notify_blue_vehicle_parked(vehicle.object_id,self,vehicle_color) 
    @vehicle_color.merge! vehicle.object_id => vehicle_color
    @vehicle_time.merge! vehicle.object_id => parked_time
    vehicle.object_id
  end

  def unpark(parking_token)
    if !@vehicles.keys.include?(parking_token) && @used_tokens.include?(parking_token)
      notify_car_not_available(self,parking_token)
      return false 
    end
    raise "Invalid Parking Token!" if !@vehicles.keys.include?(parking_token)
    @occupied -= 1
    notify_on_space_open(self) if parking_open?
    notify_occupancy(self)
    @used_tokens << parking_token
    @vehicles.delete(parking_token)
  end

  def available_slots
    @slots - @occupied
  end

  def parking_full?
    @slots == @occupied
  end

  def find_specific_colored_vehicles color
    specified_colored_vehicles = []
    @vehicle_color.each do |key, value|
      specified_colored_vehicles << key if value == color
    end
    specified_colored_vehicles
  end

  def find_parked_between from_time, to_time
    vehicles_parked_between = []
    @vehicle_time.each do |key, value|
      vehicles_parked_between << key if value > from_time and value < to_time
    end
    vehicles_parked_between
  end

  private

  def parking_open?
    @occupied == (@slots - 1)
  end
end
