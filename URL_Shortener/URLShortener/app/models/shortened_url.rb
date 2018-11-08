# == Schema Information
#
# Table name: shortened_urls
#
#  id         :bigint(8)        not null, primary key
#  long_url   :string           not null
#  short_url  :string           not null
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ShortenedUrl < ApplicationRecord
  validates :long_url, :short_url, presence: true, uniqueness: true

  belongs_to :submitter,
    primary_key: :id,
    foreign_key: :user_id,
    class_name: :User

  has_many :visits,
    primary_key: :id,
    foreign_key: :shortened_url_id,
    class_name: :Visit

  has_many :visitors,
    Proc.new{ distinct }
    through: :visits,
    source: :user

  def self.random_code
    code = SecureRandom::urlsafe_base64(16)
    while ShortenedUrl.exists?(:short_url => code)
      code = SecureRandom::urlsafe_base64(16)
    end
    code
  end

  def self.create_shortened_url(user, long_url)
    code = self.random_code
    ShortenedUrl.create!(:long_url => long_url, :short_url => code, :user_id => user.id)
  end

  def num_clicks
    # Ruby code
    # self.visitors.count

    # Initial Rails query
    Visit.select(:user_id).where("shortened_url_id = #{self.id}").count
  end

  def num_uniques
    # Ruby code
    # self.visitors.map { |v| v.user_id }.uniq.count

    # Initial Rails query
    Visit.select(:user_id).where("shortened_url_id = #{self.id}").distinct.count
  end

  def num_recent_uniques
    Visit.select(:user_id).where("shortened_url_id = #{self.id} AND created_at >= ?", 30.minutes.ago).distinct.count
  end

end
