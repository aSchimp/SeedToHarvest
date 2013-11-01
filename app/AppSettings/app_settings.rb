# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class AppSettings
  include Rhom::FixedSchema

  # Uncomment the following line to enable sync with AppSettings.
  # enable :sync

  #add model specifc code here
  
  property :selectedSeasonYear, :integer
  
  # Farm info properties
  property :FarmName, :string
  property :FarmOwner, :string
  property :FarmAddress1, :string
  property :FarmAddress2, :string
  property :FarmCity, :string
  property :FarmState, :string
  property :FarmZipCode, :string
  property :FarmRecordManager, :string
  property :FarmEmail, :string
  property :FarmPhone, :string
  property :FarmWebsite, :string
  
  property :reportIncludeFarmInfo, :string
  
  set :schemaversion, "1.0"

end
