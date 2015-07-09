class AddVolunteerUserAccounts < ActiveRecord::Migration
  def self.up
    vl = [56, 100]
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
      'kalitle@u.washington.edu',   # NO ACCOUNT
      'rbecca@u.washington.edu',    # has account
      'dolliver@u.washington.edu',  # has account
      'jparrish@u.washington.edu',  # has account
      'penech@u.washington.edu',    # has account
      'mary.sue.brancato@noaa.gov', # has account
      'janet.lamont@noaa.gov',      # has account
      'jlt25@u.washington.edu',     # has account
      'penny2@washington.edu',      # has account
      'esmith2@u.washington.edu',   # NO ACCOUNT
      'shorec@u.washington.edu',    # NO ACCOUNT
      'rjestrad@u.washington.edu',  # NO ACCOUNT
      'funisc@u.washington.edu',    # NO ACCOUNT
      'schmidt4@u.washington.edu',  # NO ACCOUNT
      'sstolk10@amherst.edu',       # NO ACCOUNT
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
