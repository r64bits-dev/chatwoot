class Public::Api::V1::Portals::ArticlesController < Public::Api::V1::Portals::BaseController
  before_action :ensure_custom_domain_request, only: [:show, :index]
  before_action :portal
  before_action :set_category, except: [:index, :show]
  before_action :set_article, only: [:show]
  before_action :check_permissions, only: [:show, :index]
  layout 'portal'

  def index
    @articles = @portal.articles
    @articles = @articles.search(list_params) if list_params.present?
    order_by_sort_param
    @articles.page(list_params[:page]) if list_params[:page].present?
  end

  def show; end

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
    render 'public/api/v1/portals/articles/403', status: :forbidden unless article_access?
  end

  def article_access?
    @article.visibility_public? || article_private_access?
  end

  def article_private_access?
    @article.visibility_private? && Current.user && @article.teams.include?(Current.user.account.team)
  end
end
