secrets = require('./secrets')

module.exports =
    WebService:
        prefix: 'localhost'
        port: 3000
    Postgres:
        connection: "postgres://#{secrets.PG.app.username}:#{secrets.PG.app.password}@localhost:5432/platform"
