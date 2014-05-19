require 'spec_helper'

describe Parsers::Edi::Etf::EtfLoop do
  let(:etf) { Parsers::Edi::Etf::EtfLoop.new(raw_etf_loop) }

  describe '#subscriber_loop' do
    let(:not_subscriber) { { "INS" => ['','','']} }
    let(:subscriber) { { "INS" => ['','','18']} }
    let(:raw_etf_loop) { {"L2000s" => [ not_subscriber, subscriber]} }
    it 'returns subscriber person loop' do
      expect(etf.subscriber_loop).to eq subscriber
    end

    describe '#carrier_fein' do
      let(:carrier_fein) { '1234'}
      let(:raw_etf_loop) { {"L1000B" => { "N1" => ['','','','', carrier_fein]}} }

      it 'returns the carrier fein from the Payer loop' do
        expect(etf.carrier_fein).to eq carrier_fein
      end
    end
    describe '#employer_loop' do
      let(:n1) { ['','','DC0'] }
      let(:raw_etf_loop) { {"L1000A" => {"N1" => n1}} }
      it 'returns the employer loop' do
        expect(etf.employer_loop).to eq n1
      end
    end

    describe '#is_shop?' do
      let(:raw_etf_loop) { {"L1000A" => {"N1" => n1}} }
      context 'when employer is not DC0' do
        let(:n1) { ['','','NOT_DC0'] }
        it 'returns the employer loop' do
          expect(etf.is_shop?).to eq true
        end
      end

      context 'when employer is DC0' do
        let(:n1) { ['','','DC0'] }
        it 'returns the employer loop' do
          expect(etf.is_shop?).to eq false
        end
      end
    end
  end
end