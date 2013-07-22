# Put your database migration here!
#
# Each one needs to be named correctly:
# timestamp_[action]_[class]
#
# and once a migration is run, a new one must
# be created with a later timestamp.

class CreateLinks < ActiveRecord::Migration
    def up
      create_table :links do |t|
        t.string :long_url
        t.string :short_url
      end
    end
    def down 
    	drop_table :links
    end
end
