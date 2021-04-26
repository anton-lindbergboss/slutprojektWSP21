require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions
#1. 
# - Kontrollera gems (sinatra, slim, sqlite). Kommer du behöva sessions? Troligen ej, ska endast utföra CRUD på databasen.
# - Se hur Slimfiler är organierade i mappstrukturen. Följer det REST? Hur kallar man på en slimfil i en mapp?

#2. Starta upp applikationen och inspektera koden i Chrome (högerklick>inspect). Hur ser länkarna ut? Finns de som routes i app.rb?

#3. När vi klickar på ett album vill vi även se artisten (inte bara id). Gör ett andra anrop till db och skicka med i locals.

#4. Skapa en sida där vi lägger till nya album för tex Artisten ACDC (ArtistId 1). Hitta gärna på nya namn på skivorna

#5. Skapa funktionalitet för att ta bort album

#6. Skapa funktionalitet för att uppdatera artistinformation


get('/')  do
  slim(:home)
end 

get('/login') do
  slim(:"users/login")
end

post('/login') do
  email = params[:email]
  password = params[:password]
  db = SQLite3::Database.new("db/open_stocks.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM users WHERE email = ?",email).first
  pw_digest = result["pw_digest"]
  user_id = result["user_id"]

  if BCrypt::Password.new(pw_digest) == password
    session[:user_id] = user_id
    redirect('/account')
  else
    "Fel lösenord, försök vänligen igen."
  end
end

get('/account') do
  user_id = session[:user_id].to_i
  db = SQLite3::Database.new("db/open_stocks.db")
  db.results_as_hash = true
  callingemail = db.execute("SELECT email FROM users WHERE user_id = ?", user_id)
  portfolio = db.execute("SELECT * FROM user_stock_relation WHERE user_id = ?", user_id)
  slim(:account, locals:{cemail:callingemail})
end

get('/register') do
  slim(:"users/register")
end

post('/users/new') do
  email=params[:email]
  password=params[:password]
  password_confirm=params[:password_confirm]
  if password == password_confirm
    password_digest = BCrypt::Password.create(password)
    db = SQLite3::Database.new("db/open_stocks.db")
    db.execute("INSERT INTO users(email, pw_digest) VALUES (?,?)", email, password_digest)
    redirect("/stocks")
  else
    "Lösenordet matchar inte! Försök vänligen igen."
  end
end

get('/news') do
  slim(:news)
end

get('/stocks') do
  db = SQLite3::Database.new("db/open_stocks.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM stocks")
  p result
  slim(:"stocks", locals:{stocks:result})
end


post '/stocks' do #Gör att denna lägger till user_stock_relation och att det är omöjligt att göra utan att vara inloggad
  stock_id = params[:stock_id].to_i #Denna rad tror jag inte gör något pga. att post inte ger något i adressen.
  db = SQLite3::Database.new("db/open_stocks.db")
  db.results_as_hash = true
  result = db.execute("SELECT name FROM STOCKS where stock_id=?", stock_id).first
  "Du har nu köpt en aktie."
  #redirect('/stocks/:stock_id/buy')
end

get('/stocks/:stock_id/buy') do #Raden precis över(#redirect('/stocks/:stock_id/buy')) gör denna do onödig.
  slim(:buy)
end

get('/stocks/:stock_id') do
  stock_id = params[:stock_id]
  db = SQLite3::Database.new("db/open_stocks.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM stocks WHERE stock_id=?", stock_id).first
  slim(:"individualstock", locals:{result:result})
end



# post('buystock') do 
#   db = SQLite3::Database.new("db/open_stocks.db")
#   db.results_as_hash = true
#   number_not_sold = db.execute("SELECT stock_id FROM stocks")
#   new_number = number_not_sold - 1
#   db.execute("UPDATE stocks SET price = '#{new_number}' WHERE stock_id = 1")
#   redirect('/stocks')
# end




























# get('/albums') do
#   db = SQLite3::Database.new("db/chinook-crud.db")
#   db.results_as_hash = true
#   result = db.execute("SELECT * FROM albums")
#   p result
#   slim(:"albums/index",locals:{albums:result})
# end

# get('/albums/:id') do
#   id = params[:id].to_i
#   db = SQLite3::Database.new("db/chinook-crud.db")
#   db.results_as_hash = true
#   result = db.execute("SELECT * FROM albums WHERE ArtistId = ?",id).first
#   slim(:"albums/show",locals:{result:result})
# end


