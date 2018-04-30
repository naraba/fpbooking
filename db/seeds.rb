# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# financial planner
3.times do |n|
  email = "fp-#{n+1}@example.com"
  password = "password"
  Fp.create!(email: email,
             password: password, password_confirmation: password)
end

# user
10.times do |n|
  email = "user-#{n+1}@example.com"
  password = "password"
  User.create!(email: email,
               password: password, password_confirmation: password)
end

# slot
today = (Time.now.utc - 3.day).change(hour: 10, min: 0, sec: 0)
lastday = today + 1.month
while today <= lastday do
  today = today + 1.day
  weekday = today.wday
  next if weekday == 0

  Fp.all.each do |fp|
    if (fp.id.even? and weekday.even?) ||
      (fp.id.odd? and weekday.odd?)
      stime = today
      while stime.hour < 18 do
        if stime.hour != 12 &&
          ((stime.hour >= 11 and stime.hour <= 14) || weekday != 6)
          fp.slots.create!(start_time: stime, end_time: stime + 30.minutes)
        end
        stime = stime + 30.minutes
      end
    end
  end
end

# additionals
Fp.create!(email: "fp@example.com",
           password: "testtest", password_confirmation: "testtest")
User.create!(email: "user@example.com",
             password: "testtest", password_confirmation: "testtest")
