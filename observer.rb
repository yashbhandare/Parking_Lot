# frozen_string_literal: true
module Observer

  def add_observer(observer)
    @observers << observer
  end

  def delete_observer(observer)
    @observer.delete(observer)
  end

  def notify_on_space_full(observable)
    observers.each do |observer|
      observer.update_on_space_full(observable)
    end
  end

  def notify_on_space_open(parking_space)
    observers.each do |observer|
      observer.update_on_space_open(parking_space)
    end
  end

  def notify_car_not_available(parking_space, parking_token)
    observers.each do |observer|
      observer.update_car_not_available(parking_space,parking_token)
    end
  end

  def notify_occupancy(parking_space)
    observers.each do |observer|
      observer.update_occupancy(parking_space)
    end
  end
  
  def notify_on_80_percent_occupancy parking_lot
    @observers.each do |observer|
        observer.update_on_80_percent_occupancy(parking_lot)
    end
  end

  protected
  def update_occupancy(parking_space)
    #parking_lot
  end

  def update_on_space_full(observable)
    #attendant(parking_space), owner(parking_space || parking_lot), coordinator(attendant)
  end

  def update_on_space_open(observable)
    #attendant(parking_space), owner(parking_space,parking_lot), coordinator(attendant)
  end

  def update_on_80_percent_occupancy(parking_lot)
    #traffic_police_dept
  end 

  def update_car_not_available(parking_space,parking_token)
    #fbi_agent
  end

end
