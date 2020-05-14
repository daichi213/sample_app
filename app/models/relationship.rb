class Relationship < ApplicationRecord
    belongs_to :follower, class_name: "User"
    belongs_to :followed, class_name: "User"
    # rails5から自動的に以下のバリデーションが裏側で実行されるようになった
    # validates :follower_id, presence: true
    # validates :followed_id, presence: true
end
