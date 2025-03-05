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

        // Fetch employee and borrower names
        const [empResult] = await db.query(`SELECT FIRSTNAME, LASTNAME FROM employee WHERE ID = ?`, [emp_id]);
        const [borrowerResult] = await db.query(`SELECT FIRSTNAME, LASTNAME FROM employee WHERE ID = ?`, [borrowerId]);

        const empName = empResult.length > 0 ? `${empResult[0].FIRSTNAME} ${empResult[0].LASTNAME}` : `Employee ${emp_id}`;
        const borrowerName = borrowerResult.length > 0 ? `${borrowerResult[0].FIRSTNAME} ${borrowerResult[0].LASTNAME}` : `Borrower ${borrowerId}`;

        // Insert into lending transaction table
        const [result] = await db.query(
            `INSERT INTO borrowing_transaction 
             (item_id, borrower_emp_id, owner_emp_id, quantity, status, createdAt, updatedAt, DPT_ID) 
             VALUES (?, ?, ?, ?, 2, NOW(), NOW(), ?)`,
            [item_id, borrowerId, emp_id, quantity, currentDptId]
        );

        const transactionId = result.insertId;
        console.log(`🎉 Lend Transaction Submitted Successfully! Transaction ID: ${transactionId}`);

        // Fetch item details
        const [itemResult] = await db.query(
            `SELECT name, description, ics, are_no, prop_no, serial_no, pis_no, class_no 
             FROM items WHERE ID = ?`,
            [item_id]
        );

        if (itemResult.length === 0) {
            return res.status(404).json({ message: "Item not found" });
        }

        const item = itemResult[0];

        // ✅ Create Notification Messages
        const adminMessage = `**Subject: Lending Transaction Request**\n\nDear Admin,\n\nMr./Mrs. ${empName} (Employee ID: ${emp_id}) has initiated a lending transaction for Mr./Mrs. ${borrowerName} (Employee ID: ${borrowerId}).\n\n🔹 **Transaction Details:**\n- **Item Name:** ${item.name}\n- **Description:** ${item.description}\n- **Quantity:** ${quantity}\n- **ICS No.:** ${item.ics}\n- **ARE No.:** ${item.are_no}\n- **Property No.:** ${item.prop_no}\n- **Serial No.:** ${item.serial_no}\n- **PIS No.:** ${item.pis_no}\n- **Class No.:** ${item.class_no}\n- **Transaction ID:** ${transactionId}\n\nBest regards,\nLending Management System`;

        const borrowerMessage = `**Subject: Request to Lend Item**\n\nDear Mr./Mrs. ${borrowerName},\n\nMr./Mrs. ${empName} (Employee ID: ${emp_id}) has requested to lend an item to you.\n\n🔹 **Transaction Details:**\n- **Item Name:** ${item.name}\n- **Description:** ${item.description}\n- **Quantity:** ${quantity}\n- **ICS No.:** ${item.ics}\n- **ARE No.:** ${item.are_no}\n- **Property No.:** ${item.prop_no}\n- **Serial No.:** ${item.serial_no}\n- **PIS No.:** ${item.pis_no}\n- **Class No.:** ${item.class_no}\n- **Transaction ID:** ${transactionId}\n\nPlease review the details and proceed accordingly.\n\nBest regards,\nLending Management System`;

        // ✅ **New Notification for the Requester (Lender)**
        const requesterMessage = `**Lending Request Submitted**\n\nDear Mr./Mrs. ${empName},\n\nYour request to lend the following item has been successfully submitted. Please wait for the admin's approval.\n\n🔹 **Item Details:**\n- **Item Name:** ${item.name}\n- **Description:** ${item.description}\n- **Quantity:** ${quantity}\n- **Transaction ID:** ${transactionId}\n\nYou will be notified once the admin reviews your request.\n\nBest regards,\nLending Management System`;

        // ✅ Save Notifications
        const notifications = [
            { message: adminMessage, for_emp: 1, transaction_id: transactionId }, // Admin Notification
            { message: borrowerMessage, for_emp: borrowerId, transaction_id: transactionId }, // Borrower Notification
            { message: requesterMessage, for_emp: emp_id, transaction_id: transactionId } // Requester Notification
        ];

        for (let notif of notifications) {
            await db.query(
                `INSERT INTO notification_tbl (message, for_emp, transaction_id, createdAt, updatedAt) 
                 VALUES (?, ?, ?, NOW(), NOW())`,
                [notif.message, notif.for_emp, notif.transaction_id]
            );            
        }

        console.log("🔔 Notifications saved successfully!");

        // ✅ **Simplified Response**
        res.status(201).json({ 
            message: "Request submitted successfully!", 
            transactionId: transactionId 
        });

    } catch (error) {
        console.error("❌ Error submitting transaction:", error);
        res.status(500).json({ message: "Internal server error" });
    }
});


  
/*router.post("/lend_transaction", async (req, res) => {
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
*/

module.exports = router;
