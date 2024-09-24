class SuperAdmin::ProductsController < SuperAdmin::ApplicationController
  def destroy
    if requested_resource.destroy
      flash[:notice] = translate_with_resource('destroy.success')
    else
      flash[:error] = requested_resource.errors.full_messages.join('<br/>')
    end
    redirect_back(fallback_location: [namespace, requested_resource])
  end
end
