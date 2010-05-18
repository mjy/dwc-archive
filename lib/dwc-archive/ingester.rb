class DarwinCore
  module Ingester
    def read(batch_size = 10000)
      res = []
      errors = []
      index_fix = 1
      args = {:col_sep => @field_separator}
      args.merge!({:quote_char => @quote_character}) if @quote_character != ''
      CSV.open(@file_path, args).each_with_index do |r, i|
        index_fix = 0; next if @ignore_headers && i == 0
        str = r.join('')
        if defined? FasterCSV
          UTF8RGX === str ? res << r : errors << r
        else
          str = str.force_encoding('utf-8')
          str.encoding.name == "UTF-8" && str.valid_encoding? ? res << r : errors << r
        end
        if block_given? && (i + index_fix) % batch_size == 0
          yield [res, errors]
          res = []
          errors = []
        end
      end
      [res, errors]
    end
    
    private
    def get_file_path
      file = @core[:location] || @core[:attributes][:location] || @core[:files][:location]
      File.join(@path, file)
    end

    def get_fields
      @core[:field] = Array(@core[:field]) 
      @core[:field].map {|f| f[:attributes]}
    end

    def get_field_separator
      res = @properties[:fieldsTerminatedBy] || ','
      res = "\t" if res == "\\t"
      res
    end
  end
end
