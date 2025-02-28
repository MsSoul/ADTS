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

router.get("/userName/:empId", async (req, res) => {
    try {
        const empId = Number(req.params.empId);

        if (isNaN(empId)) {
            console.warn("❌ Invalid or missing empId parameter.");
            return res.status(400).json({ error: "Invalid empId parameter." });
        }

        console.log(`🔍 Fetching userName for employee ID: ${empId}`);

        const [rows] = await db.query(
            "SELECT FIRSTNAME, MIDDLENAME, LASTNAME FROM employee WHERE ID = ?",
            [empId]
        );

        if (rows.length === 0) {
            console.warn(`⚠ Employee ID ${empId} not found.`);
            return res.status(404).json({ error: "User not found" });
        }

        const { FIRSTNAME, MIDDLENAME, LASTNAME } = rows[0];

        // Construct full name
        const userName = [FIRSTNAME, MIDDLENAME, LASTNAME]
            .filter(name => name && name.trim() !== '') 
            .map(name => name.trim()) 
            .join(" "); 

        console.log(`✅ User Name: ${userName}`);

        res.json({ userName });
    } catch (error) {
        console.error("❌ Error fetching user:", error);
        res.status(500).json({ error: "Server error" });
    }
});


module.exports = router;
