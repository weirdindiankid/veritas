FactoryBot.define do
  factory :document do
    association :company
    sequence(:url) { |n| "https://example#{n}.com/terms" }
    sequence(:title) { |n| "Terms of Service #{n}" }
    content { "This is the terms of service content. By using our service, you agree to these terms and conditions. We may update these terms at any time." }
    archived_at { Time.current }
    sequence(:ipfs_hash) { |n| "Qm#{SecureRandom.alphanumeric(44)}" } # Mock IPFS hash format
    
    trait :privacy_policy do
      sequence(:url) { |n| "https://example#{n}.com/privacy" }
      sequence(:title) { |n| "Privacy Policy #{n}" }
      content { "This privacy policy describes how we collect, use, and protect your personal information." }
    end
    
    trait :old_document do
      archived_at { 1.year.ago }
    end
    
    trait :recent_document do
      archived_at { 1.hour.ago }
    end
    
    trait :with_archives do
      after(:create) do |document|
        create_list(:archive, 2, document: document)
      end
    end
  end
end
