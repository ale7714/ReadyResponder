require 'rails_helper'

RSpec.describe Event do
  describe 'associations' do
    it 'has many notifications' do
      expect(subject).to have_many(:notifications)
    end
  end
  it { should validate_presence_of(:status) }
  it { should validate_presence_of(:id_code) }

  it "has a valid factory" do
    expect(create(:event)).to be_valid
  end

  it "is invalid without a title" do
    expect(build(:event, title: nil)).not_to be_valid
  end

  it "is invalid if end_time is before start_time" do # chronology
    expect(build(:event, start_time: Time.current, end_time: 10.days.ago)).not_to be_valid
  end

  it "is invalid if start_time is blank and status is completed" do
    expect(build(:event, status: "Completed", start_time: nil, end_time: 10.days.ago )).not_to be_valid
  end

  it "is invalid if end_time is blank and status is completed" do
    expect(build(:event, status: "Completed", start_time: Time.current, end_time: nil)).not_to be_valid
  end

  it "reports if it's ready to schedule" do
    @event = build(:event, start_time: nil, end_time: 75.minutes.from_now, status: "Scheduled")
    expect(@event.ready_to_schedule?("Available")).to eq(false)  # Need a start time
    @event = build(:event, start_time: Time.current, end_time: nil, status: "Scheduled")
    expect(@event.ready_to_schedule?("Worked")).to eq(false)  # Need an end time
    @event = build(:event, start_time: Time.current, end_time: 75.minutes.from_now, status: "Closed")
    expect(@event.ready_to_schedule?("Scheduled")).to eq(false)  # Never for a closed event
  end

  it "changes the id_code to lower case and trims it" do
    @event = create(:event, id_code: " HowDy DOOdy ")
    expect(@event.id_code).to eq("howdy")
  end

  it "counts as upcoming if it hasnt ended" do
    @event = create(:event, start_time: Time.current, end_time: 75.minutes.from_now, status: "Scheduled")
    expect(Event.upcoming.include?(@event)).to be(true)
  end

end
