$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
$:.unshift File.expand_path(File.dirname(__FILE__))

require 'rubygems'
require 'simple_oracle_jdbc'
require 'data_factory'

#interface = DataFactory::DBInterface::Oracle.create('sodonnel', 'sodonnel', 'local11gr2')
interface = SimpleOracleJDBC::Interface.create('sodonnel', 'sodonnel', 'DB12C', '192.168.0.1', '1521')

DataFactory::Base.set_database_interface(interface)

class Foo < DataFactory::Base
  set_table_name "sodonnel.employee"
  set_column_default "FIRST_NAME", 'john'
end


f = Foo.create!("id" => 1001, :date_added => Time.now)
f.column_values.keys.each do |k|
  puts f.column_values[k]
end
