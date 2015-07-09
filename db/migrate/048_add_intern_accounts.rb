class AddInternAccounts < ActiveRecord::Migration
  def self.up
    vl = [1365,]
    @@test_password = {
      :active => true,
      :salt   => '359046700.213670561950635',
      :hashed_password => '412d076b6609b47c2bd7745661350f4ed3f30cdb'
    }
    vl.each { |v_id|
      v = Volunteer.find(v_id)
      if !v.nil?
        v.update_attributes(@@test_password)
        v.save
      end
    }

    intern_accounts = [
      'janet.lamont@noaa.gov',
      'John.Barimo@noaa.gov',
      'mary.sue.brancato@noaa.gov',
    ]

    interns = Volunteer.find(:all, :conditions => ['email IN (?)', intern_accounts])
     # give the interns the correct role
    role = Role.find_by_name('intern')
    interns.each do |intern|
      intern.roles.push(role)
    end
  end

  def self.down
  end
end
