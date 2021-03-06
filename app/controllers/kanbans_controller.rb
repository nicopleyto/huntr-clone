class KanbansController < ApplicationController
  before_action :set_kanban, only: [:edit, :update, :destroy, :sort]

  def index
    @kanbans = current_user.kanbans
    @kanban = !params[:kanban_id].nil? ? current_user.kanbans.find(params[:kanban_id]) : current_user.kanbans.first
  end

  def new
    @kanban = current_user.kanbans.build
  end

  def edit
  end

  def create
    @kanban = current_user.kanbans.build(kanban_params)
    
    if @kanban.save
      @kanban.create_default_columns
      redirect_to kanbans_path(kanban_id: @kanban), notice: 'Kanban was successfully created.'
    else  
      render :new
    end
  end

  def update
    if @kanban.update(kanban_params)
      redirect_to kanbans_path(kanban_id: @kanban), notice: 'Kanban was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @kanban.destroy
    redirect_to kanbans_path, notice: 'Kanban was successfully destroyed.'
  end

  def sort
    # Get the new col sort
    sorted_cols = JSON.parse(kanban_params["kanbanIds"])["columns"]
    sorted_cols.each do |col|
      # Look at each of its cards
      col["itemIds"].each do |card_id|
        # Find the card if in the DB and 
        # update its column and position within the column
        if Card.find(card_id).update(
          kanban_column: KanbanColumn.find(col["id"]),
          position: col["itemIds"].find_index(card_id)
        )
          Card.find(card_id).create_activities_upon_drag(@kanban, col["id"])
        end
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_kanban
      @kanban = current_user.kanbans.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def kanban_params
      params.require(:kanban).permit(:name, :kanbanIds)
    end
end