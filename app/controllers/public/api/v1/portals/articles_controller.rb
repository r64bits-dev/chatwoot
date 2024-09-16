class Public::Api::V1::Portals::ArticlesController < Public::Api::V1::Portals::BaseController
  before_action :authenticate_user!, only: [:content]

  before_action :ensure_custom_domain_request, only: [:show, :index, :content]
  before_action :portal
  before_action :set_category, except: [:index, :show, :content]
  before_action :set_article, only: [:show, :content]
  before_action :check_permissions, only: [:show, :index]
  before_action :check_article_access, only: [:content]

  layout 'portal'

  def index
    @articles = @portal.articles
    @articles = @articles.search(list_params) if list_params.present?
    order_by_sort_param
    @articles.page(list_params[:page]) if list_params[:page].present?
  end

  def show; end

  def content; end

  private

  def order_by_sort_param
    @articles = if list_params[:sort].present? && list_params[:sort] == 'views'
                  @articles.order_by_views
                else
                  @articles.order_by_position
                end
  end

  def set_article
    @article = @portal.articles.find_by(slug: permitted_params[:article_slug])
    @article.increment_view_count
    @parsed_content = render_article_content(@article.content)
  end

  def set_category
    return if permitted_params[:category_slug].blank?

    @category = @portal.categories.find_by!(
      slug: permitted_params[:category_slug],
      locale: permitted_params[:locale]
    )
  end

  def list_params
    params.permit(:query, :locale, :sort, :status)
  end

  def permitted_params
    params.permit(:slug, :category_slug, :locale, :id, :article_slug)
  end

  def render_article_content(content)
    ChatwootMarkdownRenderer.new(content).render_article
  end

  def check_permissions
    render 'public/api/v1/portals/articles/private/show' unless article_access?
  end

  def article_access?
    @article.visibility_public? || article_private_access?
  end

  def article_private_access?
    return false unless @article.visibility_private?
    return false unless current_user

    @article.teams.any? { |team| current_user.teams.include?(team) }
  end

  def check_article_access
    return if article_private_access?

    render json: { error: 'You are not authorized to view this content' }, status: :forbidden
  end
end
