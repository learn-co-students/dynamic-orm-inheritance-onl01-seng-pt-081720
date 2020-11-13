require_relative "../config/environment.rb"
require 'active_support/inflector'  #need this to use the method "pluralize"

class InteractiveRecord
 
  # this method creates the table name. the method 'plurize' add an s to end of name
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true    #checking if what we get is a hash

    sql = "pragma table_info('#{table_name}')"  #his will call for to get hash w/table name

    table_info = DB[:conn].execute(sql) #executes the sql and setting the info of the hash into that variable.
    column_names = [] #setting an empty array to inseret the info want. 
    table_info.each do |row|  #using the each method here because we want to itrate over this hash. dont really want to change the changes we do
      column_names << row["name"]  ## this is picking the stuff we want from the row into clmns
    end
    column_names.compact #doing compact to not have nil values. and returning column names info not an empty array.
  end

  def initialize(options={})  
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

def self.find_by_name(name)
  sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
  DB[:conn].execute(sql, name)
end

end
