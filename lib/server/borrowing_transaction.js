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
            FROM items i
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
        const empId = parseInt(req.params.empId, 10); // Ensure empId is an integer

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
            .filter(name => name && name.trim() !== '')  // Remove empty/null values
            .map(name => name.trim())  // Trim spaces
            .join(" ");  // Join with a space

        console.log(`✅ User Name: ${userName}`);

        res.json({ userName });
    } catch (error) {
        console.error("❌ Error fetching user:", error);
        res.status(500).json({ error: "Server error" });
    }
});

// Borrow an item
router.post("/borrow", async (req, res) => {
    try {
        console.log("📥 Received borrow request:", req.body);

        const { borrower_emp_id, owner_emp_id, item_id, quantity, DPT_ID } = req.body;

        if (!borrower_emp_id || !owner_emp_id || !item_id || !quantity || !DPT_ID) {
            return res.status(400).json({ error: "Missing required fields" });
        }

        console.log(`🔄 Processing borrow request: Borrower ${borrower_emp_id}, Item ${item_id}`);

        // Check if item exists and fetch current available quantity
        const [itemRows] = await db.query(
            "SELECT quantity, accountable_emp FROM items WHERE id = ?",
            [item_id]
        );

        if (itemRows.length === 0) {
            return res.status(404).json({ error: "Item not found" });
        }

        const { quantity: available_quantity, accountable_emp } = itemRows[0];

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
            "INSERT INTO borrowing_transaction (item_id, borrower_emp_id, owner_emp_id, quantity, DPT_ID, createdAt, updatedAt, status) VALUES (?, ?, ?, ?, ?, NOW(), NOW(), ?)",
            [item_id, borrower_emp_id, owner_emp_id, quantity, DPT_ID, 1] // 1 = Pending or Active
        );

        // Update available quantity in items table
        await db.query(
            "UPDATE items SET quantity = quantity - ? WHERE id = ?",
            [quantity, item_id]
        );

        console.log(`✅ Borrow transaction successful: Transaction ID ${insertResult.insertId}`);
        res.status(201).json({ message: "Borrow transaction recorded", transactionId: insertResult.insertId });

    } catch (error) {
        console.error("❌ Error processing borrow transaction:", error);
        res.status(500).json({ error: "Server error" });
    }
});

module.exports = router;
