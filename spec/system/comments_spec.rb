require 'rails_helper'

RSpec.describe "Comments", type: :system do
  let(:user) { create(:user) }
  let!(:post) { create(:post) }

  it "コメントを作成、削除できること" do
    log_in(user)
    click_link '投稿一覧'
    click_link post.title

    # コメント投稿
    fill_in 'コメント', with: 'こんにちは'
    click_button 'コメントする'

    expect(page).to have_content 'こんにちは'

    # コメント削除
    within '.comment_delete' do
      click_link '削除'
    end

    expect(page).to_not have_content 'こんにちは'
  end

  xit "141字以上のコメントは投稿できないこと" do
    log_in(user)
    click_link '投稿一覧'
    click_link post.title

    fill_in 'コメント', with: 'a' * 141
    click_button 'コメントする'

    expect(page).to have_content 'コメントは140文字以内で入力してください'
  end
end
