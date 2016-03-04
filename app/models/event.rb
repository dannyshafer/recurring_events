class Event < ActiveRecord::Base
	has_many :delivery_dates
end
