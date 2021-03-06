class Micropost < ApplicationRecord
  # belongs_toで関連付けるテーブルは一つに決まるため単数形になっている
  belongs_to :user
  # -> {}はブロックといい、-{}.callのようにコールバックメソッドで呼び出されたときに実行される
  default_scope -> {order(created_at: :desc)}
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: 140}
  validate :picture_size

  private

    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end
end
