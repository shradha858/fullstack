const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// PostgreSQL Connection Pool
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

// Middleware to handle async errors
const asyncHandler = (fn) => (req, res, next) =>
  Promise.resolve(fn(req, res, next)).catch(next);

// Routes

// Users
app.get('/api/users', asyncHandler(async (req, res) => {
  const result = await pool.query('SELECT * FROM users ORDER BY created_at DESC');
  res.json(result.rows);
}));

// Courses
app.get('/api/courses', asyncHandler(async (req, res) => {
  const result = await pool.query('SELECT * FROM courses ORDER BY code');
  res.json(result.rows);
}));

app.post('/api/courses', asyncHandler(async (req, res) => {
  const { code, name, description, credits } = req.body;
  const result = await pool.query(
    'INSERT INTO courses (code, name, description, credits) VALUES ($1, $2, $3, $4) RETURNING *',
    [code, name, description, credits]
  );
  res.status(201).json(result.rows[0]);
}));

// Enrollments
app.get('/api/enrollments', asyncHandler(async (req, res) => {
  const { studentId, courseId } = req.query;
  let query = `
    SELECT e.*, c.code, c.name as course_name, u.display_name as student_name
    FROM enrollments e
    JOIN courses c ON e.course_id = c.id
    JOIN users u ON e.student_id = u.id
    WHERE 1=1
  `;
  const params = [];

  if (studentId) {
    params.push(studentId);
    query += ` AND e.student_id = $${params.length}`;
  }
  if (courseId) {
    params.push(courseId);
    query += ` AND e.course_id = $${params.length}`;
  }

  query += ' ORDER BY c.code';

  const result = await pool.query(query, params);
  res.json(result.rows);
}));

app.post('/api/enrollments', asyncHandler(async (req, res) => {
  const { studentId, courseId, grade, percentage, status } = req.body;
  const result = await pool.query(
    'INSERT INTO enrollments (student_id, course_id, grade, percentage, status) VALUES ($1, $2, $3, $4, $5) RETURNING *',
    [studentId, courseId, grade, percentage, status]
  );
  res.status(201).json(result.rows[0]);
}));

// Faculty Assignments
app.get('/api/faculty-assignments', asyncHandler(async (req, res) => {
  const { facultyId } = req.query;
  let query = `
    SELECT fa.*, c.code, c.name as course_name, u.display_name as faculty_name
    FROM faculty_assignments fa
    JOIN courses c ON fa.course_id = c.id
    JOIN users u ON fa.faculty_id = u.id
  `;
  const params = [];

  if (facultyId) {
    params.push(facultyId);
    query += ' WHERE fa.faculty_id = $1';
  }

  query += ' ORDER BY c.code';

  const result = await pool.query(query, params);
  res.json(result.rows);
}));

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));