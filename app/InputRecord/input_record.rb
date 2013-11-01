# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class InputRecord
  include Rhom::FixedSchema

  # Uncomment the following line to enable sync with InputRecord.
  # enable :sync

  #add model specifc code here
  
  property :InputRecordId, :integer
  property :PlantingRecordId, :integer
  property :InputDescription, :string
  property :Quantity, :string
  property :InputDate, :date
  property :Notes, :string
  
  unique_index :inputRecord_by_InputRecordId, [:InputRecordId]
  index :inputRecord_by_PlantingRecordId, [:PlantingRecordId]
  
  set :schemaversion, "1.0"
end
