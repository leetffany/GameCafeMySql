//jshint esversion: 6
const mysql = require('mysql');
const express = require('express');
const session = require('express-session');
const bodyParser = require('body-parser');
const path = require('path');

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

//app.use(express.bodyParser());

app.use(express.urlencoded({
  extended: true
}));

app.use(express.json());



const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '21737912420Se',
  database: 'gamelounge'
});

//after log in
app.post('/auth', function(request, response) {
  var username = request.body.username;
  var password = request.body.password;
  if (username && password) {
    connection.query('SELECT * FROM STAFF WHERE username = ? AND password = ?', [username, password], function(error, results, fields) {
      if (results.length > 0) {
        request.session.loggedin = true;
        request.session.username = username;
        response.redirect('/success');
      } else {
        request.session.loggedin = false;
        response.redirect('/failure');
      }
      response.end();
    });
  } else {
    //res.sendFile(__dirname + "/login.html");
    response.send('Please enter username and password again');
    response.end();
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
    //res.sendFile(__dirname + "/login.html");
    response.send('Please enter username and password again');
    response.end();
  }
});

//insert an item worked
app.get('/asdf', (request, response)=>{
  let sql = update CUSTOMER SET username = nicerjamie, password = 4321, CustomerID = 123123, FirstName = jamie, MiddleName =K, LastName =Kim, Zip =95826, Street =3305, City = sac, State = ca, Hours = NULL, GameID = NULL, BoothID = NULL where CustomerID =123123;
    connection.query(sql, (err, result) => {
    if (err) throw err;
    console.log("result");
    response.send('An item is inserted!');
  });
});

app.post('/updat', function(request, response) {

  var newusername  = request.body.username;
  var newpassword = request.body.password;
  var newcustomerID = request.body.CustomerID;
  var newfirstName = request.body.FirstName;
  var newmiddleName = request.body.MiddleName;
  var newlastName = request.body.LastName;
  var newzip = request.body.Zip;
  var newstreet = request.body.Street;
  var newcity = request.body.City;
  var newstate = request.body.State;
  var newhours = request.body.Hours;
  var newboothID = request.body.BoothID;

  //will work in phpmyadi
  var sql = `update CUSTOMER
      SET username = 'nicerjamie',
          password = '4321',
          CustomerID = 123123, 
          FirstName = 'jamie',
          MiddleName ='K',
          LastName ='Kim',
          Zip ='95826',
          Street ='3305',
          City = 'sac',
          State = 'ca',
          Hours = NULL,
          GameID = NULL,
          BoothID = NULL
      where CustomerID =123123;`

    connection.query(sql, function (err, result) {
         if (err){
           throw err;
         }else{
          console.log("1 item added. ");
         }
      });
 });





//i want to response with a new page rather than showing a message.
//response.redirect('/addsuccess');
//response.redirect('/addfail');


//after menuitem page
// app.post('/add', function(request, response) {
//
//   var itemID = request.body.ItemID;
//   var name = request.body.Name;
//   var price = request.body.Price;
//   var quantity = request.body.Quantity;
//   var alcohol = request.body.Alcohol;
//   var vegan = request.body.Vegan;
//   var itemType = request.body.ItemType;
//
//   console.log(itemID,name,price,quantity,alcohol,vegan,itemType);
//   var sql = `INSERT INTO MENU_ITEM (ItemID, Name, Price,Quantity, Alcohol, Vegan, ItemType) VALUES (itemID, name, price, quantity, alcohol, vegan, itemType)`
//
//     connection.query(sql, function (err, result) {
//          if (err){
//            throw err;
//          }else{
//           console.log("1 item added. ");
//          }
//       });
//  });
//












// app.post('/update', function(request, response){
//
// });
//
// app.post('/delete', function(request, response){
//
// });




// app.post('/update', function(request, response) {
//
//   var itemID = request.body.ItemID;
//   var name = request.body.Name;
//   var price = request.body.Price;
//   var quantity = request.body.Quantity;
//   var alcohol = request.body.Alcohol;
//   var vegan = request.body.Vegan;
//   var itemType = request.body.ItemType;
//
//   console.log(itemID,price);
//   var sql = `UPDATE MENU_ITEM SET Price = 'price' WHERE ItemID = 'itemID'`
//
//     connection.query(sql, function (err, result) {
//          if (err){
//            throw err;
//          }else{
//           console.log("1 item updated. ");
//          }
//       });
//  });

app.get("/", function(req, res) {
  res.sendFile(__dirname + "/login.html");
});

