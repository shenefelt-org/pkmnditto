class DamageRelationsController < ApplicationController
  before_action :set_damage_relation, only: %i[ show edit update destroy ]

  # GET /damage_relations or /damage_relations.json
  def index
    @damage_relations = DamageRelation.all
  end

  # GET /damage_relations/1 or /damage_relations/1.json
  def show
  end

  # GET /damage_relations/new
  def new
    @damage_relation = DamageRelation.new
  end

  # GET /damage_relations/1/edit
  def edit
  end

  # POST /damage_relations or /damage_relations.json
  def create
    @damage_relation = DamageRelation.new(damage_relation_params)

    respond_to do |format|
      if @damage_relation.save
        format.html { redirect_to @damage_relation, notice: "Damage relation was successfully created." }
        format.json { render :show, status: :created, location: @damage_relation }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @damage_relation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /damage_relations/1 or /damage_relations/1.json
  def update
    respond_to do |format|
      if @damage_relation.update(damage_relation_params)
        format.html { redirect_to @damage_relation, notice: "Damage relation was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @damage_relation }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @damage_relation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /damage_relations/1 or /damage_relations/1.json
  def destroy
    @damage_relation.destroy!

    respond_to do |format|
      format.html { redirect_to damage_relations_path, notice: "Damage relation was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_damage_relation
      @damage_relation = DamageRelation.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def damage_relation_params
      params.fetch(:damage_relation, {})
    end
end
