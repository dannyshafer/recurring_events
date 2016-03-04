class EventsController < ApplicationController
  require 'date'
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  # GET /events
  # GET /events.json
  def index
    @events = Event.all
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @delivery_dates = @event.delivery_dates.compact
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)
    @event.day_of_month = @event.start_date.to_s.split("-").last
    respond_to do |format|
      if @event.save
        @date = is_non_holiday_weekday(@event.start_date)
        DeliveryDate.create(delivery: @event.start_date, event_id: @event.id)
        future_deliveries(@event.start_date, @event.occurence_frequency)
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        @event.delivery_dates.destroy_all
        @date = is_non_holiday_weekday(@event.start_date)
        DeliveryDate.create(delivery: @event.start_date, event_id: @event.id)
        future_deliveries(@event.start_date, @event.occurence_frequency)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_event
      @event = Event.find(params[:id])
    end

    def event_params
      params.require(:event).permit(:name, :start_date, :occurence_frequency)
    end

    def is_non_holiday_weekday(date)
      holidays = []
      Holidays.on(date.to_date, :us).each do |holiday|
        holidays << holiday[:name]
      end
      if !date.to_date.sunday? && !date.to_date.saturday? && !(holidays.any? { |holiday| ["New Year's Day","Martin Luther King, Jr. Day","Presidents' Day","Memorial Day","Independence Day","Labor Day","Columbus Day","Veterans' Day","Thanksgiving Day","Christmas Day"].include?(holiday) } )
        return date
      else
        @date = date.to_s.split("-").map(&:to_i)
        @date[2] -= 1
        @date = @date.map(&:to_s).join("-")
        is_non_holiday_weekday(@date)
      end
    end

    def future_deliveries(date, occurence_frequency)
      counter = 1
      4.times do
        @date = is_non_holiday_weekday(date)
        @date = @date.to_s.split("-").map(&:to_i)
        @date[1] = (@date[1] + occurence_frequency*counter)
        while @date[1] > 12
          @date[1] -= 12
          @date[0] += 1
        end
        @date = @date.map(&:to_s).join("-")
        if @date == is_non_holiday_weekday(@date) #this check ensures that the new date N months in the future is not a weekend or holiday
          DeliveryDate.create(delivery: @date, event_id: @event.id)
          counter += 1
        else
          @date = is_non_holiday_weekday(@date)
          DeliveryDate.create(delivery: @date, event_id: @event.id)
          counter += 1
        end
      end
    end
  end
