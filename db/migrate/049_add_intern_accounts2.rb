class AddInternAccounts2 < ActiveRecord::Migration
  def self.up
    role = Role.find_by_name('intern')
    vl = [1556,1557,1558,1559]
    @@test_password = {
      :active => true,
      :salt   => '814795200.0152127436503323',
      :hashed_password => '66d5d50f33e21043417a313383097b25b8dc2fd8',
    }
    vl.each { |v_id|
      puts "looking for #{v_id}"
      v = Volunteer.find(v_id)
      if !v.nil?
        puts "updating #{v.id}"
        v.update_attributes(@@test_password)
        v.save
        # give the interns the correct role
        v.roles.push(role)
        v.save
      end
    }
  end

  def self.down
  end
end
