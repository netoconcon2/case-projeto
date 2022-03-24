class Transaction < ApplicationRecord
  belongs_to :company

  def get_pagarme_infos
  	transaction = PagarMe::Transaction.find_by_id(self.pagarme_id.to_i)
  end
end
