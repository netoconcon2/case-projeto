module PagarMeHelper
  def subscription_statuses(status)
    case status
    when "paid"
      t('.paid')
    when "waiting_payment"
      t('.waiting_payment')
    end
  end

  def total_subscriptions
    total_count = 0
    page = 1
    while PagarMe::Subscription.all({ count: 1000, page: page }) != [] do
      total_count += PagarMe::Subscription.all({ count: 1000, page: page }).size
      page += 1
    end
    total_count
  end
end
