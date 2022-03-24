class Api::V1::TransactionsController < Api::V1::BaseController
  def postback
    postback_body = request.raw_post
    signature = request.headers["x-hub-signature"]

    if PagarMe::Postback.valid_request_signature?(postback_body, signature)
      puts "Postback autorizado"
      if postback_body
        payload = Hash[URI.decode_www_form(postback_body)]

        company = Company.find(params[:id])
        transaction_id = payload["id"].to_i
        package_id = payload["transaction[items][0][id]"].to_i

        transaction = Transaction.find_by(pagarme_id: transaction_id)
        package = Package.find(package_id)

        postback_status = payload["current_status"]

        transaction.status = postback_status

        if postback_status == "paid"
          company.available_words += package.words
          company.save
        end
        transaction.save
      end
    end
  end
end
