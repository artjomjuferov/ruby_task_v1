require_relative 'checkout'

describe Checkout do

  it { is_expected.to respond_to(:scan).with(1).argument }
  it { is_expected.to respond_to(:total) }

  context '#new' do
    context 'when promotional rule is not provided' do
      it 'sets @total_rule to 60' do
        expect(subject.instance_variable_get :@total_rule).to eq 60
      end

      it 'sets @total_disc to 10' do
        expect(subject.instance_variable_get :@total_disc).to eq 10
      end

      it 'sets @card_rule to 2' do
        expect(subject.instance_variable_get :@card_rule).to eq 2
      end

      it 'sets @card_disc to 8.5' do
        expect(subject.instance_variable_get :@card_disc).to eq 8.5
      end
    end

    context 'when total_rule is negative' do
      subject { Checkout.new total_rule: -1}

      it 'raises error' do
        expect { subject }.to raise_error PromotionalRuleError
      end
    end

    context 'when total_disc is over 100' do
      subject { Checkout.new total_disc: 101 }

      it 'raises error' do
        expect { subject }.to raise_error PromotionalRuleError
      end
    end

    context 'when total_rule is 1 and card_rule is 1.1' do
      subject { Checkout.new total_rule: 1, card_rule: 1.1}

      it 'sets @total_rule to 1' do
        expect(subject.instance_variable_get :@total_rule).to eq 1
      end

      it 'sets @card_rule to 1.1' do
        expect(subject.instance_variable_get :@card_rule).to eq 1.1
      end
    end
  end

  context '#scan' do

    context 'when wrong item provided' do
      ['01', '004',1].each do |wrong_item|
        it 'raises error' do
          expect { subject.scan wrong_item }.to raise_error ItemNotFoundError
        end
      end
    end

    context 'when nothing was scanned' do
      it 'does not change total' do
        expect(subject.total).to eq 0
      end
    end

    context 'when 1 card is scanned' do
      it 'does not apply discount' do
        subject.scan '001'
        expect(subject.total).to eq 9.25
      end
    end

    context 'when 2 card is scanned' do
      it 'does not apply card discount' do
        subject.scan '001'
        subject.scan '001'
        expect(subject.total).to eq 8.5*2
      end
    end

    context 'when total price is not over 60' do
      it 'does not apply total discount' do
        subject.scan '002'
        expect(subject.total).to eq 45
      end
    end

    context 'when total price is not over 60' do
      it 'does not apply total discount' do
        subject.scan '002'
        subject.scan '002'
        expect(subject.total).to eq 81
      end
    end

    context 'when total price is not over 60 after applying card discount' do
      it 'does not apply total discount' do
        7.times { subject.scan '001' }
        expect(subject.total).to eq 8.5*7
      end
    end

    context 'when default test 1' do
      it 'sets total eq to 66.78' do
        scan_all subject, %w(001 002 003)
        expect(subject.total).to eq 66.78
      end
    end

    context 'when default test 2' do
      it 'sets total eq to 36.95' do
        scan_all subject, %w(001 003 001)
        expect(subject.total).to eq 36.95
      end
    end

    context 'when default test 3' do
      it 'sets total eq to 73.76' do
        scan_all subject, %w(001 002 001 003)
        expect(subject.total).to eq 73.76
      end
    end

  end

  private

  def scan_all co, items
    items.each{ |item| co.scan item }
  end
end