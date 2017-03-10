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
	id: 1,
	item: "Do the dishes."
},
{
	id: 2,
	item: "Take out the trash."
},
{
	id: 3,
	item: "Do the laundry."
},
{
	id: 4,
	item: "Vacuum the bedroom."
}
];

app.get('/toDoItems', function(req, res) {
	console.log("GET from server");
	res.send(toDoList);
});

app.listen(process.env.PORT || 8000);