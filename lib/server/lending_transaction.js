//filaname: lib/server/borrowing_transaction.js
const express = require('express');
const router = express.Router();
const db = require('./db');

console.log("borrowing_transaction.js is running...")

// Fetch borrowers based on current department ID
router.get("/borrowers", async (req, res) => {
    try {
      const { current_dpt_id, query, search_type, emp_id } = req.query; // Get emp_id from request
      console.log("🔍 Received Request:", req.query);
  
      if (!current_dpt_id || !emp_id) {
        return res.status(400).json({ message: "Missing required parameters" });
      }
  
      // Base SQL query with exclusion of logged-in user
      let sqlQuery = `
        SELECT ID, ID_NUMBER, FIRSTNAME, MIDDLENAME, LASTNAME, SUFFIX 
        FROM employee 
        WHERE CURRENT_DPT_ID = ? 
        AND ID != ?`; // Exclude the logged-in user by their emp_id
  
      let params = [current_dpt_id, emp_id];
  
      // Add search conditions if query is provided
      if (query) {
        if (search_type === "ID Number") {
          sqlQuery += " AND ID_NUMBER LIKE ?";
          params.push(`%${query}%`); // Wildcard search
        } else {
          sqlQuery += " AND CONCAT(FIRSTNAME, ' ', LASTNAME) LIKE ?";
          params.push(`%${query}%`); // Wildcard search
        }
      }
  
      console.log("📢 Executing SQL Query:", sqlQuery, "Params:", params);
  
      // Execute the query
      const [borrowers] = await db.query(sqlQuery, params);
  
      console.log("📦 Borrowers Retrieved:", borrowers);
  
      res.json(borrowers);
    } catch (error) {
      console.error("❌ Error fetching borrowers:", error);
      res.status(500).json({ message: "Internal server error" });
    }
  });
  
// Submit borrowing transaction
router.post('/borrow_transaction', async (req, res) => {
    try {
        const { emp_id, item_id, item_name, description, quantity, borrower_id } = req.body;
        
        const [result] = await db.query(
            `INSERT INTO borrowing_transaction (item_id, borrower_emp_id, owner_emp_id, quantity, status, createdAt, updatedAt) 
             VALUES (?, ?, ?, ?, 'pending', NOW(), NOW())`, 
            [item_id, borrower_id, emp_id, quantity]
        );

        res.status(201).json({ message: 'Transaction recorded successfully', transactionId: result.insertId });
    } catch (error) {
        console.error('Error submitting transaction:', error);
        res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router;
