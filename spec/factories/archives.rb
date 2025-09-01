FactoryBot.define do
  factory :archive do
    association :document
    # version is auto-set by model callback, don't set here
    previous_archive { nil }
    sequence(:checksum) { |n| "sha256_#{SecureRandom.hex(32)}" }
    diff_content { "Added new terms regarding data usage." }
    archived_by { "system" }
    
    trait :with_changes do
      diff_content { "Significant changes to privacy policy section 3.2" }
    end
    
    trait :no_changes do
      diff_content { nil }
    end
  end
end
