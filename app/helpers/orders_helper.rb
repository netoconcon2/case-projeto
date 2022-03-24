module OrdersHelper
  def order_installments(order)
    # if Kit.find_by(id: order.kit_id).payment_type == "single"
    #   installments = []
    #   total_price = []
    #   KitProduct.where(kit_id: order.kit_id).each do |order|
    #     total_price << order.price.to_i
    #   end
    #   total_price = total_price.sum
    #   order.kit.maximum_installments.times do |index|
    #     installment_price = total_price  / (index + 1)
    #     installments << ["#{index + 1} X #{number_to_currency(installment_price, unit: "R$ ", separator: ",")}", index]
    #   end
    #   installments
    # else
    #   total_price = []
    #   KitProduct.where(kit_id: order.kit_id).each do |order|
    #     total_price << order.price.to_i
    #   end
    #   total_price = total_price.sum
    #   installments = ["1 X #{number_to_currency(total_price, unit: "R$ ", separator: ",")}"]      
    # end
  end

  def order_single(order)
  #   total_price = []
  #   KitProduct.where(kit_id: order.kit_id).each do |order|
  #     total_price << order.price.to_i
  #   end
  #   total_price = number_to_currency(total_price.sum, unit: "R$ ", separator: ",")
  end
end