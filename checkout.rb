class Checkout
  attr_reader :total

  def initialize total_rule: 60, total_disc: 10,  card_rule: 2, card_disc: 8.5
    @total_rule = total_rule
    @card_rule  = card_rule
    @total_disc = total_disc
    @card_disc  = card_disc
    # is discount already applied
    @is_total   = false
    @is_card    = false
    @items      = []
    @total      = 0
    # validate promotional rules
    validation
  end

  def scan item
    # do we have such item in store
    validate_item item
    @total += get_price item
    @items << item
  end

  def total
    # first we have to apply card rules
    apply_card_rule
    apply_total_rule
    @total.round 2
  end

  private

  # I hope that in scope of this task we have only 3 items
  def get_price item
    case item
      when "001"
        9.25
      when "002"
        45.0
      when "003"
        19.95
    end
  end

  def validation
    validate_total_discount @total_disc
    validate_rule @total_rule
    validate_rule @card_disc
    validate_rule @card_rule
  end

  def apply_rules

  end

  def apply_total_rule
    return if @is_total or @total <= @total_rule
    @is_total = true
    @total -= @total*(@total_disc.to_f/100)

  end

  def apply_card_rule
    return if @is_card
    amount = @items.select{|item| item == '001' }.count
    return unless amount >= @card_rule
    @is_card = true
    @total -= (9.25-@card_disc)*amount

  end

  def validate_rule rule
    raise PromotionalRuleError, rule if rule < 0
  end

  def validate_total_discount value
    raise PromotionalRuleError, value if value < 0 or value > 100
  end

  def validate_item item
    raise ItemNotFoundError, item unless ['001', '002','003'].include? item
  end
end

class PromotionalRuleError < StandardError
  def initialize rule
    super "Promotional rule is not correct: '#{rule}'"
  end
end

class ItemNotFoundError < StandardError
  def initialize id
    super "Item with id = '#{id}' is not found in our store"
  end
end
