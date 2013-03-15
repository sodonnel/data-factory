require 'helper'

class BaseDSLTest < Test::Unit::TestCase

  include TestHelper

  def setup
    @klass = Class.new
    @klass.extend DataFactory::BaseDSL
  end

  def teardown
  end

  def test_table_name_can_be_set_as_a_class_instance_variable
    @klass.set_table_name('foobar')
    assert_equal('FOOBAR', @klass.table_name)
    assert_equal('FOOBAR', @klass.instance_variable_get('@table_name'))
  end

  def test_table_name_as_symbol_converted_to_string
    @klass.set_table_name(:foobar)
    assert_equal('FOOBAR', @klass.table_name)
  end

  def test_db_interface_is_set_as_a_class_variable
    dbklass = Class.new
    @klass.set_database_interface(dbklass)
    # need to use send here as @@db_interface is a private variable
    assert_equal(dbklass, @klass.send(:class_variable_get, '@@db_interface'))
  end

  def test_set_column_default_value
    @klass.set_column_default("COL1", 'value1')
    assert_equal('value1', @klass.column_default('COL1'))
  end

  def test_set_column_default_as_symbol_converted_to_string
    @klass.set_column_default(:col1, 'value1')
    assert_equal('value1', @klass.column_default('COL1'))
  end

  def test_set_column_default_as_proc
    @klass.set_column_default(:col1) { 'value1' }
    assert_equal('value1', @klass.column_default('COL1'))
  end

  def test_set_column_default_value_as_symbol_converted_to_string
    @klass.set_column_default("COL1", :value1)
    assert_equal('value1', @klass.column_default('COL1'))
  end

  def test_get_column_default_returns_nil_when_not_set
    assert_equal(nil, @klass.column_default('COL1'))
  end

  def test_get_column_default_as_symbol_converted_to_string
    @klass.set_column_default("COL1", 'value1')
    assert_equal('value1', @klass.column_default(:col1))
  end

  def test_load_meta_data_loads_columns
    @klass.set_database_interface(DBInterfaceMock.new)
    @klass.set_table_name(:foobar)
    @klass.load_meta_data
    assert(@klass.column_detail('COL1').is_a?(DataFactory::Column))
    assert_equal('COL1', @klass.column_detail('COL1').column_name)
  end

  def test_load_meta_data_exception_raised_when_table_not_set
    assert_raises DataFactory::TableNotSet do
      @klass.set_database_interface(DBInterfaceMock.new)
      @klass.load_meta_data
    end
  end

  def test_load_meta_data_exception_raised_when_db_interface_not_set
    @klass.set_table_name(:foobar)
    assert_raises DataFactory::DatabaseInterfaceNotSet do
      @klass.load_meta_data
    end
  end

  def test_load_meta_data_raises_exception_when_invalid_column_default_set
    @klass.set_database_interface(DBInterfaceMock.new)
    @klass.set_table_name(:foobar)
    @klass.set_column_default :not_exists, :value1
    assert_raises DataFactory::ColumnNotInTable do
      @klass.load_meta_data
    end
  end

  def test_column_detail_loads_meta_data_if_not_loaded
    @klass.set_database_interface(DBInterfaceMock.new)
    @klass.set_table_name(:foobar)
    assert(@klass.column_detail('COL1').is_a?(DataFactory::Column))
  end

  def test_column_detail_raises_exception_if_column_does_not_exist
    @klass.set_database_interface(DBInterfaceMock.new)
    @klass.set_table_name(:foobar)
    assert_raises DataFactory::ColumnNotInTable do |e|
      assert(@klass.column_detail('COLNOTTHERE').is_a?(DataFactory::Column))
    end
  end

  def test_error_message_contains_column_name_when_column_does_not_exist
    @klass.set_database_interface(DBInterfaceMock.new)
    @klass.set_table_name(:foobar)
    begin
      @klass.column_detail('COLNOTTHERE').is_a?(DataFactory::Column)
    rescue DataFactory::ColumnNotInTable => e
      assert_match(/COLNOTTHERE is not/, e.to_s)
    end
  end

end

