# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class MiscRecord
  include Rhom::FixedSchema

  # Uncomment the following line to enable sync with MiscRecord.
  # enable :sync

  #add model specifc code here
  
  property :MiscRecordId, :integer
  property :PlantingRecordId, :integer
  property :Date, :date
  property :Description, :string
  
  unique_index :miscRecord_by_MiscRecordId, [:MiscRecordId]
  index :miscRecord_by_PlantingRecordId, [:PlantingRecordId]
    
  set :schemaversion, "1.0"
end
