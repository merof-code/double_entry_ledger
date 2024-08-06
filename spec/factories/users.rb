# frozen_string_literal: true

User = Class.new(ActiveRecord::Base)

FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
  end
end
