class AppLogsController < ApplicationController
  before_action :set_app_log, only: %i[ show edit update destroy ]

  # GET /app_logs or /app_logs.json
  def index
    @app_logs = AppLog.all
  end

  # GET /app_logs/1 or /app_logs/1.json
  def show
  end

  # GET /app_logs/new
  def new
    @app_log = AppLog.new
  end

  # GET /app_logs/1/edit
  def edit
  end

  # POST /app_logs or /app_logs.json
  def create
    @app_log = AppLog.new(app_log_params)

    respond_to do |format|
      if @app_log.save
        format.html { redirect_to @app_log, notice: "App log was successfully created." }
        format.json { render :show, status: :created, location: @app_log }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @app_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /app_logs/1 or /app_logs/1.json
  def update
    respond_to do |format|
      if @app_log.update(app_log_params)
        format.html { redirect_to @app_log, notice: "App log was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @app_log }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @app_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /app_logs/1 or /app_logs/1.json
  def destroy
    @app_log.destroy!

    respond_to do |format|
      format.html { redirect_to app_logs_path, notice: "App log was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_app_log
      @app_log = AppLog.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def app_log_params
      params.expect(app_log: [ :level, :message, :ip_address, :user_id ])
    end
end
