# frozen_string_literal: true

require 'json'
require 'time'
require 'ostruct'

module Api
  # For test purposes let's assume it is not web API, but implemented in similar style
  class StudiosController < Struct.new(:raw_params)
    DEFAULT_PAGE = 1
    PER_PAGE = 10

    def index
      start_index = (page - 1) * PER_PAGE

      collection[start_index...(start_index + PER_PAGE)]
    end

    def summary
      collection.group_by {|studio| studio['studioId'] }.map do |(studio_id, bookings)|
        bookings_duration = bookings.sum { |b| Time.parse(b['endsAt']) - Time.parse(b['startsAt']) }

        {
          studioId: studio_id,
          bookedPercentage: ((bookings_duration / total_duration) * 100).to_i,
        }
      end
    end

    private

    def collection
      @collection ||= JSON.parse(File.read('./config/studios.json')) # Normally, do not hardcode paths
    end

    def total_duration
      @total_duration ||= begin
        max = collection.map {|b| Time.parse(b['endsAt']) }.max
        min = collection.map {|b| Time.parse(b['startsAt']) }.min
        max - min
      end
    end

    def params
      return {} unless raw_params.is_a?(Hash)

      raw_params
    end

    def page
      params[:page].to_i.clamp(1, Float::INFINITY) || DEFAULT_PAGE
    end
  end
end
