const express = require('express');
const app = express();
const port = 4000;

// Root route
app.get('/', (req, res) => {
  res.send('Hello from Node.js on AKS!');
});

// About route
app.get('/about', (req, res) => {
  res.send('This is a simple Node.js app running on AKS.');
});

// Users route
app.get('/users', (req, res) => {
  res.send('User list would be displayed here.');
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});
