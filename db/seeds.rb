# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create!(email: 'root@root.com', password: 'password')
Layout.create!(width: 5, height: 3, selected: false)
Layout.create!(width: 10, height: 5, selected: true)
Layout.create!(width: 14, height: 6, selected: false)