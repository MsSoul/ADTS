// filename: lib/server/items.js
const express = require("express");
const db = require("../server/db");

const router = express.Router();

console.log("distributed_items.js is running...");

// Get distributed_items only if emp_id matches accountable_emp(for lending transaction)
router.get("/:emp_id", async (req, res) => {
    const { emp_id } = req.params;

    if (!emp_id || isNaN(emp_id)) {
        console.warn("Invalid or missing emp_id parameter.");
        return res.status(400).json({ error: "Invalid emp_id parameter." });
    }

    console.log(`Fetching distributed_items for emp_id: ${emp_id}...`);

    try {
        // Check if emp_id exists in the employee table
        const employeeQuery = "SELECT COUNT(*) AS count FROM employee WHERE ID = ?";
        const [employeeResult] = await db.query(employeeQuery, [emp_id]);

        if (employeeResult[0].count === 0) {
            console.warn(`Access denied: emp_id ${emp_id} not found in employee table.`);
            return res.status(403).json({ error: "Access denied. Employee not found." });
        }

        console.log(`Employee ID ${emp_id} found. Fetching distributed_items...`);

        // Fetch distributed_items for this emp_id
        const query = "SELECT * FROM distributed_items WHERE accountable_emp = ? AND deleted = 0";
        const [rows] = await db.query(query, [emp_id]);
        
        console.log("rows ", rows);
        if (rows.length === 0) {
            return res.status(200).json({ message: "No distributed items found.", items: [] });
        }

        res.status(200).json({ items: rows });
    } catch (error) {
        console.error("Database error:", error);
        res.status(500).json({ error: "Server error. Please try again later." });
    }
});

// Fetch distributed_items based on department ID (for borrowing transaction)
router.get("/department/:currentDptId", async (req, res) => {
    const { currentDptId } = req.params;

    if (!currentDptId || isNaN(currentDptId)) {
        console.warn("Invalid or missing currentDptId parameter.");
        return res.status(400).json({ error: "Invalid currentDptId parameter." });
    }

    console.log(`Fetching distributed_items for department_id: ${currentDptId}...`);

    try {
        // Check if department exists
        const departmentQuery = "SELECT COUNT(*) AS count FROM distributed_items WHERE current_dpt_id = ?";
        const [departmentResult] = await db.query(departmentQuery, [currentDptId]);

        if (departmentResult[0].count === 0) {
            console.warn(`Department ID ${currentDptId} not found.`);
            return res.status(403).json({ error: "Department not found." });
        }

        console.log(`Department ID ${currentDptId} found. Fetching distributed_items...`);

        // Fetch all available distributed_items for this department
        const query = "SELECT id AS distributed_item_id, * FROM distributed_items WHERE current_dpt_id = ? AND deleted = 0";
const [rows] = await db.query(query, [currentDptId]);


        console.log(`Total distributed_items fetched for department: ${rows.length}`);

        return res.status(200).json({ items: rows });
    } catch (error) {
        console.error("Database error:", error);
        return res.status(500).json({ error: "Server error. Please try again later." });
    }
});

module.exports = router;
