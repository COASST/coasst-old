# == Schema Information
#
#  id                        :integer       not null, primary key
#  state_id                  :integer
#  first_name                :string(255)   not null
#  last_name                 :string(255)   not null
#  middle_initial            :string(1)
#  fullname                  :string(255)
#  email                     :string(255)
#  phone                     :string(255)
#  extension                 :string(255)
#  street_address            :string(255)
#  city                      :string(255)
#  zip                       :string(255)
#  created_on                :datetime
#  updated_on                :datetime
#  ended_on                  :datetime
#  active                    :boolean       default(TRUE)
#  hashed_password           :string(255)
#  salt                      :string(255)
#  reset_password_code       :string(255)
#  reset_password_code_until :datetime
#  has_account               :boolean
#  gender                    :string(255)
#  trained_age               :integer
#  occupation                :string(255)
#  employer                  :string(255)
#  contact_time_of_day       :string(255)
#  contact_method            :string(255)
#  trained_date              :date
#  find_us                   :string(255)
#  find_us_category          :string(255)
#  involvement               :string(255)
#  birding_experience        :string(255)
#  volunteer_comments        :text
#  organizations             :string(255)
#  substitute_only           :boolean
#  widthdrawn                :boolean
#  widthdrawn_date           :date
#  inactive_date             :date
#  kit_type                  :string(255)
#  kit_return_date           :date
#  deposit_amount            :decimal(12, 8
#  deposit_type              :string(255)
#  deposit_check_number      :string(255)
#  deposit_return_date       :date
#  deposit_return_type       :string(255)
#  mailing_list              :boolean
#  mailing_list_expiration   :date
#  directory                 :boolean
#  directory_phone           :boolean
#  directory_email           :boolean
#  directory_guest           :boolean
#  directory_substitute      :boolean
#  notes                     :text
#

require 'digest/sha1'

