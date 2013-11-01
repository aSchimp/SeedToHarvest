# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class Crop
  include Rhom::FixedSchema

  # Uncomment the following line to enable sync with Crop.
  # enable :sync
  
  property :CropName, :string
  property :CropType, :integer
  property :DefaultAmountUnit, :string
  
  unique_index :by_CropName, [:CropName]
    
  set :schemaversion, "1.0"


  #add model specifc code here
end
