class ItemsController < ApplicationController
  before_action :set_item, only: %i[ show edit update destroy ]

  # GET /items or /items.json
  def index
    @q = params[:q].to_s.strip
    @items = Item.all
    if @q.present?
      term = "%#{@q.downcase}%"
      @items = @items.where(
        "LOWER(name) LIKE :t OR LOWER(short_effect) LIKE :t OR LOWER(flavor_text) LIKE :t",
        t: term
      )
    end
    @items = @items.order(:name)
  end

  # GET /items/1 or /items/1.json
  def show
  end

  # GET /items/new
  def new
    @item = Item.new
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items or /items.json
  def create
    @item = Item.new(item_params)

    respond_to do |format|
      if @item.save
        format.html { redirect_to @item, notice: "Item was successfully created." }
        format.json { render :show, status: :created, location: @item }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /items/1 or /items/1.json
  def update
    respond_to do |format|
      if @item.update(item_params)
        format.html { redirect_to @item, notice: "Item was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @item }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1 or /items/1.json
  def destroy
    @item.destroy!

    respond_to do |format|
      format.html { redirect_to items_path, notice: "Item was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = Item.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def item_params
      permitted = params.expect(item: [ :name, :short_effect, :flavor_text, :sprite, :url, :generations ])

      # `generations` is serialized as a JSON Hash on the model. The form sends
      # it as a JSON string, so parse it here (or fall back to {} on bad input).
      if permitted[:generations].is_a?(String)
        raw = permitted[:generations].strip
        permitted[:generations] =
          if raw.empty?
            {}
          else
            begin
              parsed = JSON.parse(raw)
              parsed.is_a?(Hash) ? parsed : { "value" => parsed }
            rescue JSON::ParserError
              { "raw" => raw }
            end
          end
      end

      permitted
    end
end
