/*
  # Sample Data for GRADEX

  This migration adds sample data to test the application:
  - Sample users (admin, faculty, students)
  - Sample courses
  - Sample enrollments
  - Sample faculty assignments
*/

-- Sample Users
INSERT INTO users (email, role, display_name) VALUES
  ('admin@gradex.com', 'admin', 'System Administrator'),
  ('johnson@gradex.com', 'faculty', 'Dr. Robert Johnson'),
  ('garcia@gradex.com', 'faculty', 'Prof. Maria Garcia'),
  ('chen@gradex.com', 'faculty', 'Dr. Emily Chen'),
  ('student1@gradex.com', 'student', 'Alex Johnson'),
  ('student2@gradex.com', 'student', 'Maria Garcia'),
  ('student3@gradex.com', 'student', 'James Wilson');

-- Sample Courses
INSERT INTO courses (code, name, description, credits) VALUES
  ('CSE-101', 'Introduction to Computer Science', 'Fundamental concepts of programming and computer science', 3),
  ('CSE-201', 'Data Structures', 'Advanced data structures and algorithms', 4),
  ('MATH-101', 'Calculus I', 'Introduction to differential calculus', 4),
  ('ENG-101', 'Technical Writing', 'Professional communication skills', 3),
  ('PHY-101', 'Physics I', 'Classical mechanics and thermodynamics', 4);

-- Sample Faculty Assignments
INSERT INTO faculty_assignments (faculty_id, course_id) 
SELECT u.id, c.id 
FROM users u, courses c 
WHERE u.email = 'johnson@gradex.com' AND c.code = 'CSE-101';

INSERT INTO faculty_assignments (faculty_id, course_id) 
SELECT u.id, c.id 
FROM users u, courses c 
WHERE u.email = 'garcia@gradex.com' AND c.code = 'CSE-201';

-- Sample Enrollments
INSERT INTO enrollments (student_id, course_id, grade, percentage, status)
SELECT 
  u.id,
  c.id,
  'A',
  95,
  'completed'
FROM users u, courses c
WHERE u.email = 'student1@gradex.com' AND c.code = 'CSE-101';

INSERT INTO enrollments (student_id, course_id, grade, percentage, status)
SELECT 
  u.id,
  c.id,
  'B+',
  88,
  'completed'
FROM users u, courses c
WHERE u.email = 'student2@gradex.com' AND c.code = 'CSE-101';