class WorkHoursController < ApplicationController
  before_action :authenticate_user!
  before_action :set_work_hour, only: [:show, :edit, :update, :destroy]

  # GET /work_hours
  # GET /work_hours.json
  def index
    @work_hours = WorkHour.search(search_params)

    @project_options = []
    projects = WorkHour.select(:project).group(:project).order(:project)
    @project_options = projects.map { |p|
      [p.project, p.project]
    }

    years = WorkHour.select(:date).group(:date).order(:date).map { |item| item.date.year.to_i }.uniq
    @year_options = years.map { |year|
      [year, year]
    }

    @month_options = (1..12).to_a.map { |month| [month, month] }

    total = 0
    @chart_labels = []
    @chart_datas = []

    @work_hours.each do |work_hour|
      total += work_hour.hour
      @chart_labels.push(work_hour.date.strftime("%Y-%m-%d"))
      @chart_datas.push(work_hour.hour)
    end
    @total = total
  end

  # GET /work_hours/1
  # GET /work_hours/1.json
  def show
  end

  # GET /work_hours/new
  def new
    @work_hour = WorkHour.new
  end

  # GET /work_hours/1/edit
  def edit
  end

  # POST /work_hours
  # POST /work_hours.json
  def create
    @work_hour = WorkHour.new(work_hour_params)

    respond_to do |format|
      if @work_hour.save
        format.html { redirect_to @work_hour, notice: 'Work hour was successfully created.' }
        format.json { render :show, status: :created, location: @work_hour }
      else
        format.html { render :new }
        format.json { render json: @work_hour.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /work_hours/1
  # PATCH/PUT /work_hours/1.json
  def update
    respond_to do |format|
      if @work_hour.update(work_hour_params)
        format.html { redirect_to @work_hour, notice: 'Work hour was successfully updated.' }
        format.json { render :show, status: :ok, location: @work_hour }
      else
        format.html { render :edit }
        format.json { render json: @work_hour.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /work_hours/1
  # DELETE /work_hours/1.json
  def destroy
    @work_hour.destroy
    respond_to do |format|
      format.html { redirect_to work_hours_url, notice: 'Work hour was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_work_hour
      @work_hour = WorkHour.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def work_hour_params
      params.require(:work_hour).permit(:project, :date, :hour)
    end

    def search_params
      params.permit(:project, :year, :month, :page)
    end
end
