
class IronWarbler::OptionWatchesController < ApplicationController
  before_action :set_option_watch, only: %i[ show edit update destroy ]

  def index
    @option_watches = Iwa::OptionWatch.all
  end

  def show
  end

  def new
    @option_watch = Iwa::OptionWatch.new
  end

  def edit
  end

  def create
    @option_watch = Iwa::OptionWatch.new(option_watch_params)

    respond_to do |format|
      if @option_watch.save
        format.html { redirect_to option_watch_url(@option_watch), notice: "Option watch was successfully created." }
        format.json { render :show, status: :created, location: @option_watch }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @option_watch.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @option_watch.update(option_watch_params)
        format.html { redirect_to option_watch_url(@option_watch), notice: "Option watch was successfully updated." }
        format.json { render :show, status: :ok, location: @option_watch }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @option_watch.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @option_watch.destroy

    respond_to do |format|
      format.html { redirect_to option_watches_url, notice: "Option watch was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  #
  # private
  #
  private

  def set_option_watch
    @option_watch = Iwa::OptionWatch.find(params[:id])
  end

  def option_watch_params
    params[:iwa_option_watch].permit(%i|
      ticker symbol description strike
      contractType date direction notificationType
      email phone profile_id
    |)
  end

end
