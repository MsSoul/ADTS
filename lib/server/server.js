//filename:lib/server/server.js (main node file)
require("dotenv").config(); 
const express = require("express");
const cors = require("cors");
const usersRoutes = require("./users"); 
const itemsRoutes = require("./items");
const borrowTransactionRoutes = require("./borrowing_transaction")


const db = require("./db");  

const app = express();

// Middleware
app.use(express.json());
app.use(cors());

// Routes
app.use("/api/users", usersRoutes);
app.use("/api/items", itemsRoutes);
app.use("/api/borrowTransaction",borrowTransactionRoutes);

// Start Server
const PORT = process.env.PORT; 
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
