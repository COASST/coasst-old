class AddVolunteerTestAccount < ActiveRecord::Migration
  def self.up

    #execute("SELECT setval('volunteers_id_seq', (SELECT MAX(id) FROM volunteers), true)")

    test_user = Volunteer.create(
      :email => 'billyblanks@bugmenot.com',
      :first_name => 'Billy',
      :last_name => 'Blanks',
      :middle_initial => 'M',
      :fullname => 'Billy M Blanks',
      :active => true,
      :has_account => true,
      :salt => '814795200.0152127436503323',
      :hashed_password => '66d5d50f33e21043417a313383097b25b8dc2fd8'
    )

    test_partner_user = Volunteer.create(
      :email => 'billyblanks@bugmenot.com',
      :first_name => 'Bobby',
      :last_name => 'Blanks',
      :middle_initial => 'B',
      :fullname => 'Bobby B Blanks',
      :active => true
    )

    volunteer_user = Volunteer.create(
      :email => 'volunteer@bugmenot.com',
      :first_name => 'Volunter',
      :last_name => 'Tester',
      :middle_initial => 'V',
      :fullname => 'Volunteer V Tester',
      :active => true,
      :has_account => true,
      :salt => '814795200.0152127436503323',
      :hashed_password => '66d5d50f33e21043417a313383097b25b8dc2fd8'
    )
    volunteer_user.save!

    intern_user = Volunteer.create(
      :email => 'intern@bugmenot.com',
      :first_name => 'Intern',
      :last_name => 'Tester',
      :middle_initial => 'T',
      :fullname => 'Intern T Tester',
      :active => true,
      :has_account => true,
      :salt => '814795200.0152127436503323',
      :hashed_password => '66d5d50f33e21043417a313383097b25b8dc2fd8'
    )

    verifier_user = Volunteer.create(
      :email => 'verifier@bugmenot.com',
      :first_name => 'Vera',
      :last_name => 'Verifier',
      :middle_initial => 'V',
      :fullname => 'Vera V Verifier',
      :active => true,
      :has_account => true,
      :salt => '814795200.0152127436503323',
      :hashed_password => '66d5d50f33e21043417a313383097b25b8dc2fd8'
    )

    coasst_verifier_user = Volunteer.create(
      :email => 'coasst@u.washington.edu',
      :first_name => 'COASST',
      :last_name => 'Staff',
      :fullname => 'COASST Staff',
      :active => true,
      :has_account => true,
      :salt => '814795200.0152127436503323',
      :hashed_password => 'c1ee76b7a307638cc6293c844f8d287b8de0e649'
    )
    upgrade_user = Volunteer.create(
      :email => 'upgrade@bugmenot.com',
      :first_name => 'Upgrade',
      :last_name => 'Me',
      :fullname => 'Upgrade Me',
      :active => true,
      :has_account => false
    )
    upgrade_user.save!

    new_roles = ['intern', 'verifier'].each do |role|
      r = Role.find_by_name(role)
      if r.blank?
        Role.create(:name => role)
      end
    end

    # give the intern the correct role
    intern_user.roles.push(Role.find_by_name('intern'))

    # give the verifier the correct role
    verifier_role = Role.find_by_name('verifier')
    verifier_user.roles.push(verifier_role)
    coasst_verifier_user.roles.push(verifier_role)

    # insert friends into volunteer_friends mapping
    test_friends = {
      489 => 4,
      189 => 1,
      249 => 1,
      783 => 1,
      419 => 1,
      765 => 1,
    }

    test_friends.each { |friend_id, count|
      vf = VolunteerFriend.new(:volunteer_id => test_user.id, :frequency => count,
             :friend_id => friend_id)
      vf.save!
    }

    # insert beaches into volunteer_beaches mapping
    test_beaches = {
      322 => 5,
      312 => 1,
      215 => 1,
    }

    test_beaches.each { |beach_id, count|
      vb = VolunteerBeach.new(:volunteer_id => test_user.id, :frequency => count,
             :beach_id => beach_id)
      vb.save!
    }

    test_friends.each { |friend_id, count|
      vi = VolunteerFriend.new(:volunteer_id => volunteer_user.id, :frequency => count,
             :friend_id => friend_id)
      vi.save!
    }

    test_beaches.each { |beach_id, count|
      vj = VolunteerBeach.new(:volunteer_id => volunteer_user.id, :frequency => count,
             :beach_id => beach_id)
      vj.save!
    }
  end

  def self.down
    execute("DELETE FROM volunteer_friends WHERE volunteer_id IN (SELECT id FROM volunteers WHERE email LIKE '%bugmenot.com%')");
    execute("DELETE FROM volunteer_beaches WHERE volunteer_id IN (SELECT id FROM volunteers WHERE email LIKE '%bugmenot.com%')");
    execute("DELETE FROM survey_volunteers WHERE volunteer_id IN (SELECT id FROM volunteers WHERE email LIKE '%bugmenot.com%')");
    execute("DELETE FROM roles_volunteers WHERE volunteer_id IN (SELECT id FROM volunteers WHERE email LIKE '%bugmenot.com%')");
    execute("DELETE FROM volunteers WHERE email LIKE '%bugmenot.com%'")

    #def delete_volunteers
    #test_user = Volunteer.find(:first,:conditions => {:email => 'billyblanks@bugmenot.com'})
    #volunteer_user = Volunteer.find(:first, :conditions => {:email => 'intern@bugmenot.com'})
    #intern_user = Volunteer.find(:first, :conditions => {:email => 'intern@bugmenot.com'})

    #if !test_user.blank? && !intern_user.blank? && !volunteer_user.blank?
      # do this with raw SQL instead of a destroy method; the destroy method syncs with the relationships
      # and fails dynamically searching the 'volunteer_beaches' relationship
    #  execute("DELETE FROM volunteer_beaches WHERE volunteer_id IN (#{test_user.id}, #{volunteer_user.id}, #{intern_user.id})")
    #  execute("DELETE FROM volunteer_friends WHERE volunteer_id IN (#{test_user.id}, #{volunteer_user.id}, #{intern_user.id})")
    #  execute("DELETE FROM survey_volunteers WHERE volunteer_id IN (#{test_user.id}, #{volunteer_user.id}, #{intern_user.id})")
    #  execute("DELETE FROM roles_volunteers   WHERE volunteer_id = #{intern_user.id}")
    #  execute("DELETE FROM volunteers WHERE id IN (#{test_user.id}, #{volunteer_user.id}, #{intern_user.id})")
    #end
    #end
  end

end
