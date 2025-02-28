//filaname: lib/server/lending_transaction.js
const express = require("express");
const router = express.Router();
const db = require("./db");

console.log("lending_transaction.js is running...");

// Fetch borrowers based on current department ID
router.get("/borrowers", async (req, res) => {
    try {
        const { current_dpt_id, query, search_type, emp_id } = req.query;
        console.log("🔍 Received Request:", req.query);

        if (!current_dpt_id || !emp_id) {
            return res.status(400).json({ message: "Missing required parameters" });
        }

        let sqlQuery = `
        SELECT ID AS borrowerId, ID_NUMBER, FIRSTNAME, MIDDLENAME, LASTNAME, SUFFIX 
        FROM employee 
        WHERE CURRENT_DPT_ID = ? 
        AND ID != ?`;


        let params = [current_dpt_id, emp_id];

        if (query) {
            if (search_type === "ID Number") {
                sqlQuery += " AND ID_NUMBER LIKE ?";
                params.push(`%${query}%`);
            } else {
                sqlQuery += " AND CONCAT(FIRSTNAME, ' ', LASTNAME) LIKE ?";
                params.push(`%${query}%`);
            }
        }

        console.log("📢 Executing SQL Query:", sqlQuery, "Params:", params);

        const [borrowers] = await db.query(sqlQuery, params);

        if (borrowers.length === 0) {
            return res.status(404).json({ message: "No borrowers found" });
        }

        console.log("📦 Borrowers Retrieved:", borrowers);
        res.json(borrowers);
    } catch (error) {
        console.error("❌ Error fetching borrowers:", error);
        res.status(500).json({ message: "Internal server error" });
    }
});

// Submit lending transaction (Backend finds borrower_id)
router.post("/lend_transaction", async (req, res) => {
  try {
      const { emp_id, item_id, quantity, borrowerId, currentDptId } = req.body;
      console.log("📩 Received Lending Request:", req.body);

      if (!emp_id || !item_id || !borrowerId || !quantity || !currentDptId) {
          return res.status(400).json({ message: "Missing required parameters" });
      }

      // Insert into lending transaction table
      const [result] = await db.query(
          `INSERT INTO borrowing_transaction 
           (item_id, borrower_emp_id, owner_emp_id, quantity, status, createdAt, updatedAt, DPT_ID) 
           VALUES (?, ?, ?, ?, 2, NOW(), NOW(), ?)`,  
          [item_id, borrowerId, emp_id, quantity, currentDptId] // Added currentDptId
      );

      console.log("🎉 Lend Transaction Submitted Successfully!");
      res.status(201).json({ 
          message: "Request submitted successfully!", 
          transactionId: result.insertId 
      });

  } catch (error) {
      console.error("❌ Error submitting transaction:", error);
      res.status(500).json({ message: "Internal server error" });
  }
});


module.exports = router;
