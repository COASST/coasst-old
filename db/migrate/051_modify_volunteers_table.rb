class ModifyVolunteersTable < ActiveRecord::Migration
  def self.up
    # volunteer traits
    add_column :volunteers, :gender, :string # Hash
    add_column :volunteers, :trained_age, :integer
    add_column :volunteers, :occupation, :string
    add_column :volunteers, :employer, :string
    add_column :volunteers, :nickname, :string

    # contact 
    add_column :volunteers, :contact_time_of_day, :string
    add_column :volunteers, :contact_method, :string # Hash

    # training intake data
    add_column :volunteers, :trained_date, :date
    add_column :volunteers, :find_us, :string
    add_column :volunteers, :find_us_category, :string # Hash
    add_column :volunteers, :involvement, :string
    add_column :volunteers, :birding_experience, :string # Hash
    add_column :volunteers, :volunteer_comments, :text
    add_column :volunteers, :organizations, :string

    add_column :volunteers, :quiz_score_live_family, :integer
    add_column :volunteers, :quiz_score_live_spp, :integer
    add_column :volunteers, :quiz_score_dead_family, :integer
    add_column :volunteers, :quiz_score_dead_spp, :integer

    # widthdrawl information
    add_column :volunteers, :substitute_only, :boolean, :default => false
    add_column :volunteers, :widthdrawn, :boolean, :default => false
    add_column :volunteers, :widthdrawn_date, :date
    add_column :volunteers, :widthdrawn_reason, :string
    add_column :volunteers, :inactive_date, :date
    add_column :volunteers, :kit_type, :string # Hash
    add_column :volunteers, :kit_return_date, :date

    # financial
    add_column :volunteers, :deposit_amount, :decimal, :precision => 12, :scale => 8
    add_column :volunteers, :deposit_type, :string # Hash
    add_column :volunteers, :deposit_check_number, :string
    add_column :volunteers, :deposit_return_date, :date
    add_column :volunteers, :deposit_return_type, :string # Hash
    add_column :volunteers, :donor, :boolean, :default => false

    # mailing list
    add_column :volunteers, :mailing_list, :boolean
    add_column :volunteers, :mailing_list_expiration, :date

    # directory
    add_column :volunteers, :directory, :boolean
    add_column :volunteers, :directory_phone, :boolean
    add_column :volunteers, :directory_email, :boolean
    add_column :volunteers, :directory_guest, :boolean
    add_column :volunteers, :directory_substitute, :boolean

    # internal use
    add_column :volunteers, :notes, :text

    # XXX will add later with picklists
    # notes [as a sub-table...]
    # agency info (like volunteers, but mailing list only)
  end

  def self.down
    remove_column :volunteers, :occupation
    remove_column :volunteers, :employer
    remove_column :volunteers, :gender
    remove_column :volunteers, :contact_time_of_day
    remove_column :volunteers, :contact_method
    remove_column :volunteers, :nickname

    puts "removing columns..."
    # training intake data
    remove_column :volunteers, :trained_date
    remove_column :volunteers, :trained_age
    remove_column :volunteers, :find_us
    remove_column :volunteers, :find_us_category 
    remove_column :volunteers, :involvement
    remove_column :volunteers, :birding_experience 
    remove_column :volunteers, :volunteer_comments
    remove_column :volunteers, :organizations

    remove_column :volunteers, :quiz_score_live_family
    remove_column :volunteers, :quiz_score_live_spp
    remove_column :volunteers, :quiz_score_dead_family
    remove_column :volunteers, :quiz_score_dead_spp

    # widthdrawl information
    remove_column :volunteers, :substitute_only
    remove_column :volunteers, :widthdrawn
    remove_column :volunteers, :widthdrawn_reason
    remove_column :volunteers, :widthdrawn_date
    remove_column :volunteers, :inactive_date 
    remove_column :volunteers, :kit_type
    remove_column :volunteers, :kit_return_date

    # financial
    remove_column :volunteers, :deposit_amount
    remove_column :volunteers, :deposit_type 
    remove_column :volunteers, :deposit_check_number
    remove_column :volunteers, :deposit_return_date
    remove_column :volunteers, :deposit_return_type
    remove_column :volunteers, :donor

    # mailing list
    remove_column :volunteers, :mailing_list
    remove_column :volunteers, :mailing_list_expiration

    # directory
    remove_column :volunteers, :directory
    remove_column :volunteers, :directory_phone
    remove_column :volunteers, :directory_email
    remove_column :volunteers, :directory_guest
    remove_column :volunteers, :directory_substitute

    # internal use
    remove_column :volunteers, :notes
  end
end
