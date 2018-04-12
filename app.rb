class App < Sinatra::Base

	enable:sessions

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
			redirect('/')
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
			redirect('/website')
		end
		db = SQLite3::Database.new("./db/slutprojekt.db")
		begin 
			a = db.execute("SELECT * FROM users WHERE username IS (?)", [username])[0]
			password_digest = BCrypt::Password.new(a[2])
		rescue
			redirect('/website')
		end
		if a[1] == username && password_digest == password
			session[:user] = true
			session[:username] = username
		else
			session[:user] = false
		end
		redirect('/website')
	end

	get('/website') do
		username = session[:username]
		if session[:user] == true
			user1 = session[:username]
			db = SQLite3::Database.new("./db/slutprojekt.db")
			users = db.execute("SELECT * FROM users WHERE username IS NOT (?)", [user1])
			erb(:website, locals:{users: users})
		else
			session[:error] = "Wrong username or password"
			session[:back] = "/login"
			redirect('/error')
		end
	end   
	
end
