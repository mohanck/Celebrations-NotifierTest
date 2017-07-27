require 'rubygems' # Unless you install from the tarball or zip.
require 'icalendar'
require 'date'

include Icalendar # Probably do this in your class to limit namespace overlap

require 'net/http'

def get_links
  # Anniversary Feed Link (iCal) from Bamboo
  @anniversary_link = 'https://appfolio.bamboohr.com/feeds/feed.php?id=e0d4eb5ea163290283d650a2b4581ff2'
  # Birthday Feed Link (iCal) from Bamboo
  @birthday_link    = 'https://appfolio.bamboohr.com/feeds/feed.php?id=df99fa6bb8361350db1e6581838ce069'
  @anniversary_file = 'anniversaries.ics'
  @birthday_file    = 'birthdays.ics'
  @appfolio_gmail_file = 'appfolio_gmail_data.json'
  @mycase_gmail_file = 'mycase_gmail_data.json'
  @anniversaries = []
  @birthdays = []
end

def download_files
  File.write(@anniversary_file, Net::HTTP.get(URI.parse(@anniversary_link)))
  File.write(@birthday_file, Net::HTTP.get(URI.parse(@birthday_link)))
end

def construct_array(location, hash_name)
  cal_file = File.open(location)
  cal = Icalendar::Calendar.parse(cal_file).first


  cal.events.each do |e|

    #if e.dtstart == Date.today
    #  puts 'FOUND!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    #  puts e.summary[0..e.summary.index('-')-1].strip
    #end

    #if e.dtstart == Date.today
      event = Hash.new
      event['name'] = ((location == @anniversary_file) ? e.summary[0..e.summary.index('(')-1].strip : e.summary[0..e.summary.index('-')-1].strip)
      event['duration'] = e.summary[e.summary.index('(')+1..e.summary.length-1].strip if location == @anniversary_file
      hash_name.append(event)
    #end
    end

  hash_name.each do |a|
    puts a.inspect
  end

end

def fill_emails(array, file)

end

get_links
download_files
construct_array(@anniversary_file, @anniversaries)
construct_array(@birthday_file, @birthdays)


fill_emails(@anniversaries, @appfolio_gmail_file)
fill_emails(@birthdays, @appfolio_gmail_file)

fill_emails(@anniversaries, @mycase_gmail_file)
fill_emails(@birthdays, @mycase_gmail_file)
