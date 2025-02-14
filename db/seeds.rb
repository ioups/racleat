require 'faker'
require 'net/http'
require 'json'
require 'date'
# require 'open-uri'

# sets Faker with French values
Faker::Config.locale = 'fr'

puts 'Cleaning Racleat database...'
Reservation.destroy_all
puts 'Old reservations removed !'
Device.destroy_all
puts 'Old devices removed !'
User.destroy_all
puts 'Old Cheezers removed !'

streets = []
districts = ['75010', '75011', '75019', '75020']
districts.each do | district |
  url = "https://api-adresse.data.gouv.fr/search/?q=rue&postcode=#{district}&limit=40"
  uri = URI(url)
  response = Net::HTTP.get(uri)
  addresses = JSON.parse(response)
  addresses['features'].each do | item |
    streets << item['properties']['name']
end

end

puts 'Creating Cheezers...'

DEVICES_TYPES = ['Traditionnel', 'Electrique']
CAPACITIES = [2, 4, 6, 8]
STREET_NUMBERS = (1..30).to_a
PRICES = [5, 10, 15]
BRANDS = ['Tefal', 'Moulinex', 'Proline', 'Electrolux']
RANDOM_INT = (0..7).to_a
RANDOM_DURATION = [1, 2]

# Creates some users with raclette devices
30.times do
  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name
  email = Faker::Internet.free_email(name: "#{first_name}.#{last_name}")
  password = Faker::Internet.password(min_length: 10, max_length: 20)
  user = User.new(
    first_name: first_name,
    last_name: last_name,
    email: email,
    password: password
    )
  user.save
  puts "#{first_name} #{last_name} is now a Cheezer !"
  [1, 1, 1, 1, 1, 2].sample.times do
    device_type = DEVICES_TYPES.sample
    capacity = CAPACITIES.sample
    device_name = "Appareil #{device_type} pour #{capacity} personnes"
    address = "#{STREET_NUMBERS.sample} #{streets.sample} Paris"
    brand = BRANDS.sample
    price = PRICES.sample
    device = Device.new(
      name: device_name,
      device_type: device_type,
      capacity: capacity,
      address: address,
      brand: brand,
      price: price,
      user_id: user.id
      )
    device.save
    # file = URI.open('https://media.paruvendu.fr/image/appareil-raclette/WB16/6/3/WB166324881_1.jpeg')
    img_num = (1..9).to_a.sample
    file  = File.open(File.join(Rails.root,"db/seed/raclette#{img_num}.jpg"))
    device.photos.attach(io: file, filename: 'raclette.jpg', content_type: 'image/png')
    puts "#{device_name} is now available !"
  end
end

# Creates users with reservations
5.times do
  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name
  email = Faker::Internet.free_email(name: "#{first_name}.#{last_name}")
  password = Faker::Internet.password(min_length: 10, max_length: 20)
  user = User.new(
    first_name: first_name,
    last_name: last_name,
    email: email,
    password: password
    )
  user.save
  # Now we create a reservation
  start_date = Date.today+RANDOM_INT.sample
  end_date = start_date+RANDOM_DURATION.sample
  duration = (end_date - start_date).to_i
  device = Device.all.sample
  reservation = Reservation.new(
    user_id: user.id,
    device_id: device.id,
    start_date: start_date,
    end_date: end_date,
    total_price: device.price * duration
    )
  reservation.save
  puts "#{first_name} #{last_name} is now a Cheezer with reservation n° #{reservation.id}!"
end




