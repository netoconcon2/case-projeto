class Admin::SubscriptionsController < ApplicationController
  before_action :authorize_admin

  def index
    @page = params[:page] || 1
    per_page = 10
    @subscriptions_all = PagarMe::Subscription.all({ count: per_page, page: @page.to_i })
    @subscriptions = Kaminari.paginate_array(@subscriptions_all, total_count: helpers.total_subscriptions).page(@page).per(per_page)
  end

  def show
  end

  def edit
    subscription_id = params[:subscription_id].to_i
    subscription = PagarMe::Subscription.find_by_id(subscription_id)
  end

  def update
    subscription_id = params[:subscription_id].to_i
    subscription = PagarMe::Subscription.find_by_id(subscription_id)
    subscription.plan_id = params["plan_id"]
    subscription.save
    redirect_to admin_subscription_path(subscription_id)
  end

  private

  def check_admin
    rediret_to root_path unless current_user.admin?
  end
end
