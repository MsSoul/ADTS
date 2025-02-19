//filaname: lib/server/borrowing_transaction.js
const express = require('express');
const router = express.Router();
const db = require('../server/db');

console.log("borrowing_transaction.js is running...")

// Fetch borrowers based on current department ID
router.get('/borrowers', async (req, res) => {
    try {
        const { department_id, query, search_type } = req.query;
        const searchField = search_type === 'ID Number' ? 'ID_NUMBER' : "CONCAT(FIRSTNAME, ' ', LASTNAME)";
        
        const [borrowers] = await db.query(
            `SELECT ID, ID_NUMBER, FIRSTNAME, MIDDLENAME, LASTNAME, SUFFIX FROM employee WHERE DEPARTMENT_ID = ? AND ${searchField} LIKE ?`, 
            [department_id, `%${query}%`]
        );

        res.json(borrowers);
    } catch (error) {
        console.error('Error fetching borrowers:', error);
        res.status(500).json({ message: 'Internal server error' });
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
