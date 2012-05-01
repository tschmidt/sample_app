FactoryGirl.define do
  factory :user do
    name                  "Terry Schmidt"
    email                 "terry.m.schmidt@example.com"
    password              "secret"
    password_confirmation "secret"
  end
end