module Maintenances
  class MarkDonesController < ApplicationController
    include RequiresVehicle
    include RequiresOwnedMaintenance
    include MarkDoneResponse

    def new
      render Maintenances::MarkDoneFormView.new(request: Maintenances::MarkDoneRequest.new(maintenance: @maintenance))
    end

    def update
      permitted = params.require(:mark_done).permit(:done_km, :done_on, companion_ids: [])
      request = Maintenances::MarkDoneRequest.new(maintenance: @maintenance, **permitted.to_h.symbolize_keys)

      respond_with_mark_done(Maintenances::MarkDone.call(request: request))
    end

    def destroy
      restore = params.fetch(:restore, {}).permit!.to_h

      respond_with_undo(Maintenances::UndoMarkDone.call(vehicle: @maintenance.vehicle, restore: restore))
    end
  end
end
