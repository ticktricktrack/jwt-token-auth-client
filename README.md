### Dependency

run Michs login service https://github.com/octoberclub/passport-tutorial

### Playground fow JWT Authentication and Authorization

`bundle exec rails s` to run the server

- go to http://localhost:3000/rainer
- it will redirect you to the login page
- after logging in, Michs service sets a cookie with the JWT Authentication
- this service checks authentication and permissions, otherwise redirects back to the login page
