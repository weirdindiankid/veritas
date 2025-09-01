FactoryBot.define do
  factory :company do
    sequence(:name) { |n| "Company #{n}" }
    sequence(:domain) { |n| "company#{n}.com" }
    sequence(:terms_url) { |n| "https://company#{n}.com/terms" }
    sequence(:privacy_url) { |n| "https://company#{n}.com/privacy" }
    description { "A test company for archiving terms of service" }
    
    trait :without_privacy_url do
      privacy_url { nil }
    end
    
    trait :inactive do
      to_create { |instance| instance.save(validate: false) }
      terms_url { nil }
      name { "Inactive Company" }
    end
    
    trait :twitter_like do
      name { "Twitter" }
      domain { "twitter.com" }
      terms_url { "https://twitter.com/tos" }
      privacy_url { "https://twitter.com/privacy" }
      description { "Social media platform" }
    end
    
    trait :facebook_like do
      name { "Facebook" }
      domain { "facebook.com" }
      terms_url { "https://facebook.com/legal/terms" }
      privacy_url { "https://facebook.com/privacy" }
      description { "Social networking service" }
    end
  end
end
