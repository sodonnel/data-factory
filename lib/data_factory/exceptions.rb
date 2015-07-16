module DataFactory
  class TableNotSet < Exception; end
  class DatabaseInterfaceNotSet < Exception; end
  class ColumnNotInTable < Exception; end
  class NoInsertStatement < Exception; end
  class TableNotExist < Exception; end
end
