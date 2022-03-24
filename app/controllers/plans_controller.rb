class PlansController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index]
  before_action :set_company, except: %i[index]

  def index
    @plans = policy_scope(Plan)
  end

  def subscribe
    # tela de checkout
    @plan = Plan.find(params[:plan_id])
    authorize current_user, :validated?
  end

  def subscription
    # subscription process
    @plan = Plan.find(params[:plan_id])
    order = params["order"]

    authorize current_user, :validated?

    pagarme_subscription(order)
  end

  def pagarme_subscription(order)
    if order[:card]
      payment_type = "credit_card"
      card = create_credit_card(order[:card])
      document = order[:card][:document].gsub("-", "").gsub(".", "")
    elsif params[:boleto]
      payment_type = "boleto"
      document = order["document_boleto"].gsub("-", "").gsub(".", "")
      card = nil
    end

    plan = Plan.find(params["plan_id"])
    pagarme_plan = PagarMe::Plan.find_by_id(plan.pagarme_id)

    company = current_user.company

    begin
      PagarMe.api_key = ENV['PAGARME_API_KEY']
      subscription = PagarMe::Subscription.new(
        {
          api_key: ENV['PAGARME_API_KEY'],
          payment_method: payment_type,
          card_id: card.id,
          postback_url: "#{root_url}api/v1/companies/#{company.id}/postback",
          customer: {
            name: "#{order[:first_name]} #{order[:last_name]}",
            document_number: document,
            email: order[:email],
            address: {
              street: order[:street],
              neighborhood: order[:neighborhood],
              zipcode: order[:zipcode].gsub("-", ""),
              street_number: order[:number].to_i
            },
            phone: {
              ddd: order["phone"].first(4).gsub("(", "").gsub(")", ""),
              number: order["phone"][5..-1].gsub("-", "")
            }
          }
        }
      )

      subscription.plan = pagarme_plan

      if subscription.create
        company.complete!
        company.plan_status = subscription.status
        company.update_available_words(plan.words)
        company.plan = plan
        company.pagarme_subscription_id = subscription.id
        company.save
      end
    rescue
      migue_genial = true
    end

    if migue_genial
      render :subscribe
      flash[:notice] = t('notice.error_subscribe')
    else
      redirect_to root_path
      flash[:notice] = t('notice.sucessfull_subscribe')
    end
  end

  def cancel_plan
    @company = Company.find(params[:company_id])
    subscription = PagarMe::Subscription.find_by_id(@company.pagarme_subscription_id)

    authorize @company, :special_access?

    begin
      subscription.cancel
    rescue
      error = true
    end

    if error
      redirect_to plans_path
      flash[:alert] = t('alert_error_cancel')
    else
      @company.available_words = 0
      @company.plan = nil
      @company.status = 1
      @company.pagarme_subscription_id = nil
      @company.save
      redirect_to current_user.pj? ? root_path : company_path
    end
  end

  private

  def set_company
    @company = current_user.company
  end

  def create_credit_card(card)
    # to save user credit card on pagarme and recieve a card hash
    # create a credit card on pagarme
    pagarme_card = PagarMe::Card.new({
      card_number: card[:number].gsub(" ", ""),
      card_holder_name: card[:name],
      card_expiration_month: card[:expiration_month],
      card_expiration_year: card[:expiration_year],
      card_cvv: card[:cvv]
    })

    begin
      pagarme_card.create
    rescue
    end
  end
end
