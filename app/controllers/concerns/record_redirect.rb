module RecordRedirect
  extend ActiveSupport::Concern

  private

  def redirect_to_new_record(type)
    redirect_to new_record_path(type: type, context: permitted_context)
  end

  def permitted_context
    return unless params[:context].respond_to?(:permit)

    params[:context].permit(:year, :month)
  end
end
