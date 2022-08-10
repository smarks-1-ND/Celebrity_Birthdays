class BdaysController < ApplicationController

  def bdays
    require 'uri'
    require 'net/http'
    require 'openssl'
    require 'json'
    
    
    
    # Grab the month and day from params
    # Call the month function to display month name
    date = "#{params[:date][:month]}-#{params[:date][:day]}"
    @month = month(params[:date][:month])
    db_read_write(date)

  end
  
  # Checks the database to see if data exists for the date
  # If data exists, puts all data into @list
  # else, calls function to retrieve data through API from imdb website
  def db_read_write(date)
    date = "#{params[:date][:month]}-#{params[:date][:day]}"
    in_db = db_read(date)
      if in_db == true
        puts "in_db =  #{in_db}"
        @list = Celeb.where(:bday => date).all

        
       else
        
        to_db = nm_list(date)
        @list = Celeb.where(:bday => date).all
      end
    end
  

  # calls the api to get a list of celebrities born on the date in params
  # The data is cleaned by calling another function called slice and returns clean record
  # The clean record is used in a second api call which pulls in the picutre and bio info for each celebrity
  # Parsing functions clean up the Json data
  # The clean data is written to the database
  
  def nm_list(date) 
    url = URI("https://imdb8.p.rapidapi.com/actors/list-born-today?month=#{params[:date][:month]}&day=#{params[:date][:day]}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request["X-RapidAPI-Host"] = 'imdb8.p.rapidapi.com'
    request["X-RapidAPI-Key"] = ENV["rapid_api"]

    response = http.request(request)
    resp_body = response.read_body
    #puts resp_body
    array = resp_body.split(",")
    array.slice!(0)
    array.each do |record|
    clean_record = slice(record)
    
    bio_full = api_call(clean_record)
    bio_body = JSON.parse(bio_full.read_body)
    
    
    bio_image = image_parse(bio_body)
    bio_text = bio_text_parse(bio_body)

    bio_name = bio_body["name"]
    # puts bio_name
    # puts bio_text
    # puts bio_image
    db_record = db_write(clean_record, bio_name, bio_image, bio_text, date )
    #@list << bio_name << bio_image << bio_text
    end


  end
  

  def slice(dirty_record)
    clean_record =  dirty_record.slice!(7,9)
  end

  def api_call(nm)
    #puts "nm is #{nm}"
    url = URI("https://imdb8.p.rapidapi.com/actors/get-bio?nconst=#{nm}")
  
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  
    request = Net::HTTP::Get.new(url)
    request["X-RapidAPI-Host"] = 'imdb8.p.rapidapi.com'
    request["X-RapidAPI-Key"] = ENV["rapid_api"]
  
    response = http.request(request)

    response
  end

  def image_parse(bio_body)
    #json_file = JSON.parse(bio_body.read_body)
    if bio_body.include? "image"
      image_hash =  bio_body["image"]
    else 
      return image_url = ""
    end
    image_url = image_hash["url"]
    image_url
  end

  def bio_text_parse(bio_body)
    if bio_body.include? "miniBios" 
      text_hash = bio_body["miniBios"]
      text = text_hash[0].to_h
      puts "text of the minibio = #{text["text"]}"
      text["text"]
    else
      return text_hash = ""
    end
  end

  # Checks the database for the data. Writes if it doesn't exist
  def db_write(clean_record, bio_name, bio_image, bio_text, date)
    
    if  Celeb.exists?(nm: [clean_record]) == false
      celeb = Celeb.create(nm: clean_record, name: bio_name, image: bio_image, minibio: bio_text, bday: date)
    else
      puts "#{clean_record} exists"
      celeb = Celeb.find_by(nm: clean_record)
    end
    puts "celeb = #{celeb}"
    return celeb

  end

  def db_read(date)
     
    if Celeb.exists?(bday: [date]) == true
      in_db = true
    in_db
    end
   
  end
  # A hash to display month names
  def month(month_num)
    months = Hash["1" => "January", "2" => "February","3" => "March", "4" => "April", "5" => "May", "6" => "June", "7" => "July", "8" => "August", "9" => "September", "10" => "October", "11" => "November", "12" => "December"]

    month_name = months[month_num]
    month_name
  end
end
