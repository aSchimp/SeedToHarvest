# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class Field
  include Rhom::FixedSchema

  # Uncomment the following line to enable sync with Field.
  # enable :sync

  #add model specifc code here
  
  property :FieldName, :string
  property :FieldDescription, :string
  property :Sections, :string
  
  unique_index :field_by_FieldName, [:FieldName]
    
  set :schemaversion, "1.0"
end
