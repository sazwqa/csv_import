class User < ActiveRecord::Base
  
  EXCLUDED_CSV_ATTRIBUTES = ['created_at', 'updated_at']
  TEMP_CSV_PATH = File.join(RAILS_ROOT, 'public')
  
  def User.write_file(file_data)
    File.open(File.join(TEMP_CSV_PATH, file_name), 'wb') {|file| file.write(params[:file].read)}
  end
  
  def User.generate_random_filename
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    returning random_file_name = "" do
      1.upto(8) { |i| random_file_name << chars[rand(chars.size-1)] }
      random_file_name += '.csv'
    end
  end
  
  def User.save_csv_file(file)
    random_file_name = generate_random_filename
    File.open(File.join(TEMP_CSV_PATH, random_file_name), 'wb') {|f| f.write(file.read)}
    random_file_name
  end
  
  def User.remove_csv_file(file)
    File.delete(File.join(TEMP_CSV_PATH, file)) rescue nil
  end
  
  def User.get_csv_headers(file_name)
    # TODO: Any better way to get headers ?
    FasterCSV.parse(File.open(File.join(TEMP_CSV_PATH, file_name))).first
  end
  
  def User.load_csv(file)
    # CHECK FILE
    return [false,'Please select a valid CSV file.'] if file.blank? or file.size == 0
    
    # LOAD FILE
    begin
      random_file_name = save_csv_file(file)
    rescue
      return [false, 'Error loading file, please try again.']
    end
    
    # PARSE HEADERS
    begin
      csv_header = User.get_csv_headers(random_file_name)
    rescue
      return [false, 'Invalid file selected, please select another']
    end
    [csv_header, csv_model_fields, random_file_name]
  end
  
  def User.csv_model_fields
    new.attributes.keys - EXCLUDED_CSV_ATTRIBUTES
  end
  
  def User.create_csv_user(mappings, row)
    user = new
    mappings.each { |csv_field, model_field| user.send("#{model_field}=", row.field(csv_field)) }
    user.save! if user.changed?
  end
  
  def User.clean_mappings(mappings)
    mappings.delete_if {|csv_field, model_field| model_field.blank? or !csv_model_fields.include?(model_field)}
  end
  
  def User.parse_csv(filename, mappings)
    mappings = clean_mappings(mappings)
    old_count = count
    FasterCSV.foreach(File.join(TEMP_CSV_PATH, filename), :headers => :first_row) { |row| User.create_csv_user(mappings, row) }
    remove_csv_file(filename)
    return count - old_count
  end
  
end