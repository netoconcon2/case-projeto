class Api::V1::CompaniesController < Api::V1::BaseController
  def postback
    postback_body = request.raw_post
    signature = request.headers["x-hub-signature"]

    if PagarMe::Postback.valid_request_signature?(postback_body, signature)
      puts "Postback autorizado"
      if postback_body
        payload = Hash[URI.decode_www_form(postback_body)]

        company = Company.find(params[:id])
        postback_status = payload["current_status"]

        case postback_status
        when "trialing", "paid"
          company.plan_status = "active"
        when "pending_payment"
          company.plan_status = "pending"
        when "unpaid"
          company.plan_status = "unpaid"
        when "canceled"
          company.plan_status = "canceled"
        when "ended"
          company.plan_status = "ended"
        end
      end
      company.save
    else
      puts "Postback não autorizado"
    end
  end
end
