# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class AmountUnit
  include Rhom::FixedSchema

  # Uncomment the following line to enable sync with AmountUnit.
  # enable :sync

  #add model specifc code here
  
  property :UnitName, :string
  property :UnitNamePlural, :string
  
  unique_index :amountUnit_by_UnitName, [:UnitName]
    
  set :schemaversion, "1.0"
end
