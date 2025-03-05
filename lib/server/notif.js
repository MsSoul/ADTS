const express = require("express");
const db = require("./db");

const router = express.Router();

console.log("notif.js is running...");

// WebSocket instance (to be initialized in main server)
let io;
const setSocketIo = (socketIo) => {
  if (!io) {
    io = socketIo;

    io.on("connection", (socket) => {
      console.log("User connected:", socket.id);

      socket.on("joinRoom", (empId) => {
        socket.join(`emp_${empId}`);
        console.log(`User joined room: emp_${empId}`);
      });

      socket.on("disconnect", () => {
        console.log("User disconnected:", socket.id);
      });
    });
  }
};

// Fetch unread notifications for an employee
router.get("/:empId", async (req, res) => {
    const empId = parseInt(req.params.empId, 10);
  
    if (isNaN(empId)) {
      return res.status(400).json({ error: "Invalid employee ID" });
    }
  
    try {
      const [notifications] = await db.query(
        "SELECT ID, MESSAGE, `READ`, FOR_EMP, TRANSACTION_ID, created_at, updated_at " +
        "FROM notification_tbl " +
        "WHERE `FOR_EMP` = ? AND `READ` = 0 " +
        "ORDER BY created_at DESC",
        [empId]
      );
  
      res.json(notifications);
    } catch (err) {
      console.error("Error fetching notifications:", err);
      res.status(500).json({ error: err.message });
    }
  });
  

// Mark notification as read
router.put("/read/:id", async (req, res) => {
  try {
    await db.query(
      "UPDATE notification_tbl SET read = 1, updated_at = NOW() WHERE ID = ?",
      [req.params.id]
    );
    res.json({ message: "Notification marked as read" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Send real-time notification
const sendNotification = async (notification) => {
  if (io) {
    io.to(`emp_${notification.for_emp}`).emit("newNotification", notification);
  }
};

// Create a new notification
router.post("/", async (req, res) => {
  try {
    const { message, for_emp, transaction_id } = req.body;
    const [result] = await db.query(
      "INSERT INTO notification_tbl (message, for_emp, transaction_id, created_at, updated_at) VALUES (?, ?, ?, NOW(), NOW())",
      [message, for_emp, transaction_id]
    );

    const newNotification = {
      ID: result.insertId,
      message,
      read: 0,
      for_emp,
      transaction_id,
      created_at: new Date(),
      updated_at: new Date(),
    };

    sendNotification(newNotification);

    res.status(201).json(newNotification);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Export router & WebSocket setup
module.exports = { router, setSocketIo };
