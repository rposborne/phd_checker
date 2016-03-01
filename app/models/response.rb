class Response < ActiveRecord::Base
  require 'csv'
  belongs_to :user
  before_save :update_actions
  validates :user_id, presence: true
  validates :corrected, length: { maximum: 100 }
  scope :incorrect, -> { where(correct: false) }
  scope :correct, -> { where(correct: true) }

  def set_correct
    assign_attributes(correct: correct?)
  end

  def self.raw_csv(responses)
    CSV.generate do |csv|
      # header row
      csv << [
        'id',
        'group',
        'participant_id',
        'error',
        'essay',
        'Correct?',
        'Field Before Correction',
        'Seconds to Complete',
        'Round',
        'Treatment',
        'Time Corrected'
      ]

      # data rows
      responses.each do |response|
        csv << [
          response.id,
          response.user_id,
          response.user.group,
          response.error,
          response.essay,
          response.correct,
          response.uncorrected,
          response.round_number,
          response.user.time_to_complete,
          response.controller,
          response.created_at
        ]
      end
    end
  end

  private

  def update_actions
    actions = self.actions ? self.actions.map{|action| JSON.parse(action).symbolize_keys} : []
    last_response = Response.where(round_number: round_number, user: user).order(updated_at: :desc).pluck(:id, :updated_at).first
    last_response_id = last_response.present? ? last_response[0] : nil
    last_action_time = last_response.present? ? last_response[1] : Round.where(user: user, round_number: round_number).first.try(:created_at) || Time.current
    time_of_action = Time.current
    time_since_last_action = (time_of_action - last_action_time).round(6)

    current_action = {last_response: last_response_id, time_since_last_action: time_since_last_action, correct?: correct?, time_of_action: time_of_action}
    self.actions = (actions << current_action).map(&:to_json)
  end

  def correct?
    correct_answer == corrected
  end
end
