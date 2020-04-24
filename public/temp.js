/*
<button class="btn btn-outline-primary" type="button" >Add Item</button>

      </form>

      <form action="/update" method="POST">
        <input type="text" name="ItemID" class="form-control top" placeholder="ItemID" required autofocus>
        <input type="text" name="Name" class="form-control bottom" placeholder="Name" required autofocus>
        <input type="text" name="Price" class="form-control top" placeholder="Price" required autofocus>
        <input type="text" name="Quantity" class="form-control bottom" placeholder="Quantity" required autofocus>
        <input type="text" name="Alcohol" class="form-control top" placeholder="Alcohol" required autofocus>
        <input type="text" name="Vegan" class="form-control bottom" placeholder="Vegan" required autofocus>
        <input type="text" name="ItemType" class="form-control bottom" placeholder="ItemType" required autofocus>
        <button type="button" class="btn btn-outline-secondary">Update Item </button>
        <p></p>
      </form>

      <form action="/delete" method="POST">
        <input type="text" name="ItemID" class="form-control top" placeholder="ItemID" required autofocus>
        <input type="text" name="Name" class="form-control bottom" placeholder="Name" required autofocus>
        <input type="text" name="Price" class="form-control top" placeholder="Price" required autofocus>
        <input type="text" name="Quantity" class="form-control bottom" placeholder="Quantity" required autofocus>
        <input type="text" name="Alcohol" class="form-control top" placeholder="Alcohol" required autofocus>
        <input type="text" name="Vegan" class="form-control bottom" placeholder="Vegan" required autofocus>
        <input type="text" name="ItemType" class="form-control bottom" placeholder="ItemType" required autofocus>
        <button type="button" class="btn btn-outline-warning">Delete Item</button>
        <p></p>
      </form>

*/

//jshint esversion: 6
//const mysql = require('mysql');
const express = require('express');
const session = require('express-session');
const bodyParser = require('body-parser');
const path = require('path');


// const connection = mysql.createConnection({
//   host: 'localhost',
//   user: 'root',
//   password: '21737912420Se',
//   database: 'pcbang'
// });

var Client = require('mysql').Client;
var client = new Client();
client.host ='some.host.com';
client.user = 'user';
client.password = 'password';
console.log("connecting...");
var db = new Promise(function(resolve, reject) {

  ssh.on('ready', function() {
    ssh.forwardOut(
      // source address, this can usually be any valid address
      '127.0.0.1',
      // source port, this can be any valid port number
      12345,
      // destination address (localhost here refers to the SSH server)
      '127.0.0.1',
      // destination port
      3306,
      function(err, stream) {
        if (err) throw err; // SSH error: can also send error in promise ex. reject(err)
        // use `sql` connection as usual
        const connection = mysql.createConnection({
          host: 'localhost',
          user: 'root',
          password: '21737912420Se',
          database: 'pcbang'
        });

        // send connection back in variable depending on success or not
        /*
                connection.connect(function(err) {
                  if (err) {
                    resolve(connection);
                  } else {
                    reject(err);
                  }
                });
                */
        connection.connect((err) => {
          if (err) {
            throw err;
          }
          console.log("Mysql conneceted ...");
        });
      });
  }).connect({
    host: 'athena.csus.edu',
    port: 22,
    username: 'kimja', //maps to html
    password: 'qvhabfxm'
  });
});


exports.getConnection = function(callback) {
  pool.getConnection(function(err, conn) {
    if (err) {
      console.log('error..')
      return callback(err);
    }
    callback(err, conn);
  });
};


module.exports = db;

// connection.connect((err) => {
//   if (err) {
//     throw err;
//   }
//   console.log("Mysql conneceted ...");
// });

const app = express();
//want static folder css in even remote
app.use(express.static("public"));
app.use(session({
  secret: 'secret',
  resave: true,
  saveUninitialized: true
}));
app.use(bodyParser.urlencoded({
  extended: true
}));
app.use(bodyParser.json());


const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '21737912420Se',
  database: 'pcbang'
});
//create db

  app.get("/", function(req, res) {

    let sql = 'CREATE DATABASE pcbang';
    connection.query(sql, (err, result) => {
      if (err) throw err;
      console.log(result);
      res.send('Databased pcbang created');
      res.sendFile(__dirname + "/login.html");

    });
  });


//crete table
// app.get('/auth', (req, res) => {
//   let sql = 'CREATE TABLE ACCOUNTS(id int AUTO_INCREMENT NOT NULL, username VARCHAR(50) NOT NULL,password varchar(255) NOT NULL, email VARCHAR(100) NOT NULL, PRIMARY KEY (id))';
//   db.query(sql, (err, result) => {
//     if (err) throw err;
//     console.log(result);
//     res.send('ACCOUNTS table created');
//   });
// });

/*
app.post('/auth', function(request, response) {
	var username = request.body.username;
	var password = request.body.password;
	if (username && password) {
		connection.query('SELECT * FROM accounts WHERE username = ? AND password = ?', [username, password], function(error, results, fields) {
			if (results.length > 0) {
				request.session.loggedin = true;
				request.session.username = username;
				response.redirect('/home');
			} else {
				response.send('Incorrect Username and/or Password!');
			}
			response.end();
		});
	} else {
		response.send('Please enter Username and Password!');
		response.end();
	}
});

app.get('/home', function(request, response) {
	if (request.session.loggedin) {
		response.send('Welcome back, ' + request.session.username + '!');
	} else {
		response.send('Please login to view this page!');
	}
	response.end();
});
*/
app.listen(3000);
//api id
//f7bf6d5cc26f1f691ce98dd19519e184-us19

//list id
//3fc253fa9c
