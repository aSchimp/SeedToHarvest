# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class GrowingSeason
  include Rhom::FixedSchema

  # Uncomment the following line to enable sync with GrowingSeason.
  # enable :sync

  #add model specifc code here
  
  property :Year, :integer
  
  unique_index :by_Year, [:Year]
    
  set :schemaversion, "1.0"
  
end
