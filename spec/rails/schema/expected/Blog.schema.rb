#
# Auto-generated (edits will be lost)
#

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Schema.define(version: 20000000000000) do
  enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

  create_table "authors", id: false, force: true do |t|
    t.column "author_id", :primary_key, null: false
    t.column "author_name", :string, limit: 64, null: false
  end

  add_index "authors", ["author_name"], name: :index_authors_on_author_name, unique: true

  create_table "comments", id: false, force: true do |t|
    t.column "comment_id", :primary_key, null: false
    t.column "author_id", :integer, null: false
    t.column "content_style", :string, limit: 20, null: true
    t.column "content_text", :text, null: false
    t.column "paragraph_id", :integer, null: false
  end

  create_table "paragraphs", id: false, force: true do |t|
    t.column "paragraph_id", :primary_key, null: false
    t.column "post_id", :integer, null: false
    t.column "ordinal", :integer, null: false
    t.column "content_style", :string, limit: 20, null: true
    t.column "content_text", :text, null: false
  end

  add_index "paragraphs", ["post_id", "ordinal"], name: :index_paragraphs_on_post_id_ordinal, unique: true

  create_table "posts", id: false, force: true do |t|
    t.column "post_id", :primary_key, null: false
    t.column "author_id", :integer, null: false
    t.column "topic_id", :integer, null: false
  end

  create_table "topics", id: false, force: true do |t|
    t.column "topic_id", :primary_key, null: false
    t.column "topic_name", :string, limit: 64, null: false
    t.column "parent_topic_id", :integer, null: true
  end

  add_index "topics", ["topic_name"], name: :index_topics_on_topic_name, unique: true

  unless ENV["EXCLUDE_FKS"]
    add_foreign_key :comments, :authors, column: :author_id, primary_key: :author_id, on_delete: :cascade
    add_foreign_key :comments, :paragraphs, column: :paragraph_id, primary_key: :paragraph_id, on_delete: :cascade
    add_foreign_key :paragraphs, :posts, column: :post_id, primary_key: :post_id, on_delete: :cascade
    add_foreign_key :posts, :authors, column: :author_id, primary_key: :author_id, on_delete: :cascade
    add_foreign_key :posts, :topics, column: :topic_id, primary_key: :topic_id, on_delete: :cascade
    add_foreign_key :topics, :topics, column: :parent_topic_id, primary_key: :topic_id, on_delete: :cascade
    add_index :comments, [:author_id], unique: false, name: :index_comments_on_author_id
    add_index :comments, [:paragraph_id], unique: false, name: :index_comments_on_paragraph_id
    add_index :posts, [:author_id], unique: false, name: :index_posts_on_author_id
    add_index :posts, [:topic_id], unique: false, name: :index_posts_on_topic_id
    add_index :topics, [:parent_topic_id], unique: false, name: :index_topics_on_parent_topic_id
  end
end
