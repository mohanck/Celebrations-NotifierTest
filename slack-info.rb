require 'json';

file = File.read('data.json');
data_parsed = JSON.parse(file);
members_data = data_parsed['members'];
members_data.each do |d|
  puts d["profile"]["email"] unless d["profile"]["email"].nil? && d["is_bot"]
end
