#
# schema.rb auto-generated for Person
#

ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Schema.define(version: 20160411150450) do
  enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

  create_table "people", id: false, force: true do |t|
    t.column "person_id", :primary_key, null: false
    t.column "family_name", :string, null: false
    t.column "given_name", :string, null: false
  end

  add_index "people", ["family_name", "given_name"], name: :index_people_on_family_name_given_name, unique: true

  unless ENV["EXCLUDE_FKS"]
  end
end
