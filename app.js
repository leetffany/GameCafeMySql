//jshint esversion: 6
const mysql = require('mysql');
const express = require('express');
const session = require('express-session');
const bodyParser = require('body-parser');
const path = require('path');

const app = express();
//want static folder css in even remote
app.use(express.static("public"));

app.use(bodyParser.urlencoded({
  extended: true
}));

const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '21737912420Se',
  database: 'gamelounge'
});

//register insert into customer
app.post('/signup', function(request, response) {
  var username = request.body.username;
  var password = request.body.password;
  var customerID = request.body.CustomerID
  var firstname = request.body.Firstname;
  var middlename = request.body.Middlename;
  var lastname = request.body.Lastname;
  var zip = request.body.Zip;
  var street = request.body.Street;
  var city = request.body.City;
  var state = request.body.State;


  if(username && password && customerID){
    connection.query('INSERT INTO CUSTOMER  SET ?',
    {username:username,
      password:password,
      CustomerID:customerID,
      Firstname:firstname,
      Middlename:middlename,
      Lastname:lastname,
      Zip: zip,
      Street: street,
      City: city,
      State: state
    }, function(err, results, fields) {

      if (!err) {
        response.redirect('/signupsuccess');
      } else {
      console.log(err);
      response.redirect('/signupfailure');
      }
      response.end();
    });
  } else {

    response.send("your username and password is varchar type and customer id is integer. ");
  }
});


//
app.post('/authcustomer', function(request, response) {
  var username = request.body.username;
  var password = request.body.password;
  if (username && password) {
    connection.query('SELECT * FROM CUSTOMER WHERE username = ? AND password = ?', [username, password], function(error, results, fields) {
      if (results.length > 0) {
        request.session.loggedin = true;
        request.session.username = username;
        response.redirect('/successcustomer');
      } else {
        request.session.loggedin = false;
        response.redirect('/failurecustomer');
      }
      response.end();
    });
  } else {
    response.send('Please enter username and password.');
    response.end();
  }
});

app.post('/updatun', function(request, response) {
  var currCustomerID = request.body.currCustomerID;
  var newusername = request.body.username;
  var newpassword = request.body.password;
  /* CUSTOMER wants to update theirusername*/
  //connection.query('UPDATE users SET ? WHERE UserID = ?', [{ Name: name }, userId])
  if (newusername) {
    connection.query('UPDATE CUSTOMER SET ? WHERE CustomerID = ?', [{
      username: newusername
    }, currCustomerID], function(err, results) {

      if (!err) {
        response.send("Hey " + currCustomerID + ", your username successfully updated to " + newusername + "! " + results.affectedRows + " record(s) updated in CUSTOMER table and inserted into MEMBERS_VIEW table.");
      } else {
        response.send("something gone wrong, try again.")
      }
      response.end();
    });
  } else {
    response.send('Please enter your customerid and new username.');
    response.end();
  }
});



app.post('/updatp', function(request, response) {
  var currCustomerID = request.body.currCustomerID;
  var newpassword = request.body.password;
  if (newpassword) {
    connection.query('UPDATE CUSTOMER SET ? WHERE CustomerID = ?', [{
      password: newpassword
    }, currCustomerID], function(err, results, fields) {
      if (!err) {
        response.send("Hey " + currCustomerID + ", your password successfully updated!  " + results.affectedRows + " record(s) updated in CUSTOMER table and inserted into MEMBERS_VIEW table.");


      } else {
        response.send("something gone wrong, try again.")
      }
      response.end();
    });
  } else {
    response.send('Please enter new password.');
    response.end();
  }
});

app.post('/menu', (request, response) => {
  let sql = 'SELECT ItemID, Name, Price, Alcohol, Vegan FROM MENU_ITEM';

  connection.query(sql, (err, results, fields) => {

    if (!err) {
      response.send(results);
      console.log(results);
    } else {
      throw err;
    }
  });
});


app.post('/order', function(request, response) {
  var customerID = request.body.CustomerID
  var ordernumber = 1;
  var cost = 1 ;
  var payment =1 ;
  var itemID = request.body.ItemID;
  if(customerID && itemID){
    connection.query('INSERT INTO CUSTOMER_ORDER  SET ?',
    {OCustomerID:customerID, OrderNum:ordernumber, Cost:cost, Payment:payment}, function(err, results, fields) {

      if (!err) {

        response.send("" + results.affectedRows + " record(s) inserted into CUSTOMER_ORDER table.");
      } else {
        response.send(err);
      }
      response.end();
    });
  } else {
    response.send('Please check your customerid and/or itemid.');
    response.end();
  }
});


app.get("/", function(req, res) {
  res.sendFile(__dirname + "/signup.html");
});

app.get("/login", function(req, res) {
  res.sendFile(__dirname + "/login.html");
});

app.get('/successcustomer', function(req, res) {
  res.sendFile(__dirname + "/successcustomer.html");
});

app.get('/failurecustomer', function(req, res) {
  res.sendFile(__dirname + "/failurecustomer.html");
});

app.get("/signupsuccess", function(req, res) {
  res.sendFile(__dirname + "/signupsuccess.html");
})

//click tryagain button in failure then go to /
app.get("/signupfailure", function(req, res) {
  res.sendFile(__dirname + "/signupfailure.html");
})

app.get('/mygameloungecustomer', function(req, res) {
  res.sendFile(__dirname + "/mygameloungecustomer.html");
});

app.get('/updateusername', function(req, res) {
  res.sendFile(__dirname + "/updateusername.html");
})

app.get('/updatepassword', function(req, res) {
  res.sendFile(__dirname + "/updatepassword.html");
})





app.post("/successcustomer", function(request, response) {
  response.redirect("/mygameloungecustomer");
})

//click try again button in failurecustomer then go to main/
app.post("/failurecustomer", function(request, response) {
  response.redirect("/login");
})

app.post("/login", function(request, response){
  response.redirect("/login");
})

//click go to log in.
app.post("/signupsuccess", function(request, response) {
  response.redirect("/login");
})

//click tryagain button in failure then go to /
app.post("/signupfailure", function(request, response) {
  response.redirect("/");
})

//click forgot my username button in customer then go to updateusername.html.
app.post("/customerlogin", function(request, response) {
  response.redirect("/updateusername");
})

app.post("/customerpassword", function(request, response) {
  response.redirect("/updatepassword");
})



app.listen(process.env.PORT || 3000, function() {
  console.log("Server is running on port 3000. ");
});
