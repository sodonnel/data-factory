module DataFactory
  class Column

    attr_accessor :column_name, :data_type, :data_length, :data_scale, :data_precision, :position, :nullable

    def initialize
    end

    def nullable?
      nullable
    end

    def to_s
      "#{@column_name} #{@data_type} #{data_length} #{data_scale} #{data_precision} #{position.to_s}"
    end

  end
end
