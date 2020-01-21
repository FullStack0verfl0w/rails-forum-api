class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  
  def self.escape_sql(array)
    self.send(:sanitize_sql_array, array)
  end
end
