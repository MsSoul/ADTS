//filename:lib/server/borrowing_transaction.js
const express = require("express");
const router = express.Router();
const db = require("./db");

console.log("borrowing_transaction.js is running...");

router.get("/:currentDptId/:empId", async (req, res) => {
    const currentDptId = Number(req.params.currentDptId);
    const empId = Number(req.params.empId);

    if (isNaN(currentDptId)) {
        console.warn("❌ Invalid or missing currentDptId parameter.");
        return res.status(400).json({ error: "Invalid currentDptId parameter." });
    }

    if (isNaN(empId)) {
        console.warn("❌ Invalid or missing empId parameter.");
        return res.status(400).json({ error: "Invalid empId parameter." });
    }

    console.log(`🔍 Fetching items for department_id: ${currentDptId}, excluding employee ID: ${empId}...`);

    try {
        // SQL query to join items with employee table and exclude the given empId
        const query = `
            SELECT 
                i.*, 
                e.FIRSTNAME, 
                e.MIDDLENAME, 
                e.LASTNAME, 
                e.SUFFIX,
                TRIM(CONCAT(e.FIRSTNAME, ' ', 
                            COALESCE(e.MIDDLENAME, ''), ' ', 
                            e.LASTNAME, ' ', 
                            COALESCE(e.SUFFIX, ''))) AS accountable_name
            FROM distributed_items i
            LEFT JOIN employee e ON i.accountable_emp = e.ID
            WHERE i.current_dpt_id = ? 
            AND i.deleted = 0
            AND i.accountable_emp != ?  -- Exclude the given empId
        `;

        console.log(`📝 SQL Query: ${query}`);

        const [rows] = await db.query(query, [currentDptId, empId]);

        console.log(`✅ Total items fetched (excluding empId ${empId}): ${rows.length}`);

        return res.status(200).json({ items: rows });
    } catch (error) {
        console.error("❌ Database error:", error);
        return res.status(500).json({ error: "Server error. Please try again later." });
    }
});

//filename:lib/server/borrowing_transaction.js
router.get("/:empId", async (req, res) => {
    try {
        const empId = parseInt(req.params.empId, 10); 

        if (isNaN(empId)) {
            console.warn("❌ Invalid or missing empId parameter.");
            return res.status(400).json({ error: "Invalid empId parameter." });
        }

        console.log(`🔍 Fetching userName for employee ID: ${empId}`);

        const [rows] = await db.query(
            "SELECT FIRSTNAME, MIDDLENAME, LASTNAME, SUFFIX FROM employee WHERE ID = ?",
            [empId]
        );

        if (rows.length === 0) {
            console.warn(`⚠ Employee ID ${empId} not found.`);
            return res.status(404).json({ error: "User not found" });
        }

        const { FIRSTNAME, MIDDLENAME, LASTNAME, SUFFIX } = rows[0];

        // Construct full name including suffix
        const userName = [FIRSTNAME, MIDDLENAME, LASTNAME, SUFFIX]
            .filter(name => name && name.trim() !== '') 
            .map(name => name.trim())  
            .join(". ");  

        console.log(`✅ User Name: ${userName}`);

        res.json({ userName });
    } catch (error) {
        console.error("❌ Error fetching user:", error);
        res.status(500).json({ error: "Server error" });
    }
});

