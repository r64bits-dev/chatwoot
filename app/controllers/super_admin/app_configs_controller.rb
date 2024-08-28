require 'mini_magick'

class SuperAdmin::AppConfigsController < SuperAdmin::ApplicationController
  before_action :set_config
  before_action :allowed_configs

  IMMUTABLE_KEYS = %w[FAVICON FAVICON_BADGE].freeze

  def show
    @app_config = InstallationConfig.where(name: @allowed_configs)
                                    .pluck(:name, :serialized_value)
                                    .to_h
                                    .transform_values { |serialized_value| serialized_value['value'] }
  end

  def create
    params['app_config'].each do |key, value|
      next unless @allowed_configs.include?(key)

      if IMMUTABLE_KEYS.include?(key)
        handle_favicon(value, key) if key == 'FAVICON'
        handle_favicon_badge(value, key) if key == 'FAVICON_BADGE'
      else
        i = InstallationConfig.where(name: key).first_or_create(value: value, locked: false)
        i.value = value
        i.save!
      end
    end
    redirect_to super_admin_settings_path, notice: I18n.t('global_config.update_success')
  end

  private

  def set_config
    @config = params[:config]
  end

  def allowed_configs
    @allowed_configs = %w[FB_APP_ID FB_VERIFY_TOKEN FB_APP_SECRET FAVICON FAVICON_BADGE]
  end

  def handle_favicon(favicon_url, key)
    sizes = [16, 32, 96, 512]
    convert_and_save_favicon(favicon_url, sizes, key)
  end

  def handle_favicon_badge(favicon_url, key)
    badge_sizes = [16, 32, 96]
    convert_and_save_favicon(favicon_url, badge_sizes, key, badge: true)
  end

  def convert_and_save_favicon(favicon_url, sizes, key, badge: false)
    sizes.each do |size|
      url = save_favicon(favicon_url, size, badge: badge)
      i = InstallationConfig.where(name: "#{key}_#{size}").first_or_create(value: url, locked: false)
      i.value = url
      i.save!
      Rails.logger.info "Favicon saved to: #{url}"
    end
  rescue StandardError => e
    Rails.logger.error "Failed to convert and save favicon: #{e.message}"
  end

  def save_favicon(favicon_url, size, badge: false)
    image = MiniMagick::Image.open(favicon_url)
    image.resize "#{size}x#{size}"

    temp_path = Rails.root.join('tmp', "favicon_temp_#{size}.png")
    image.write temp_path

    response = Cloudinary::Uploader.upload(temp_path, folder: 'favicons', public_id: "favicon#{'-badge' if badge}-#{size}x#{size}")

    # Excluir o arquivo temporário
    FileUtils.rm_f(temp_path)

    response['secure_url']
  end
end

SuperAdmin::AppConfigsController.prepend_mod_with('SuperAdmin::AppConfigsController')
