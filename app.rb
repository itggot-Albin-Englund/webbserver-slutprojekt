require_relative './model/model'
class App < Sinatra::Base

	enable:sessions
	include SlutprojektDB

	get('/error') do
		error = session[:error]
		back = session[:back]
		a = [error, back]
		erb(:error, locals:{a: a})
    end

	get('/') do	
	    session[:user] = false	
		erb(:index)
	end

	get('/register') do
		erb(:register)
	end

	post('/register') do
		username = params[:username]
		password = params[:password]
		re_password = params[:re_password]
		phone = params[:phone]
		if username == "" or password == "" or re_password == "" or phone == ""
			session[:error] = "Username, password or phone number is not filled in"
			session[:back] = "/register"
			redirect('/error')

		elsif username.length > 21 or phone.length > 21 
			session[:error] = "Username or phone number is too long(maximum 20 digits)"
			session[:back] = "/register"
			redirect('/error')

		end

		
		if password == re_password
			password_digest = BCrypt::Password.create(password)
			db = SQLite3::Database.new("./db/slutprojekt.db")
			begin
				db.execute("INSERT INTO users (username, password, phone) VALUES (?,?,?)", [username, password_digest, phone])
			rescue
				session[:error] = "Username has already been used"
				session[:back] = "/register"
				redirect('/error')
			end
			redirect('/login')
		else
			session[:error] = "Passwords not the same"
			redirect('/error')
		end
	end

	get('/login') do
		erb(:login)
	end

	post('/login') do
		session[:user] = false
		username = params[:username]
		password = params[:password]
		if username == "" or password == ""
			redirect('/contacts')
		end

		begin 
			user = get_user(username)
			password_digest = BCrypt::Password.new(user[2])
		rescue
			redirect('/contacts')
		end
		if user[1] == username && password_digest == password
			session[:user] = true
			session[:username] = username
		else
			session[:user] = false
		end
		redirect('/contacts')
	end

	get('/contacts') do
		username = session[:username]
		if session[:user] == true
			user1 = session[:username]
			db = SQLite3::Database.new("./db/slutprojekt.db")
			users = db.execute("SELECT * FROM users WHERE username IS NOT (?)", [user1])
			erb(:contacts, locals:{users: users})
		else
			session[:error] = "Wrong username or password"
			session[:back] = "/login"
			redirect('/error')
		end
	end  

	
	
	get('/favorites') do
		username = session[:username]
		if session[:user] == true
			user1 = session[:username]
			db = SQLite3::Database.new("./db/slutprojekt.db")
			user1_id = db.execute("SELECT id FROM users WHERE username IS (?)", [user1])
			user1_id = user1_id[0]
			# users = db.execute("SELECT favorite_id FROM favorites WHERE user_id IS (?)", [user1_id]
			users = db.execute("SELECT * FROM users WHERE id IN (SELECT favorite_id FROM favorites WHERE user_id IS (?))", [user1_id])

			erb(:favorites, locals:{users: users})
		else
			session[:error] = "Something went wrong :(("
			session[:back] = "/login"
			redirect('/error')
		end
	end

	post('/add-favorite') do
	
		if session[:user] == true
			user1 = session[:username]
			db = SQLite3::Database.new("./db/slutprojekt.db")
			user1_id = db.execute("SELECT id FROM users WHERE username IS (?)", [user1])
			user1_id = user1_id[0]
			favorite_id = params[:favorite_id]
			db.execute("INSERT INTO favorites (user_id, favorite_id) VALUES (?,?)", [user1_id, favorite_id])

			redirect('/favorites')
		else
			session[:error] = "Something went wrong :(("
			session[:back] = "/login"
			redirect('/error')
		end

	end

	post('/remove-favorite') do
	
		if session[:user] == true
			user1 = session[:username]
			db = SQLite3::Database.new("./db/slutprojekt.db")
			user1_id = db.execute("SELECT id FROM users WHERE username IS (?)", [user1])
			user1_id = user1_id[0]
			favorite_id = params[:favorite_id]
			db.execute("DELETE FROM favorites WHERE (user_id=? AND favorite_id=?)", [user1_id, favorite_id])

			redirect('/favorites')
		else
			session[:error] = "Something went wrong :(("
			session[:back] = "/login"
			redirect('/error')
		end

	end
	
end
