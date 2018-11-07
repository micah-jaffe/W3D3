class RemoveUniqueIndexFromShortenedUrls < ActiveRecord::Migration[5.1]
  def change
    remove_index(:shortened_urls, :user_id)
    remove_index(:shortened_urls, :long_url)

    add_index :shortened_urls, :user_id
    add_index :shortened_urls, :long_url
    add_index :shortened_urls, :short_url
  end
end
