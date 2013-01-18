module DataFactory
  module BaseFactory

    # This module implements the class methods of the DataFactory::Base class.
    # These factory methods should be used to generate database records.

    # Builds a new instance of a DataFactory class, inserts it into the database
    # and commits the transaction. The params parameter is expected to be a hash, mapping columns
    # in the underlying table to values. These values will be merged with any
    # defaults set for the columns, and will override the defaults if passed. For example:
    #
    # obj = Employee.create!(:last_name => 'Smith')
    def create!(params)
      df = create(params)
      df.commit
      df
    end

    # Same as the create! method, only the transaction is not committed on the database.
    # For example:
    #
    # obj = Employee.create(:last_name => 'Smith')
    def create(params)
      df = build(params)
      df.generate_insert
      df.run_insert
      df
    end

    # Builds and returns a new instance of a DataFactory class, but does not insert it
    # into the database. For example:
    #
    # obj = Employee.build(:last_name => 'Smith')
    def build(params)
      df = self.new
      df.generate_column_data(params)
      df
    end

  end
end