// Borrow an item with notifications
router.post("/borrow", async (req, res) => {
    try {
        console.log("📥 Received borrow request:", req.body);

        const { borrower_emp_id, owner_emp_id, distributedItemId, quantity, DPT_ID } = req.body;

        if (!borrower_emp_id || !owner_emp_id || !distributedItemId || quantity === undefined || quantity === null || !DPT_ID) {
            return res.status(400).json({ error: "Missing required fields" });
        }

        if (typeof quantity !== 'number' || isNaN(quantity)) {
            return res.status(400).json({ error: "Invalid quantity provided" });
        }
        console.log(`Received quantity: ${quantity}`);
        console.log(`🔄 Processing borrow request: Borrower ${borrower_emp_id}, Item ${distributedItemId}`);

        // Function to capitalize first letter of each word
        const capitalizeName = (name) => {
            return name.toLowerCase().replace(/\b\w/g, (char) => char.toUpperCase());
        };

        // Fetch employee and borrower names
        const [borrowerResult] = await db.query("SELECT FIRSTNAME, LASTNAME FROM employee WHERE ID = ?", [borrower_emp_id]);
        const [ownerResult] = await db.query("SELECT FIRSTNAME, LASTNAME FROM employee WHERE ID = ?", [owner_emp_id]);

        const borrowerFirstName = borrowerResult.length > 0 ? capitalizeName(borrowerResult[0].FIRSTNAME) : `Employee ${borrower_emp_id}`;
        const borrowerLastName = borrowerResult.length > 0 ? capitalizeName(borrowerResult[0].LASTNAME) : "";
        const borrowerName = `${borrowerFirstName} ${borrowerLastName}`.trim();

        const ownerFirstName = ownerResult.length > 0 ? capitalizeName(ownerResult[0].FIRSTNAME) : `Employee ${owner_emp_id}`;
        const ownerLastName = ownerResult.length > 0 ? capitalizeName(ownerResult[0].LASTNAME) : "";
        const ownerName = `${ownerFirstName} ${ownerLastName}`.trim();

        // Fetch item details
        const [itemResult] = await db.query(
            `SELECT name, description, quantity, accountable_emp, ics, are_no, prop_no, serial_no, pis_no, class_no 
             FROM distributed_items WHERE id = ?`,
            [distributedItemId]
        );

        if (itemResult.length === 0) {
            return res.status(404).json({ error: "Item not found" });
        }

        const { name, description, quantity: available_quantity, accountable_emp, ics, are_no, prop_no, serial_no, pis_no, class_no } = itemResult[0];

        // Validate owner
        if (accountable_emp !== owner_emp_id) {
            return res.status(400).json({ error: "Invalid owner for this item" });
        }

        // Validate quantity
        if (quantity > available_quantity) {
            return res.status(400).json({ error: "Not enough stock available" });
        }

        // Insert borrow transaction
        const [insertResult] = await db.query(
            "INSERT INTO borrowing_transaction (distributed_item_id, borrower_emp_id, owner_emp_id, quantity, DPT_ID, createdAt, updatedAt, status) VALUES (?, ?, ?, ?, ?, NOW(), NOW(), 2)",
            [distributedItemId, borrower_emp_id, owner_emp_id, quantity, DPT_ID]
        );

        const transactionId = insertResult.insertId;

        console.log(`✅ Borrow transaction successful: Transaction ID ${transactionId}`);

        // Notifications
        const itemDetails = `🔹 Item Details:\nItem Name: ${name}\nDescription: ${description}\nQuantity: ${quantity}\nICS No.: ${ics}\nARE No.: ${are_no}\nProperty No.: ${prop_no}\nSerial No.: ${serial_no}\nPIS No.: ${pis_no}\nClass No.: ${class_no}`;

        const adminMessage = `**Subject:Borrow Item Request**\nFrom: ${borrowerName}\n\n${borrowerName} has requested to borrow an item.\n\n${itemDetails}`;

        const ownerMessage = `**Subject:Borrow Item Request**\nDear ${ownerName},\n\n${borrowerName} has requested to borrow your item.\n\n${itemDetails}`;
        const borrowerMessage = `*Subject:Borrow Item Request**\n\nDear ${borrowerName},\n\nYour request to borrow the following item has been submitted successfully.\n\n${itemDetails}\n\nPlease wait for the admin's approval.`;

        // Save Notifications
        const notifications = [
            { message: adminMessage, for_emp: 1, transaction_id: transactionId }, // Admin notification
            { message: ownerMessage, for_emp: owner_emp_id, transaction_id: transactionId }, // Owner notification
            { message: borrowerMessage, for_emp: borrower_emp_id, transaction_id: transactionId } // Borrower confirmation
        ];

        for (let notif of notifications) {
            await db.query(
                `INSERT INTO notification_tbl (message, for_emp, transaction_id, createdAt, updatedAt) 
                 VALUES (?, ?, ?, NOW(), NOW())`,
                [notif.message, notif.for_emp, notif.transaction_id]
            );
        }

        console.log("🔔 Notifications saved successfully!");

        res.status(201).json({ 
            message: "Borrow transaction recorded successfully!", 
            transactionId: transactionId 
        });
    } catch (error) {
        console.error("❌ Error processing borrow transaction:", error);
        res.status(500).json({ error: "Server error" });
    }
});

module.exports = router;
