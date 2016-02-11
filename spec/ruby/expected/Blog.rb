require 'activefacts/api'

module Blog
  class AuthorId < AutoCounter
    value_type
  end

  class Name < String
    value_type      length: 64
  end

  class Author
    identified_by   :author_id
    one_to_one      :author_id, mandatory: true         # Author has Author Id, see AuthorId#author
    one_to_one      :author_name, mandatory: true, class: Name  # Author is called Name, see Name#author_as_author_name
  end

  class CommentId < AutoCounter
    value_type
  end

  class Style < String
    value_type      length: 20
  end

  class Content
    identified_by   :style, :text
    has_one         :style                              # Content is of Style, see Style#all_content
    has_one         :text, mandatory: true              # Content has Text
  end

  class Ordinal < UnsignedInteger
    value_type      length: 32
  end

  class PostId < AutoCounter
    value_type
  end

  class TopicId < AutoCounter
    value_type
  end

  class Topic
    identified_by   :topic_id
    one_to_one      :topic_id, mandatory: true          # Topic has Topic Id, see TopicId#topic
    one_to_one      :topic_name, mandatory: true, class: Name  # Topic is called topic-Name, see Name#topic_as_topic_name
    has_one         :parent_topic, class: Topic         # Topic belongs to parent-Topic, see Topic#all_topic_as_parent_topic
  end

  class Post
    identified_by   :post_id
    one_to_one      :post_id, mandatory: true           # Post has Post Id, see PostId#post
    has_one         :author, mandatory: true            # Post was written by Author, see Author#all_post
    has_one         :topic, mandatory: true             # Post belongs to Topic, see Topic#all_post
  end

  class Paragraph
    identified_by   :post, :ordinal
    has_one         :post, mandatory: true              # Paragraph involves Post, see Post#all_paragraph
    has_one         :ordinal, mandatory: true           # Paragraph involves Ordinal, see Ordinal#all_paragraph
    has_one         :content, mandatory: true           # Paragraph contains Content, see Content#all_paragraph
  end

  class Comment
    identified_by   :comment_id
    one_to_one      :comment_id, mandatory: true        # Comment has Comment Id, see CommentId#comment
    has_one         :author, mandatory: true            # Comment was written by Author, see Author#all_comment
    has_one         :content, mandatory: true           # Comment consists of text-Content, see Content#all_comment
    has_one         :paragraph, mandatory: true         # Comment is on Paragraph, see Paragraph#all_comment
  end
end