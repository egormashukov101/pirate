# frozen_string_literal: true

require 'json'
require './api/studios_controller.rb'

RSpec.describe(Api::StudiosController) do
  let(:params) { {} }
  # TODO: Normally, have or create dataset only for testing purposes
  let(:studios_data) { JSON.parse(File.read('./config/studios.json')) }

  describe '#index' do
    subject(:call) { described_class.new(params).index }

    before do
      stub_const('Api::StudiosController::PER_PAGE', 2)
    end

    let(:result) { call }

    context 'when no page provided' do
      it 'returns records from default page' do
        expect(result).to eq([studios_data[0], studios_data[1]])
      end
    end

    context 'when page is invalid' do
      let(:params) { {page: 'wrong'} }

      it 'returns records from default page' do
        expect(result).to eq([studios_data[0], studios_data[1]])
      end
    end

    context 'when page is provided' do
      let(:params) { {page: 2} }

      it 'returns records from provided page' do
        expect(result).to eq([studios_data[2], studios_data[3]])
      end
    end
  end

  describe '#summary' do
    subject(:call) { described_class.new(params).summary }

    let(:result) { call }

    it 'returns summary of all bookings' do
      expect(result[0..1]).to eq(
        [
          {
            bookedPercentage: 18,
            studioId: 1
          },
          {
            bookedPercentage: 29,
            studioId: 2
          }
        ]
      )
    end
  end
end
