require 'spec_helper'

RSpec.feature "AGames", :type => :feature, js: true do
  subject { page }

  scenario 'plays salary' do
    visit a_index_path
    fill_in :participant_id, with: 100
    fill_in :group_id, with: 400
    click_button 'start'
    sleep 0.3
    click_link 'Start'

    correct_essay(1)
    correct_essay(2)

    click_link 'Finish'
    click_button 'Confirm'

    expect(subject).to have_content('Total earnings so far:')

    within '.earnings' do
      expect(subject).to have_content('$0.00')
    end

    within '.round_earnings' do
      expect(subject).to have_content('$0.00')
    end
    screenshot_and_open_image

    visit user_path(id: User.last.id)

    screenshot_and_open_image
  end
end
