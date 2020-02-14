#frozen_string_literal: true

class Owner
    include Observer
    attr_reader :available_parkings, :observers
    def initialize(*parking_spaces)
        @observers = []
        @parking_spaces = parking_spaces
        @parking_spaces.each { |parking_space| parking_space.add_observer(self) }
        @available_parkings = Array.new @parking_spaces
    end

    def update_on_space_full(parking_space)
        @available_parkings.delete parking_space
    end

    def update_on_space_open(parking_space)
        @available_parkings << parking_space
    end

end
