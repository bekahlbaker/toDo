var express = require('express');
var bodyParser = require('body-parser');
var app = express();

app.all('/*', function(req, res, next) {
	res.header("Access-Control-Allow-Origin", "*");
	res.header("Access-Control-Allow-Headers", "X-Requested-With", "Content-Type, Accept");
	res.header("Access-Control-Allow-Methods", "POST, GET");
	next();
});

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: false}));

var toDoList = [
{
	item: "Do the dishes."
}
];


//POST
app.post('/toDoItems', function(req, res) {
	var item = req.body;
	if (item) {
		if (item.item) {
			toDoList.push(item);
		} else {
			res.send("You posted invalid data.");
		}
	} else {
		res.send("Your post has no body.");
	}

	console.log(toDoList);
	res.send("You successfully posted a item");
});

//GET
app.get('/toDoItems', function(req, res) {
	console.log("GET from server");
	res.send(toDoList);
});

app.listen(8000);