class Volunteer < ActiveRecord::Base
#include Mcm::Validations

  has_and_belongs_to_many :roles, :join_table => :roles_volunteers
  has_and_belongs_to_many :friends,
    :class_name => "Volunteer",
    :join_table => "volunteer_friends",
    :association_foreign_key => "friend_id",
    :foreign_key => "volunteer_id"
  has_many :beaches,
    :through => :volunteer_beaches
  has_many :survey_volunteers, :dependent => :destroy
  # we have multiple roles per volunteer, need only unique surveys
  has_many :surveys, :through => :survey_volunteers, :select => "DISTINCT surveys.*"
  has_many :volunteer_friends, :dependent => :destroy
  has_many :volunteer_beaches, :dependent => :destroy
  belongs_to :state
  has_and_belongs_to_many :occupations, :join_table => :volunteer_occupation
  has_and_belongs_to_many :involvements, :join_table => :volunteer_involvement

  Gender = [
    [ "Male",        "male"],
    [ "Female",      "female"],
    [ "Unspecified",  nil]
  ]

  ContactMethod = [
    [ "Email",       "email"],
    [ "Phone",       "phone"],
    [ "Either",      "either"],
    [ "Unspecified",  nil]
  ]

  FindUsCategory = [
    [ "Through an organization", "organization"],
    [ "Newspaper", "newspaper"],
    [ "Poster", "poster"],
    [ "Someone I know", "person"],
    [ "Watched a presentation or communicated with COASST staff", "staff"],
    [ "Website", "website"],
    [ "Unspecified", nil]
  ]

  InvolvementCategory = [
    ["Interest in a similar program", "another program"],
    ["Interest in the environment", "environment"],
    ["Excuse to be outside", "outside"],
    ["Community involvement", "community"],
    ["Help research", "research"],
    ["Unspecified", nil]
  ]

  BirdingExperience = [
    [ "No Experience", "no experience"],
    [ "Beginner", "beginner"],
    [ "Intermediate", "intermediate"],
    [ "Advanced", "advanced"],
    [ "Expert", "expert"],
    [ "Unspecified", nil]
  ]

  DepositType = [
    [ "Check", "check"],
    [ "Cash", "cash"],
    [ "Unspecified", nil]
  ]

  DepositReturnType = [
    [ "Check", "check" ],
    [ "Gift", "gift" ],
    [ "Unspecified", nil ]
  ]

  KitType = [
    ["No kit", "none"],
    ["Has kit", "has"],
    ["Borrows kit", "borrows"],
    ["Returned kit", "returned"]
  ]

  validates_presence_of     :first_name, :last_name
  validates_presence_of     :email,
                            :if => Proc.new { |v| !v.password.nil?}
  validates_presence_of     :password,
                            :if => Proc.new { |v| !v.password.nil?}
  validates_as_email        :email, # uses plugin RFC-822 email validation
                            :if => Proc.new { |v| !v.password.nil?}
  validates_length_of       :email, :within => 3..100,
                            :if => Proc.new { |v| !v.email.blank? }
  validates_length_of       :middle_initial, :is => 1,
                            :message => 'can only be one letter',
                            :if => Proc.new { |v| !v.middle_initial.blank? }
  validates_length_of       :zip, :within => 5..9,
                            :if => Proc.new { |v| !v.zip.blank? }
  validates_uniqueness_of   :fullname,
                            :case_sensitive => false,
                            :message => ": volunteer with the same name already exists"
  validates_numericality_of :extension,
                            :if => Proc.new { |v| !v.extension.blank? }
  validates_numericality_of :zip,
                            :if => Proc.new { |v| !v.zip.blank? }
  validates_numericality_of :trained_age,
                            :if => Proc.new { |v| !v.trained_age.blank? }
  validates_confirmation_of :password, :on => :create,
                            :if => Proc.new { |v|
                              v.has_account? && !v.password.blank?
                            }

  # volunteer survey traits
  validates_inclusion_of  :gender , :in => Gender.map {|x| x[1]},
                          :if => Proc.new { |s| s.gender?},
                          :message =>  "invalid gender selected"
  validates_inclusion_of  :contact_method, :in => ContactMethod.map {|x| x[1]},
                          :if => Proc.new { |s| s.contact_method?},
                          :message =>  "invalid contact method selected"
  validates_inclusion_of  :find_us_category, :in => FindUsCategory.map {|x| x[1]},
                          :if => Proc.new { |s| s.find_us_category?},
                          :message =>  "invalid 'find us' category selected"
  validates_inclusion_of  :birding_experience, :in => BirdingExperience.map {|x| x[1]},
                          :if => Proc.new { |s| s.birding_experience?},
                          :message =>  "invalid level of birding experience selected"
  validates_inclusion_of  :kit_type, :in => KitType.map {|x| x[1]},
                          :if => Proc.new { |s| s.kit_type?},
                          :message => "invalid kit type selected"
  validates_inclusion_of  :deposit_type, :in => DepositType.map {|x| x[1]},
                          :if => Proc.new { |s| s.deposit_type?},
                          :message =>  "invalid deposit type selected"
  validates_inclusion_of  :deposit_return_type, :in => DepositReturnType.map {|x| x[1]},
                          :if => Proc.new { |s| s.deposit_return_type?},
                          :message =>  "invalid deposit return method selected"

  composed_of :name, :class_name => 'Name',
              :mapping =>
                 [ # database         ruby
                   [ :first_name,     :first_name ],
                   [ :middle_initial, :middle_initial ],
                   [ :last_name,      :last_name ]
                 ]

  composed_of :address, :class_name => 'Address',
              :mapping =>
                 [ # database          ruby
                   [ :address_street,  :address_street ],
                   [ :city,            :city ],
                   [ :state_id,        :state_id ],
                   [ :zip,             :zip ]
                 ]

  before_validation :normalize_phone_number
  before_validation :generate_fullname
  before_destroy :remove_friends

  # XXX XXX validate trained date in the past, mailing_list_expiration in the future, deposit_return in the past

  def password
    @password
  end

  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = Volunteer.encrypted_password(self.password, self.salt)
    self.has_account = true
  end

  def self.phone_formatted(number, number_extension)
    return if number.blank?
    formatted = "(#{number[0..2]}) #{number[3..5]}-#{number[6..-1]}"
    if not number_extension.blank?
      formatted += " x#{number_extension}"
    end
    formatted
  end

  def phone_formatted
    Volunteer.phone_formatted(self.phone, self.extension)
  end

  def status
    # status: map our various fields about the volunteer into a
    # single 'status' trait
    status = 'active'
    if self.widthdrawn == true
      status = 'widthdrawn'
    elsif self.inactive_date? # date
      status = 'inactive (' + inactive_date.strftime("%b %Y") + ')'
    elsif self.substitute_only == true
      status = 'substitute'
    else
      status = 'active'
    end
  end

  def has_right_for?(action_name, controller_name)
      roles.detect{|role| role.has_right_for?(action_name, controller_name)}
  end

  def has_role?(role_name)
    if role_name.class == Array
      @role = nil
      role_name.each do |rn|
        self.roles.detect do |role|
          if role.name == rn
            @role ||= role
          end
        end
      end
      @role
    else
      roles.detect{|role| role.name == role_name}
    end
  end

  def multiple_users?
    count = Volunteer.volunteers_with_email(self.email)
    if count.length > 1
      true
    else
      false
    end
  end

  def primary_user?
    if Volunteer.primary_user(self.email) == self
      true
    else
      false
    end
  end

  def self.volunteers_with_email(email)
    if email.nil?
      return nil
    end
    logger.info("volunteers_with_email: #{email}")
    # treat email address as case insensitive
    Volunteer.find(:all, :conditions => ["LOWER(email) = ?", email.downcase])
  end

  protected

  def remove_friends
    friends = VolunteerFriend.find(:all, :conditions => ["friend_id = #{id} OR volunteer_id = #{id}"])
    friends.each do |f|
      f.destroy
    end
  end

  def normalize_phone_number
    if phone?
      self.phone.gsub!(/[^\d]/, '').to_i
    end
  end

  def generate_fullname
    # duplicated from Name.rb, but needed it to be stored in DB to do autocomplete
    if middle_initial.blank?
      name_parts = [first_name, last_name]
    else
      name_parts = [first_name, middle_initial, last_name]
    end
    self.fullname = name_parts.compact.join(" ")
  end

  def self.authenticate(email, password)
    volunteer = primary_user(email)
    if volunteer.nil?
      volunteer = primary_user(email.downcase)
    end
    if not volunteer.nil? and volunteer.has_account
      expected_password = encrypted_password(password, volunteer.salt)
      if volunteer.hashed_password != expected_password
        nil
      else
        volunteer
      end
    else
      nil
    end
  end

  # always use the lowest id volunteer for storing the authentication info
  def self.primary_user(email)
    if email.nil?
      volunteer = nil
    else 
      vid = volunteers_with_email(email).map {|ve| ve.id}.min
      begin
        volunteer = Volunteer.find(vid)
      rescue ActiveRecord::RecordNotFound
        logger.error("Attempt to access invalid volunteer " +
                     "#{vid} for email #{email}")
        volunteer = nil
      end
    end
    volunteer
  end

  private

  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

  def self.encrypted_password(password, salt)
    string_to_hash = password + "aMRbgUVL0fTilT" + salt # random string makes it harder to guess
    Digest::SHA1.hexdigest(string_to_hash)
  end

end
