class SuperAdmin::ProductsController < SuperAdmin::ApplicationController
  def update
    if parse_details.present?
      required_keys = %w[number_of_conversations number_of_agents extra_conversation_cost extra_agent_cost]

      missing_keys = required_keys.select { |key| @parsed_details[key].blank? }
      if missing_keys.any?
        flash[:error] = I18n.t('administrate.form.required_keys', errors: missing_keys.join(', '))
        return redirect_to edit_super_admin_product_path(requested_resource)
      end

      @product = requested_resource
      @product.details = parse_details
      @product.save!

      params[:product].delete(:details)
    end

    super
  end

  private

  def parse_details
    return @passed_details if @passed_details

    if params[:product][:details]
      details = params[:product][:details]
      @parsed_details = JSON.parse(details)
      @parsed_details
    end
  rescue JSON::ParserError
    nil
  end
end
