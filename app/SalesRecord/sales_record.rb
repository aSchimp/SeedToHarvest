# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class SalesRecord
  include Rhom::FixedSchema

  # Uncomment the following line to enable sync with SalesRecord.
  # enable :sync

  #add model specifc code here
  
  property :SalesRecordId, :integer
  property :PlantingRecordId, :integer
  property :Date, :date
  property :Amount, :float
  # This is always the plural form of the unit name
  property :AmountUnit, :string
  property :Price, :float
  property :Buyer, :string
  property :Notes, :string
  
  unique_index :SalesRecord_by_SalesRecordId, [:SalesRecordId]
  index :SalesRecord_by_PlantingRecordId, [:PlantingRecordId]
    
  set :schemaversion, "1.0"
end
