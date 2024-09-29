class SuperAdmin::ProductsController < SuperAdmin::ApplicationController
  def update
    if params[:product][:details].present?
      validate_details!(params[:product][:details])
      params[:product].delete(:details)
    end

    super
  end

  private

  def validate_details!(details_param)
    json_details = JSON.parse(details_param)
    required_keys = %w[number_of_conversations number_of_agents extra_conversation_cost extra_agent_cost]

    missing_keys = required_keys.select { |key| json_details[key].blank? }
    if missing_keys.any?
      flash[:error] = translate_with_resource('update.error')
      nil
    else
      @product = requested_resource
      @product.details = json_details
      @product.save!
    end
  rescue JSON::ParserError
    flash[:error] = translate_with_resource('update.error')
    nil
  end
end
