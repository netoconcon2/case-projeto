class PackagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index]

  def index
    @packages = policy_scope(Package)
  end

  def checkout
    # tela de checkout
    @package = Package.find(params[:package_id])

    authorize current_user, :validated?
  end

  def transaction
    # transaction process
    order = params["order"]
    authorize current_user, :validated?

    pagarme_transaction(order)
  end

  def pagarme_transaction(order)
    company = current_user.company

    @package = Package.find(params["package_id"].to_i)
    if params[:card]
      begin
        card = create_credit_card(order)
        payment_type = "credit_card"
        document = order[:card][:document].gsub("-","").gsub(".","")
      rescue
      end
    elsif params[:boleto]
      payment_type = "boleto"
      document = order["document_boleto"].gsub("-","").gsub(".","")
    end

    unless document.nil?
      if document.size <= 11
        doc_type = "cpf"
      else
        doc_type = "cnpj"
      end
    end

    pagarme_transaction  = PagarMe::Transaction.new({
      amount: @package.price_cents.to_i,
      payment_method: payment_type,
      postback_url: "#{root_url}api/v1/companies/#{company.id}/transaction",
      async: true,
      customer: {
        external_id: "#{company.id}",
        name: order["first_name"] + " " + order["last_name"],
        type: "individual",
        country: order["country"],
        email: order["email"],
        documents: [
          {
            type: doc_type,
            number: document
          }
        ],
        phone_numbers: [ "+55" + order["phone"].gsub("(","").gsub(")","").gsub(" ", "").gsub("-", "")],
      },
      billing: {
        name: order["first_name"] + " " + order["last_name"],
        address: {
          country: "br",
          state: order["state"],
          city: order["city"],
          neighborhood: order["neighborhood"],
          street: order["street"],
          street_number: order["number"],
          zipcode: order["zipcode"].gsub("-", "")
        },
      },
      # shipping: {
      #   name: "Neo Reeves",
      #   fee: 1000,
      #   delivery_date: "2000-12-21",
      #   expedited: true,
      #   address: {
      #     country: "br",
      #     state: "sp",
      #     city: "Cotia",
      #     neighborhood: "Rio Cotia",
      #     street: "Rua Matrix",
      #     street_number: "9999",
      #     zipcode: "06714360"
      #   }
      # },
      items: [
        {
          id: @package.id.to_s,
          title: @package.name,
          unit_price: @package.price.to_i,
          quantity: 1,
          tangible: false
        }
      ]
    })

    begin
      pagarme_transaction[:card_id] = card.id unless payment_type == "boleto"

      pagarme_transaction.charge
      transaction = Transaction.create(status: "ordered",
                      pagarme_id: pagarme_transaction.id,
                      company: current_user.company
                      )

    rescue
      migue_genial = true
    end



    if migue_genial
      render :checkout
      flash[:alert] = t('notice.error_transaction')
    else
      redirect_to root_path
      if params[:card]
        flash[:notice] = t('notice.transaction_card')
      elsif params[:boleto]
        flash[:notice] = t('notice.transaction_slip')
      end
    end
  end

  def create_credit_card(order)
    # to save user credit card on pagarme and recieve a card hash
    # create a credit card on pagarme
    pagarme_card = PagarMe::Card.new(
      {
        card_number: order[:card][:number].gsub(" ", ""),
        card_holder_name: order[:card][:name],
        card_expiration_month: order[:card][:expiration_month],
        card_expiration_year: order[:card][:expiration_year],
        card_cvv: order[:card][:cvv]
      }
    )

    pagarme_card.create
  end
end
