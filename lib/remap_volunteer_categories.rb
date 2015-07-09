# remap volunteer involvement categories to match set columns

sql = "SELECT id, involvement_category FROM volunteers WHERE involvement_category IS NOT NULL"

ActiveRecord::Base.establish_connection
rs = ActiveRecord::Base.connection.execute(sql)

# MAP involvement categories
@involvements = {
  # from              to
  'another program' => 1,
  'community' => 4,
  'environment' => 2,
  'outside' => 3,
  'research' => 5,
}

# for each item, insert an equivalent pair in the volunteer_involvement link table
rs.each do |r|
  id = r['id'].to_i
  involvement_label = r['involvement_category']

  involvement_id = @involvements[involvement_label]
  vi_sql = "INSERT INTO volunteer_involvement (volunteer_id, involvement_id) VALUES (#{id}, #{involvement_id})"

  vi_rs = ActiveRecord::Base.connection.execute(vi_sql)
end
