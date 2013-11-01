# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class HarvestRecord
  include Rhom::FixedSchema

  # Uncomment the following line to enable sync with HarvestRecord.
  # enable :sync

  #add model specifc code here
  
  property :HarvestRecordId, :integer
  property :PlantingRecordId, :integer
  property :HarvestDate, :date
  property :HarvestAmount, :float
  
  # This is always the plural name form
  property :HarvestAmountUnit, :string
  property :Notes, :string
  
  unique_index :harvestRecord_by_HarvestRecordId, [:HarvestRecordId]
  index :harvestRecord_by_PlantingRecordId, [:PlantingRecordId]
    
  set :schemaversion, "1.0"
end
