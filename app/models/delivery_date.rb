class DeliveryDate < ActiveRecord::Base
	belongs_to :event
    require 'date'

    private 

    def is_not_holiday(date)
    	if !holiday
            true
        else
            false
        end
    end
	def is_weekday(date)
        if !date.sunday? && !date.saturday? 
            true
        else
            false
        end
    end

end
