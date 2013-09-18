require 'helper'

class BaseAPITest < Test::Unit::TestCase

  include TestHelper

  def setup
    @klass = Class.new
    @klass.extend DataFactory::BaseDSL
    @dbinterface = DBInterfaceMock.new
    @klass.set_database_interface(@dbinterface)
    @klass.set_table_name('foobar')
    @klass.send :include, DataFactory::BaseAPI
  end

  def teardown
  end

  def test_exception_if_table_name_not_set
    klass = Class.new
    klass.extend DataFactory::BaseDSL
    dbinterface = DBInterfaceMock.new
    klass.set_database_interface(dbinterface)
    klass.send :include, DataFactory::BaseAPI
    assert_raises DataFactory::TableNotSet do
      instance = klass.new
    end
  end

  def test_table_name_can_be_retrieved
    instance = @klass.new
    assert_equal('FOOBAR', instance.table_name)
  end

  def test_column_default_is_retrieved
    @klass.set_column_default('COL1', 'abcd')
    instance = @klass.new
    assert_equal('abcd', instance.column_default('COL1'))
  end

  def test_column_default_is_nil_if_not_set
    instance = @klass.new
    assert_equal(nil, instance.column_default('COL1'))
  end

  def test_column_default_hash_is_retrieved
    @klass.set_column_default('COL1', 'abcd')
    instance = @klass.new
    assert(instance.column_defaults.is_a?(Hash))
    assert_equal('abcd', instance.column_defaults['COL1'])
  end

  def test_empty_default_hash_retrieved_if_no_defaults
    instance = @klass.new
    assert(instance.column_defaults.is_a?(Hash))
    assert_equal(0, instance.column_defaults.keys.length)
  end

  def test_column_detail_is_retrieved
    instance = @klass.new
    assert(instance.column_detail('COL1').is_a? DataFactory::Column)
    assert_equal('COL1', instance.column_detail('COL1').column_name)
  end

  def test_exception_raised_if_column_not_in_table
    instance = @klass.new
    assert_raises DataFactory::ColumnNotInTable do
      instance.column_detail('not exist')
    end
  end

  def test_column_detail_hash_retrieved
    instance = @klass.new
    assert(instance.column_details.is_a? Hash)
    assert_equal('COL1', instance.column_details['COL1'].column_name)
  end

  def test_db_interface_returned
    instance = @klass.new
    assert_equal(@dbinterface, instance.db_interface)
  end

  def test_commit_called_on_db_interface
    # Mocha will raise an exception if the commit method is not invoked
    instance = @klass.new
    @dbinterface.expects(:commit).at_least_once
    instance.commit
  end

  def test_column_value_returns_nil_when_not_generated
    instance = @klass.new
    assert_equal(nil, instance.column_value('COL1'))
  end

  def test_execption_raised_for_column_value_when_not_in_table
    instance = @klass.new
    assert_raises DataFactory::ColumnNotInTable do
      instance.column_value('NOTTHERE')
    end
  end

  def test_generate_data_generates_nil_if_column_nullable
    instance = @klass.new
    instance.generate_column_data
    assert_nil(instance.column_value('COL1'))
  end

  def test_generate_data_generates_nil_if_column_nullable_unless_populate_nullable_columns_is_true
    @klass.set_populate_nullable_columns
    instance = @klass.new
    instance.generate_column_data
    assert_not_nil(instance.column_value('COL1'))
  end


  def test_generate_data_generates_column_data_if_column_not_nullable
    instance = @klass.new
    instance.generate_column_data
    assert_not_nil(instance.column_value('COL4'))
  end

  def test_generate_data_default_used_for_column_when_present
    @klass.set_column_default :col1, 'PRESET'
    instance = @klass.new
    instance.generate_column_data
    assert_equal('PRESET', instance.column_value('COL1'))
  end

  def test_generate_data_passed_in_value_overrides_default
    @klass.set_column_default :col1, 'PRESET'
    instance = @klass.new
    instance.generate_column_data(:col1 => 'OVERRIDE')
    assert_equal('OVERRIDE', instance.column_value('COL1'))
  end

  def test_generate_data_raises_exception_when_passed_in_column_not_exist
    instance = @klass.new
    assert_raises DataFactory::ColumnNotInTable do
      instance.generate_column_data(:notexist => 'OVERRIDE')
    end
    # Also ensure the error message contains the column name
    begin
      instance.generate_column_data(:notexist => 'OVERRIDE')
    rescue DataFactory::ColumnNotInTable => e
      assert_match(/NOTEXIST is not in/, e.to_s)
    end
  end


  # TODO - tests for generate insert
  # TODO - tests for




  def test_run_insert_invokes_execute_on_db_interface
    instance = @klass.new
    instance.generate_column_data
    instance.generate_insert
    @dbinterface.expects(:execute_sql).returns(@dbinterface)
    instance.run_insert
  end

end

