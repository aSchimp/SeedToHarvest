# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class FieldRecord
  include Rhom::FixedSchema

  # Uncomment the following line to enable sync with FieldRecord.
  # enable :sync

  #add model specifc code here
  
  property :FieldRecordId, :integer
  property :FieldName, :string
  property :Section, :string
  property :Date, :date
  property :Year, :integer
  property :Description, :string
  
  unique_index :fieldRecord_by_FieldRecordId, [:FieldRecordId]
  index :fieldRecord_by_FieldName, [:FieldName]
    
  set :schemaversion, "1.0"
end