app.get("/customer", function(req, res) {
  res.sendFile(__dirname + "/customer.html");
});

app.get('/success', function(req, res) {
  res.sendFile(__dirname + "/success.html");
});

app.get('/failure', function(req, res) {
  res.sendFile(__dirname + "/failure.html");
});

app.get('/successcustomer', function(req, res) {
  res.sendFile(__dirname + "/successcustomer.html");
});

app.get('/failurecustomer', function(req, res) {
  res.sendFile(__dirname + "/failurecustomer.html");
});

app.get('/mygamelounge', function(req, res) {
  res.sendFile(__dirname + "/mygamelounge.html");
});

app.get('/mygameloungecustomer', function(req, res) {
  res.sendFile(__dirname + "/mygameloungecustomer.html");
});

app.get('/infoupdate', function(req, res) {
  res.sendFile(__dirname + "/infoupdate.html");
});

app.get('/adding', function(req, res) {
  res.sendFile(__dirname + "/adding.html");
});

app.get('/updating', function(req, res) {
  res.sendFile(__dirname + "/updating.html");
});

app.get('/deleting', function(req, res) {
  res.sendFile(__dirname + "/deleting.html");
});

app.get('/menuitem', function(req, res) {
  res.sendFile(__dirname + "/menuitem.html");
});


app.get('/addsuccess', function(request, response) {
  response.sendFile(__dirname + "/addsuccess.html");
});
app.get('/addfail', function(request, response) {
  response.sendFile(__dirname + "/addfail.html");
});
app.get('/updatesuccess', function(request, response) {
  response.sendFile(__dirname + "/updatesuccess.html");
});
app.get('/updatefail', function(request, response) {
  response.sendFile(__dirname + "/updatefail.html");
});
app.get('/deltesuccess', function(request, response) {
  response.sendFile(__dirname + "/deltesuccess.html");
});
app.get('/deletefail', function(request, response) {
  response.sendFile(__dirname + "/deletefail.html");
});




// app.get('/home', function(request, response) {
// 	if (request.session.loggedin) {
// 		response.send('Welcome back, ' + request.session.username + '!');
// 	} else {
// 		response.send('Staff Only!');
// 	}
// 	response.end();
// });

//click button in success.html then go to mygamelounge
app.post("/success", function(request, response) {
  response.redirect("/mygamelounge");
})

//click tryagain button in failure then go to /
app.post("/failure", function(request, response) {
  response.redirect("/");
})

app.post("/successcustomer", function(request, response) {
  response.redirect("/mygameloungecustomer");
})

//click tryagain button in failure then go to /
app.post("/failurecustomer", function(request, response) {
  response.redirect("/customer");
})

//click menu item button in mygamelounge then go to menuitem.
app.post("/mygamelounge1", function(request, response) {
  response.redirect("/adding");
})

app.post("/mygamelounge2", function(request, response) {
  response.redirect("/updating");
})

app.post("/mygamelounge3", function(request, response) {
  response.redirect("/deleting");
})


app.post("/mygameloungecustomer", function(request, response) {
  response.redirect("/infoupdate");
})



/* now filleld up and pushed add itme button.
trying to add item  */
// app.post("/menuitem", function(req, res){
//   res.redirect("/add");
// })

/*trying to update an item */
//click add item button in menuitem then go to
//addsucess or addfail.
// app.post("/menuitem2", function(request, response) {
//   response.redirect("");
// })

// app.post("/menuitem2", function(request, response) {
//   response.redirect("");
// })
//
// /* trying to delete an itm */
// app.post("/menuitem3", function(request, response) {
//   response.redirect("/delete");
// })


app.post("/addfail", function(request, response) {
  response.redirect("/menuitem");
})
app.post("/updatefail", function(request, response) {
  response.redirect("/menuitem");
})
app.post("/deletefail", function(request, response) {
  response.redirect("/menuitem");
})



app.listen(process.env.PORT || 3000, function() {
  console.log("Server is running on port 3000. ");
});



//api id
//f7bf6d5cc26f1f691ce98dd19519e184-us19

//list id
//3fc253fa9c



// var username  = request.body.username;
// var password = request.body.password;
// var staffID = request.body.StaffID;
// var firstName = request.body.FirstName;
// var middleName = request.body.MiddleName;
// var lastName = request.body.LastName;
// var ssn = request.body.Ssn;
// var superVisorID = request.body.SuperVisorID;
// var payRate = request.body.PayRate;
// var tips = request.body.Tips;
// var bonus = request.body.Bonus;
// var staffType = request.body.StaffType;
