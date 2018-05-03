module SlutprojektDB
    DB_PATH = './db/slutprojekt.db'

    def db_connect
        db = SQLite3::Database.new(DB_PATH)
        db.results_as_hash = true
        return db
    end

    def get_user username
        db = db_connect()
        result = db.execute("SELECT * FROM users WHERE username IS (?)", [username])
        return result.first
    end

end