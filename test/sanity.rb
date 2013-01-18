$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
$:.unshift File.expand_path(File.dirname(__FILE__))

require 'rubygems'
require 'simple_oracle_jdbc'
require 'data_factory'

#interface = DataFactory::DBInterface::Oracle.create('sodonnel', 'sodonnel', 'local11gr2')
interface = SimpleOracleJDBC::Interface.create('sodonnel', 'sodonnel', 'local11gr2.world', 'localhost', '1521')

DataFactory::Base.set_database_interface(interface)

class Foo < DataFactory::Base
  set_table_name "employees"
  set_column_default "EMP_NAME", 'john'
end


f = Foo.create!("emp_id" => 1001)
f.column_values.keys.each do |k|
  puts f.column_values[k]
end
