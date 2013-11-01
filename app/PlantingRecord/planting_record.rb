# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class PlantingRecord
  include Rhom::FixedSchema

  # Uncomment the following line to enable sync with PlantingRecord.
  # enable :sync

  #add model specifc code here
  
  property :PlantingRecordId, :integer
  property :ParentRecordId, :integer
  
  # PlantingType values: 0=Regular Planting, 1=Pot-on, 2=Transplant
  property :PlantingType, :integer
  
  # 0=false, 1=true
  property :IsActiveRecord, :integer
  property :CropName, :string
  property :Year, :integer
  
  # The year in which a perennial crop no longer exists
  property :PerennielClosingYear, :integer
  property :CultivarName, :string
  property :PlantingDate, :date
  property :Location, :string
  property :Amount, :string
  property :Notes, :string
  
  unique_index :by_PlantingRecordId, [:PlantingRecordId]
  index :PlantingRecord_by_CropName, [:CropName]
  index :PlantingRecord_by_Year, [:Year]
  index :PlantingRecord_by_IsActiveRecord, [:IsActiveRecord]
  
  set :schemaversion, "1.0"
    
  # Deletes all input, harvest and sales records associated with this record
  def deleteAssocRecords()
    id = self.PlantingRecordId
    
    # Delete Input records
    inputRecords = InputRecord.find(:all, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => id})
    inputRecords.each do |inputRecord|
      inputRecord.destroy if inputRecord
    end
    
    # Delete Harvest records
    harvestRecords = HarvestRecord.find(:all, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => id})
    harvestRecords.each do |harvestRecord|
      harvestRecord.destroy if harvestRecord
    end
    
    # Delete Sales records
    salesRecords = SalesRecord.find(:all, :conditions => {{:name => "PlantingRecordId", :op => "LIKE"} => id})
    salesRecords.each do |salesRecord|
      salesRecord.destroy if salesRecord
    end
  end    
end