module PlanHelper
  def payment_period(days)
    case days
    when 30 || 31
      t('.monthly')
    when 7
      t('.weekly')
    when 14 || 15
      t('.biweekly')
    when 365
      t('annually')
    else
      t('.days', count: days)
    end
  end

  def plan_duration(days)
    case days
    when 180
      t('.semiannual')
    when 60
      t('.bimonthly')
    when 90
      t('.quarterly')
    when 365
      t('.yearly')
    end
  end

  def price_per_word(plan)
    price = (plan.price.to_f / plan.words).round(2)
    price < 0.01 ? t('.less_1_cent') : price.to_s.gsub(/\./, ",")
  end
end
