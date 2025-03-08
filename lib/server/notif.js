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
          "SELECT ID, MESSAGE, `READ`, FOR_EMP, TRANSACTION_ID, createdAt, updatedAt " +
          "FROM notification_tbl " +
          "WHERE `FOR_EMP` = ? " +  // 🔹 Removed AND `READ` = 0 to fetch all notifications
          "ORDER BY `READ` ASC, createdAt DESC", // 🔹 Sort unread first, then by latest
          [empId]
      );

      res.json(notifications);
  } catch (err) {
      console.error("Error fetching notifications:", err);
      res.status(500).json({ error: err.message });
  }
});

  

// Mark notification as read
router.put("/mark_as_read/:notifId", async (req, res) => {
  console.log("📥 Received request:", req.params); // Debugging log
  const { notifId } = req.params;

  if (!notifId) {
    return res.status(400).json({ message: "Missing notification ID" });
  }

  const [result] = await db.query(
    "UPDATE notification_tbl SET `READ` = 1 WHERE ID = ?", 
    [notifId]
  );

  if (result.affectedRows === 0) {
    return res.status(404).json({ message: "Notification not found" });
  }

  console.log(`✅ Notification ID ${notifId} marked as read`);
  res.status(200).json({ message: "Notification marked as read" });
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
      "INSERT INTO notification_tbl (message, for_emp, transaction_id, createdAt, updatedAt) VALUES (?, ?, ?, NOW(), NOW())",
      [message, for_emp, transaction_id]
    );

    const newNotification = {
      ID: result.insertId,
      message,
      read: 0,
      for_emp,
      transaction_id,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    sendNotification(newNotification);

    res.status(201).json(newNotification);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Export router & WebSocket setup
module.exports = { router, setSocketIo };
