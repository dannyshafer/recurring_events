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
        if is_not_holiday(@event.start_date) && is_weekday(@event.start_date)
          DeliveryDate.create(delivery: @event.start_date, event_id: @event.id)
          future_deliveries(@event.start_date, @event.occurence_frequency)
        else
          #adjust the date by one and make delivery date
        end
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
        if is_not_holiday(@event.start_date) && is_weekday(@event.start_date)
          DeliveryDate.create(delivery: @event.start_date, event_id: @event.id)
          future_deliveries(@event.start_date, @event.occurence_frequency)
        else
          #adjust the date by one and make delivery date
        end
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
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:name, :start_date, :occurence_frequency)
    end

    def is_not_holiday(date)
      if date != "holiday" #come back to this later and do a real holiday check
        true
      else
        #returns a date that is not a holiday
        false
      end
    end

    def is_weekday(date)
      if !date.sunday? && !date.saturday? 
        true
      else
        #returns a date that is a weekday
        false
      end
    end

    def future_deliveries(date, occurence_frequency)
      counter = 1
      4.times do
        @date = date.to_s.split("-").map(&:to_i)
        @date[1] = (@date[1] + occurence_frequency*counter)
        while @date[1] > 12
          @date[1] -= 12
          @date[0] += 1
        end
        @date = @date.map(&:to_s).join("-")
        #check if its a holiday or weekend
        DeliveryDate.create(delivery: @date, event_id: @event.id)
        counter += 1
      end
    end
  end
