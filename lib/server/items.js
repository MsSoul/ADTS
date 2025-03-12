const express = require("express");
const db = require("../server/db");

const router = express.Router();

console.log("distributed_items.js is running...");

// Fetch distributed_items by emp_id (accountable_emp) lending transaction
router.get("/:emp_id", async (req, res) => {
    const { emp_id } = req.params;

    if (!emp_id || isNaN(emp_id)) {
        console.warn("Invalid emp_id parameter.");
        return res.status(400).json({ error: "Invalid emp_id parameter." });
    }

    console.log(`Fetching distributed_items for emp_id: ${emp_id}...`);

    try {
        // Check if employee exists
        const employeeQuery = "SELECT 1 FROM employee WHERE ID = ? LIMIT 1";
        const [employeeResult] = await db.query(employeeQuery, [emp_id]);

        if (employeeResult.length === 0) {
            console.warn(`Access denied: emp_id ${emp_id} not found in employee table.`);
            return res.status(403).json({ error: "Access denied. Employee not found." });
        }

        console.log(`Employee ID ${emp_id} found. Fetching distributed_items...`);

        // Fetch all distributed_items for this emp_id
        const query = "SELECT * FROM distributed_items WHERE accountable_emp = ? AND deleted = 0";
        const [rows] = await db.query(query, [emp_id]);

        console.log(`Total distributed_items fetched: ${rows.length}`);

        return res.status(200).json({ items: rows });
    } catch (error) {
        console.error("Database error:", error);
        return res.status(500).json({ error: "Server error. Please try again later." });
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
        const query = `
            SELECT id AS distributed_item_id, ITEM_ID AS item_id, *
            FROM distributed_items
            WHERE current_dpt_id = ? AND deleted = 0
        `;
        const [rows] = await db.query(query, [currentDptId]);

        console.log(`Total distributed_items fetched for department: ${rows.length}`);

        return res.status(200).json({ items: rows });
    } catch (error) {
        console.error("Database error:", error);
        return res.status(500).json({ error: "Server error. Please try again later." });
    }
});

router.get("/borrowed/:borrower_emp_id", async (req, res) => {
    const { borrower_emp_id } = req.params;

    if (!borrower_emp_id || isNaN(borrower_emp_id)) {
        console.warn("Invalid or missing borrower_emp_id parameter.");
        return res.status(400).json({ error: "Invalid borrower_emp_id parameter." });
    }

    console.log(`Fetching borrowed items for borrower_emp_id: ${borrower_emp_id}...`);

    try {
        // Step 1: Fetch borrowing transactions where borrower_emp_id matches and status & remarks are 1
        const borrowingQuery = `
            SELECT distributed_item_id, owner_emp_id, createdAt 
            FROM borrowing_transaction 
            WHERE borrower_emp_id = ? 
            AND status = 1 
            AND remarks = 1
        `;
        const [borrowingRecords] = await db.query(borrowingQuery, [borrower_emp_id]);

        if (borrowingRecords.length === 0) {
            console.log("No borrowed items found.");
            return res.status(200).json({ borrowed_items: [] });
        }

        // Extract distributed_item_id and owner_emp_id from borrowing records
        const itemIds = borrowingRecords.map(record => record.distributed_item_id);
        const ownerIds = borrowingRecords.map(record => record.owner_emp_id);

        if (itemIds.length === 0) {
            console.log("No matching item IDs found.");
            return res.status(200).json({ borrowed_items: [] });
        }

        // Step 2: Fetch item details
        const itemDetailsQuery = `
            SELECT 
                i.ID AS ITEM_ID,
                i.ITEM_NAME, 
                i.DESCRIPTION, 
                i.PIC_NO, 
                i.PROP_NO, 
                i.SERIAL_NO
            FROM items i
            WHERE i.ID IN (${itemIds.map(() => "?").join(",")})
        `;
        const [itemDetails] = await db.query(itemDetailsQuery, itemIds);

        // Step 3: Fetch owner names
        const ownerDetailsQuery = `
            SELECT 
                e.ID AS OWNER_ID,
                CONCAT(e.FIRSTNAME, ' ', COALESCE(e.MIDDLENAME, ''), ' ', e.LASTNAME, ' ', COALESCE(e.SUFFIX, '')) AS OWNER_NAME
            FROM employee e
            WHERE e.ID IN (${ownerIds.map(() => "?").join(",")})
        `;
        const [ownerDetails] = await db.query(ownerDetailsQuery, ownerIds);

        // Step 4: Merge borrowing records with item and owner details
        const borrowedItems = borrowingRecords.map(borrowed => {
            const itemDetail = itemDetails.find(item => item.ITEM_ID === borrowed.distributed_item_id);
            const ownerDetail = ownerDetails.find(owner => owner.OWNER_ID === borrowed.owner_emp_id);
            return itemDetail && ownerDetail
                ? { 
                    distributed_item_id: borrowed.distributed_item_id,
                    createdAt: borrowed.createdAt,
                    ITEM_ID: itemDetail.ITEM_ID,
                    ITEM_NAME: itemDetail.ITEM_NAME,
                    DESCRIPTION: itemDetail.DESCRIPTION,
                    PIC_NO: itemDetail.PIC_NO,
                    PROP_NO: itemDetail.PROP_NO,
                    SERIAL_NO: itemDetail.SERIAL_NO,
                    OWNER_NAME: ownerDetail.OWNER_NAME.trim()
                  }
                : null;
        }).filter(item => item !== null); // Remove any unmatched items

        console.log(`Total borrowed items fetched: ${borrowedItems.length}`);

        return res.status(200).json({ borrowed_items: borrowedItems });

    } catch (error) {
        console.error("Database error:", error);
        return res.status(500).json({ error: "Server error. Please try again later." });
    }
});

module.exports = router;
